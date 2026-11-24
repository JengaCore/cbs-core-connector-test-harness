#!/usr/bin/env bash
# Runs the direct-integration Testing Toolkit collections against a Testing Toolkit that plays
# the DFSP, to prove that the collections and their assertions work. It starts its own
# containers, runs everything, copies the reports out and removes the containers.
#
#   ./run.sh [report-directory]
#
# Needs Docker. It uses docker cp only, so it also works with a remote Docker daemon.
# The exit status is 0 only when no assertion failed.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
TTK="$HERE/.."
REPORTS="${1:-$HERE/reports}"
PREFIX="ttk-di-selftest"
NET="$PREFIX-net"
MONGO="$PREFIX-mongo"
BACKEND="$PREFIX-backend"
CLIENT="$PREFIX-client"
TTK_IMAGE="mojaloop/ml-testing-toolkit:v18.19.2"
MONGO_IMAGE="mongo:6.0.5"
NODE_IMAGE="node:20-slim"
STATUS=0

cleanup() {
  docker rm -f "$CLIENT" "$BACKEND" "$MONGO" >/dev/null 2>&1
  docker network rm "$NET" >/dev/null 2>&1
}
trap cleanup EXIT
cleanup

say() { printf '\n== %s\n' "$*"; }
wait_for_ttk() {
  for _ in $(seq 1 60); do
    if docker exec "$BACKEND" node -e "fetch('http://localhost:4040/').then(()=>process.exit(0)).catch(()=>process.exit(1))" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  echo "The Testing Toolkit did not start" >&2
  return 1
}

say "Starting the Testing Toolkit"
docker network create "$NET" >/dev/null || exit 2
docker run -d --name "$MONGO" --network "$NET" \
  -e MONGO_INITDB_ROOT_USERNAME=ttk -e MONGO_INITDB_ROOT_PASSWORD='ttk@123' "$MONGO_IMAGE" >/dev/null || exit 2
sleep 6
docker run -d --name "$BACKEND" --network "$NET" \
  -e REPORTING_DB_CONNECTION_PASSWORD='ttk@123' \
  -e TTK_SYSTEM_CONFIG="{\"DB\":{\"HOST\":\"$MONGO\",\"PORT\":27017,\"USER\":\"ttk\",\"PASSWORD\":\"ttk@123\",\"DATABASE\":\"admin\"}}" \
  "$TTK_IMAGE" >/dev/null || exit 2
wait_for_ttk || exit 2

say "Loading the counterparty rules"
docker cp "$TTK/rules/counterparty-callback-rules.json" "$BACKEND:/opt/app/spec_files/rules_callback/di_callback_rules.json" || exit 2
docker cp "$TTK/rules/counterparty-validation-rules.json" "$BACKEND:/opt/app/spec_files/rules_validation/di_validation_rules.json" || exit 2
TMP="$(mktemp -d)"
echo '{"activeRulesFile":"di_callback_rules.json"}' >"$TMP/callback.json"
echo '{"activeRulesFile":"di_validation_rules.json"}' >"$TMP/validation.json"
docker cp "$TMP/callback.json" "$BACKEND:/opt/app/spec_files/rules_callback/config.json" || exit 2
docker cp "$TMP/validation.json" "$BACKEND:/opt/app/spec_files/rules_validation/config.json" || exit 2
rm -rf "$TMP"
docker restart "$BACKEND" >/dev/null || exit 2
wait_for_ttk || exit 2

say "Starting the client"
docker run -d --name "$CLIENT" --network "$NET" "$NODE_IMAGE" sleep infinity >/dev/null || exit 2
docker exec "$CLIENT" sh -c "npm install -g @mojaloop/ml-testing-toolkit-client-lib >/dev/null 2>&1 && mkdir -p /di" || exit 2
docker cp "$TTK/collections/di-inc.json" "$CLIENT:/di/di-inc.json" || exit 2
docker cp "$TTK/collections/di-out.json" "$CLIENT:/di/di-out.json" || exit 2
for f in incoming outgoing fake-dfsp; do
  docker cp "$HERE/$f.env.json" "$CLIENT:/di/$f.env.json" || exit 2
done

# The fake DFSP sends the same messages a real DFSP would: it reuses the incoming cases, with the
# roles reversed (see fake-dfsp.env.json).
docker exec "$CLIENT" node -e "
const fs=require('fs');const d=JSON.parse(fs.readFileSync('/di/di-inc.json'));
const by=Object.fromEntries(d.test_cases.map(c=>[c.id,c]));
fs.writeFileSync('/di/fake-payment.json',JSON.stringify({name:'fake DFSP payment',test_cases:[by['DI-INC-01'],by['DI-INC-04'],by['DI-INC-10']]}));
fs.writeFileSync('/di/fake-unknown.json',JSON.stringify({name:'fake DFSP unknown party',test_cases:[by['DI-INC-03']]}));
" || exit 2

CLI="ml-ttk-cli -m outbound -u http://$BACKEND:5050 --report-format html"

say "Incoming payments (the DFSP is the payee)"
docker exec "$CLIENT" sh -c "cd /di && $CLI -i di-inc.json -e incoming.env.json --report-target file://incoming.html" || STATUS=1

say "Outgoing payments (the DFSP is the payer)"
docker exec -d "$CLIENT" sh -c "cd /di && $CLI -i di-out.json -e outgoing.env.json --report-target file://outgoing.html > out.log 2>&1; echo \$? > out.status"
sleep 10
docker exec "$CLIENT" sh -c "cd /di && $CLI -i fake-payment.json -e fake-dfsp.env.json --report-target file://fake-payment.html >/dev/null" || STATUS=1
sleep 4
docker exec "$CLIENT" sh -c "cd /di && $CLI -i fake-unknown.json -e fake-dfsp.env.json --report-target file://fake-unknown.html >/dev/null" || STATUS=1
for _ in $(seq 1 40); do
  docker exec "$CLIENT" test -f /di/out.status && break
  sleep 3
done
docker exec "$CLIENT" sh -c "grep -E 'Passed assertions|Failed assertions' /di/out.log"
[ "$(docker exec "$CLIENT" cat /di/out.status 2>/dev/null)" = "0" ] || STATUS=1

say "Copying the reports to $REPORTS"
mkdir -p "$REPORTS"
for f in incoming outgoing; do
  docker cp "$CLIENT:/di/$f.html" "$REPORTS/$f.html" 2>/dev/null || true
done

if [ "$STATUS" -eq 0 ]; then
  say "Self-test passed"
else
  say "Self-test FAILED"
fi
exit "$STATUS"
