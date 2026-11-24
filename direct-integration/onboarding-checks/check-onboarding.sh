#!/usr/bin/env bash
# Read-only checks of a DFSP's onboarding against the hub's Mojaloop Connection Manager (MCM).
# They cover DI-ONB-01 to DI-ONB-09 and, when the hosts are given, DI-SEC-02 to DI-SEC-04
# in register.md. The checks only read. Nothing is created or changed.
#
# Needs: bash, curl, jq, openssl.
#
# Settings (environment variables):
#   MCM_URL             MCM API base URL for DFSPs, for example https://mcm.<switch domain>/pm4mlapi
#   TOKEN_URL           The Keycloak token URL for your realm
#   DFSP_ID             Your DFSP id (it is also the Keycloak client id)
#   CLIENT_SECRET_FILE  A file that contains the client secret (read by curl, never printed)
# Optional:
#   CALLBACK_HOST       Your callback host. Enables the certificate checks and DI-SEC-02, DI-SEC-03
#   CALLBACK_PORT       Port of the callback host (default 443)
#   FSPIOP_HOST         The switch FSPIOP host. With CLIENT_CERT and CLIENT_KEY it enables DI-SEC-04
#   CLIENT_CERT         Your client certificate (PEM) issued by the hub
#   CLIENT_KEY          Its private key (PEM)
#   MIN_KEY_BITS        Minimum RSA key length for the JWS key (default 2048)
#   HUB_ID              The id of the hub's entry in GET /dfsps/jwscerts (default Hub)
#
# Exit status: 0 when no check failed, 1 when a check failed, 2 when the settings are incomplete.
set -u

PASS=0
FAIL=0
SKIP=0
pass() { printf 'PASS  %s  %s\n' "$1" "$2"; PASS=$((PASS + 1)); }
fail() { printf 'FAIL  %s  %s\n' "$1" "$2"; FAIL=$((FAIL + 1)); }
skip() { printf 'SKIP  %s  %s\n' "$1" "$2"; SKIP=$((SKIP + 1)); }
info() { printf 'INFO  %s  %s\n' "$1" "$2"; }

for tool in curl jq openssl; do
  command -v "$tool" >/dev/null || { echo "Missing tool: $tool" >&2; exit 2; }
done
for var in MCM_URL TOKEN_URL DFSP_ID CLIENT_SECRET_FILE; do
  if [ -z "${!var:-}" ]; then echo "Missing setting: $var" >&2; exit 2; fi
done
[ -r "$CLIENT_SECRET_FILE" ] || { echo "Cannot read CLIENT_SECRET_FILE" >&2; exit 2; }

MCM_URL="${MCM_URL%/}"
CALLBACK_PORT="${CALLBACK_PORT:-443}"
MIN_KEY_BITS="${MIN_KEY_BITS:-2048}"
HUB_ID="${HUB_ID:-Hub}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
chmod 700 "$WORK"

# ---- DI-ONB-01: token ------------------------------------------------------------------
tr -d '\r\n' <"$CLIENT_SECRET_FILE" >"$WORK/secret"
chmod 600 "$WORK/secret"
TOKEN_JSON="$(curl -sS --max-time 30 -X POST "$TOKEN_URL" \
  --data-urlencode "client_id=$DFSP_ID" \
  --data-urlencode "client_secret@$WORK/secret" \
  --data-urlencode "grant_type=client_credentials" 2>"$WORK/token.err")"
TOKEN="$(printf '%s' "$TOKEN_JSON" | jq -r '.access_token // empty' 2>/dev/null)"
if [ -z "$TOKEN" ]; then
  fail DI-ONB-01 "no access token from the token URL ($(printf '%s' "$TOKEN_JSON" | jq -r '.error_description // .error // empty' 2>/dev/null | head -c 120))"
  echo
  printf 'Summary: %d passed, %d failed, %d skipped\n' "$PASS" "$FAIL" "$SKIP"
  exit 1
fi
# The token goes to curl through a file, so it does not appear in the process list.
printf 'header = "Authorization: Bearer %s"\n' "$TOKEN" >"$WORK/auth.cfg"
chmod 600 "$WORK/auth.cfg"
unset TOKEN TOKEN_JSON

# api PATH: prints the body. The HTTP status is left in $WORK/api.code
api() {
  local out="$WORK/api.out" code
  code="$(curl -sS --max-time 30 -K "$WORK/auth.cfg" -o "$out" -w '%{http_code}' "$MCM_URL$1" 2>/dev/null)"
  printf '%s' "$code" >"$WORK/api.code"
  cat "$out" 2>/dev/null
}
# issued_by_ca CERT: succeeds when CERT chains to the registered DFSP CA
issued_by_ca() {
  if [ -s "$WORK/ca-chain.pem" ]; then
    openssl verify -CAfile "$WORK/ca.pem" -untrusted "$WORK/ca-chain.pem" "$1" >/dev/null 2>&1
  else
    openssl verify -CAfile "$WORK/ca.pem" "$1" >/dev/null 2>&1
  fi
}
as_list() { jq -c 'if type == "array" then . else [.] end' 2>/dev/null; }

CA_JSON="$(api "/dfsps/$DFSP_ID/ca")"
API_CODE="$(cat "$WORK/api.code")"
if [ "$API_CODE" = 200 ]; then
  pass DI-ONB-01 "token obtained and accepted by MCM"
else
  fail DI-ONB-01 "MCM answered $API_CODE to GET /dfsps/$DFSP_ID/ca"
fi

# ---- DI-ONB-02: DFSP CA ----------------------------------------------------------------
printf '%s' "$CA_JSON" | jq -r '.rootCertificate // empty' >"$WORK/ca.pem" 2>/dev/null
if [ -s "$WORK/ca.pem" ] && [ "$(printf '%s' "$CA_JSON" | jq -r '.validationState // empty')" = VALID ]; then
  if openssl x509 -in "$WORK/ca.pem" -noout -ext basicConstraints 2>/dev/null | grep -q 'CA:TRUE'; then
    pass DI-ONB-02 "CA registered, validationState VALID, a CA certificate"
  else
    fail DI-ONB-02 "CA registered and VALID, but its certificate is not marked CA:TRUE"
  fi
else
  fail DI-ONB-02 "no valid CA root registered (validationState $(printf '%s' "$CA_JSON" | jq -r '.validationState // "missing"' 2>/dev/null))"
fi
printf '%s' "$CA_JSON" | jq -r '.intermediateChain // empty' >"$WORK/ca-chain.pem" 2>/dev/null

# ---- DI-ONB-03: callback server certificate ----------------------------------------------
SC_JSON="$(api "/dfsps/$DFSP_ID/servercerts")"
printf '%s' "$SC_JSON" | jq -r '.serverCertificate // empty' >"$WORK/server.pem" 2>/dev/null
if [ -s "$WORK/server.pem" ] && [ "$(printf '%s' "$SC_JSON" | jq -r '.validationState // empty')" = VALID ]; then
  detail="validationState VALID"
  ok=1
  if [ -s "$WORK/ca.pem" ]; then
    if issued_by_ca "$WORK/server.pem"; then
      detail="$detail, chains to the registered CA"
    else
      ok=0
      detail="the server certificate does not chain to the registered CA"
    fi
  fi
  if [ -n "${CALLBACK_HOST:-}" ]; then
    if openssl x509 -in "$WORK/server.pem" -noout -ext subjectAltName 2>/dev/null | grep -qi "DNS:$CALLBACK_HOST"; then
      detail="$detail, names $CALLBACK_HOST"
    else
      ok=0
      detail="the server certificate does not name $CALLBACK_HOST"
    fi
  fi
  if [ "$ok" = 1 ]; then pass DI-ONB-03 "$detail"; else fail DI-ONB-03 "$detail"; fi
else
  fail DI-ONB-03 "no valid server certificate registered (validationState $(printf '%s' "$SC_JSON" | jq -r '.validationState // "missing"' 2>/dev/null))"
fi

# ---- DI-ONB-04: JWS key ----------------------------------------------------------------
JW_JSON="$(api "/dfsps/$DFSP_ID/jwscerts")"
printf '%s' "$JW_JSON" | jq -r '.publicKey // empty' >"$WORK/jws.pem" 2>/dev/null
ALL_JWS="$(api "/dfsps/jwscerts" | as_list)"
if [ -s "$WORK/jws.pem" ]; then
  bits="$(openssl pkey -pubin -in "$WORK/jws.pem" -noout -text 2>/dev/null | sed -n 's/.*Public-Key: (\([0-9]*\) bit).*/\1/p' | head -1)"
  listed="$(printf '%s' "$ALL_JWS" | jq -r --arg d "$DFSP_ID" '[.[] | select(.dfspId == $d)] | length' 2>/dev/null)"
  if [ -z "$bits" ]; then
    fail DI-ONB-04 "the registered JWS key is not a readable PEM public key"
  elif [ "$bits" -lt "$MIN_KEY_BITS" ]; then
    fail DI-ONB-04 "the JWS key is $bits bits, below $MIN_KEY_BITS"
  elif [ "${listed:-0}" -lt 1 ]; then
    fail DI-ONB-04 "the key is registered but is not in GET /dfsps/jwscerts"
  else
    pass DI-ONB-04 "RSA public key of $bits bits registered and listed"
  fi
else
  fail DI-ONB-04 "no JWS public key registered"
fi

# ---- DI-ONB-05: callback URL and egress addresses ----------------------------------------
EP_JSON="$(api "/dfsps/$DFSP_ID/endpoints" | as_list)"
URLS="$(printf '%s' "$EP_JSON" | jq -r '.[] | select((.type // "" | ascii_upcase) == "URL" and (.direction // "" | ascii_upcase) == "INGRESS") | .value.url' 2>/dev/null)"
EG_JSON="$(api "/dfsps/$DFSP_ID/endpoints/egress")"
n_egress="$(printf '%s' "$EG_JSON" | jq '[.ipList[]? | select(.address)] | length' 2>/dev/null)"
if [ -z "$URLS" ]; then
  fail DI-ONB-05 "no ingress URL registered"
elif [ -n "${CALLBACK_HOST:-}" ] && ! printf '%s\n' "$URLS" | grep -q "$CALLBACK_HOST"; then
  fail DI-ONB-05 "an ingress URL is registered but none names $CALLBACK_HOST"
elif [ "${n_egress:-0}" -lt 1 ]; then
  fail DI-ONB-05 "ingress URL registered, but no egress address (the hub's onboarding needs at least one)"
else
  pass DI-ONB-05 "ingress URL registered: $(printf '%s\n' "$URLS" | head -1). $n_egress egress address(es) registered"
fi

# ---- DI-ONB-06: the hub's client certificate, signed by the DFSP CA ---------------------
OUT_JSON="$(api "/dfsps/$DFSP_ID/enrollments/outbound" | as_list)"
n_out="$(printf '%s' "$OUT_JSON" | jq 'length' 2>/dev/null)"
signed="$(printf '%s' "$OUT_JSON" | jq -c '[.[] | select((.state | tostring) == "CERT_SIGNED")] | last // empty' 2>/dev/null)"
if [ -z "$signed" ]; then
  fail DI-ONB-06 "the hub's request is not signed yet (${n_out:-0} enrolment(s), states: $(printf '%s' "$OUT_JSON" | jq -r '[.[].state | tostring] | join(",")' 2>/dev/null))"
else
  printf '%s' "$signed" | jq -r '.certificate // empty' >"$WORK/hub-client.pem"
  if [ -s "$WORK/hub-client.pem" ] && issued_by_ca "$WORK/hub-client.pem"; then
    pass DI-ONB-06 "the hub's client certificate is CERT_SIGNED and issued by the DFSP CA"
  else
    fail DI-ONB-06 "CERT_SIGNED, but the certificate was not issued by the registered DFSP CA"
  fi
fi

# ---- DI-ONB-07 and DI-ONB-08: the DFSP's client certificate ------------------------------
IN_JSON="$(api "/dfsps/$DFSP_ID/enrollments/inbound" | as_list)"
n_in="$(printf '%s' "$IN_JSON" | jq 'length' 2>/dev/null)"
states="$(printf '%s' "$IN_JSON" | jq -r '[.[].state | tostring] | join(",")' 2>/dev/null)"
if [ "${n_in:-0}" -lt 1 ]; then
  fail DI-ONB-07 "no client certificate request submitted"
elif [ "$(printf '%s' "$IN_JSON" | jq '[.[] | select((.state | tostring) != "INVALID")] | length')" -lt 1 ]; then
  fail DI-ONB-07 "every request is INVALID (states: $states)"
else
  pass DI-ONB-07 "request submitted (states: $states)"
fi
csigned="$(printf '%s' "$IN_JSON" | jq -c '[.[] | select((.state | tostring) == "CERT_SIGNED")] | last // empty' 2>/dev/null)"
if [ -z "$csigned" ]; then
  fail DI-ONB-08 "the hub has not signed the client certificate request (states: $states)"
else
  printf '%s' "$csigned" | jq -r '.certificate // empty' >"$WORK/dfsp-client.pem"
  if [ -s "$WORK/dfsp-client.pem" ] && openssl x509 -in "$WORK/dfsp-client.pem" -noout -checkend 0 >/dev/null 2>&1; then
    until="$(openssl x509 -in "$WORK/dfsp-client.pem" -noout -enddate 2>/dev/null | sed 's/notAfter=//')"
    pass DI-ONB-08 "client certificate CERT_SIGNED and valid until $until"
  else
    fail DI-ONB-08 "CERT_SIGNED, but the certificate is missing or expired"
  fi
fi

# ---- DI-ONB-09: hub CA and the hub's JWS key ---------------------------------------------
HUB_JSON="$(api "/hub/ca")"
printf '%s' "$HUB_JSON" | jq -r '.rootCertificate // empty' >"$WORK/hub-ca.pem" 2>/dev/null
hub_key="$(printf '%s' "$ALL_JWS" | jq -r --arg h "$HUB_ID" '[.[] | select(.dfspId == $h)] | length' 2>/dev/null)"
if [ -s "$WORK/hub-ca.pem" ] && [ "${hub_key:-0}" -ge 1 ]; then
  fp="$(openssl x509 -in "$WORK/hub-ca.pem" -noout -fingerprint -sha256 2>/dev/null | sed 's/.*=//')"
  pass DI-ONB-09 "hub CA available (SHA-256 fingerprint $fp: compare with the CA your system trusts), and the hub's JWS key is listed as $HUB_ID"
elif [ ! -s "$WORK/hub-ca.pem" ]; then
  fail DI-ONB-09 "GET /hub/ca returned no root certificate"
else
  fail DI-ONB-09 "the hub's JWS key is not in GET /dfsps/jwscerts (no entry named $HUB_ID). Ask the hub operator"
fi

# ---- DI-SEC-02 and DI-SEC-03: the callback host -------------------------------------------
if [ -n "${CALLBACK_HOST:-}" ]; then
  if curl -sS --max-time 15 -o /dev/null "https://$CALLBACK_HOST:$CALLBACK_PORT/" --insecure 2>/dev/null; then
    fail DI-SEC-02 "the callback host accepted a TLS client with no certificate"
  else
    pass DI-SEC-02 "the callback host refused a TLS client with no certificate"
  fi
  openssl s_client -connect "$CALLBACK_HOST:$CALLBACK_PORT" -servername "$CALLBACK_HOST" </dev/null 2>/dev/null \
    | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | awk '/END CERTIFICATE/{print; exit} {print}' >"$WORK/presented.pem"
  if [ -s "$WORK/presented.pem" ] && [ -s "$WORK/ca.pem" ]; then
    if issued_by_ca "$WORK/presented.pem" \
      && openssl x509 -in "$WORK/presented.pem" -noout -ext subjectAltName 2>/dev/null | grep -qi "DNS:$CALLBACK_HOST"; then
      pass DI-SEC-03 "the callback host presents a certificate issued by the DFSP CA that names $CALLBACK_HOST"
    else
      fail DI-SEC-03 "the certificate presented by the callback host is not issued by the DFSP CA or does not name the host"
    fi
  else
    fail DI-SEC-03 "no certificate was presented by $CALLBACK_HOST:$CALLBACK_PORT"
  fi
else
  skip DI-SEC-02 "set CALLBACK_HOST to check the callback host"
  skip DI-SEC-03 "set CALLBACK_HOST to check the callback host"
fi

# ---- DI-SEC-04: the switch requires the client certificate ------------------------------
if [ -n "${FSPIOP_HOST:-}" ] && [ -n "${CLIENT_CERT:-}" ] && [ -n "${CLIENT_KEY:-}" ]; then
  with="$(curl -sS --max-time 20 -o /dev/null -w '%{http_code}' --cert "$CLIENT_CERT" --key "$CLIENT_KEY" "https://$FSPIOP_HOST/" 2>/dev/null)"
  if curl -sS --max-time 20 -o /dev/null "https://$FSPIOP_HOST/" 2>/dev/null; then
    fail DI-SEC-04 "the switch accepted a TLS client with no certificate"
  elif [ -n "$with" ] && [ "$with" != 000 ]; then
    pass DI-SEC-04 "the switch answered ($with) with your certificate and refused a client without one"
  else
    fail DI-SEC-04 "the switch refused your client certificate"
  fi
else
  skip DI-SEC-04 "set FSPIOP_HOST, CLIENT_CERT and CLIENT_KEY to check the switch"
fi

echo
printf 'Summary: %d passed, %d failed, %d skipped\n' "$PASS" "$FAIL" "$SKIP"
[ "$FAIL" -eq 0 ]
