# Onboarding a DFSP to the hub

This document describes everything a DFSP must do to be admitted to the hub when it integrates directly, without the Payment Manager. It covers the certificates and keys to create, the calls to make to the Mojaloop Connection Manager (MCM), the steps the hub operator performs, and how to check each step.

Implementation is yours. The behaviour below is what the hub requires and what it checks.

## 1. How trust works

There are two mutual TLS directions between a DFSP and the hub. Each has its own certificate authority (CA).

| Direction | Who presents a certificate | Issued by |
|---|---|---|
| DFSP calls the hub (`fspiop.<switch domain>`) | The DFSP: its **client certificate** | The **hub's** CA. The hub operator signs your request |
| Hub calls the DFSP (your callback host) | The DFSP: its **server certificate** | The **DFSP's** CA |
| Hub calls the DFSP (your callback host) | The hub: its **client certificate for your DFSP** | The **DFSP's** CA. You sign the hub's request |

So a DFSP needs its own CA. It uploads the CA's root certificate to MCM so that the hub trusts your server certificate, and it uses the CA to sign the certificate the hub presents when it calls you. The CA's private key never leaves the DFSP.

Messages are also signed at application level (JWS). You create a signing key, publish the public key through MCM, and fetch the other participants' public keys from MCM. See [clearing-behaviour.md](clearing-behaviour.md#7-jws).

## 2. What you need from the hub operator

Ask for each of these before starting. The full list, with what the hub does in return, is in [hub-requests.md](hub-requests.md).

| Item | Used for |
|---|---|
| Your DFSP id, exactly as created in MCM (case-sensitive, permanent) | The path of every MCM call and the `FSPIOP-Source` of every message |
| The Keycloak client id and client secret for your DFSP, over a secure channel | Authenticating to MCM |
| The Keycloak token URL (realm) | Getting a token |
| The MCM API base URL for DFSPs | All onboarding calls |
| The switch FSPIOP host | Your payment traffic |
| The API type (`iso20022`) and settlement currency | Message format and the currencies you can use |
| The hub's JWS public key | Validating messages the hub originates |

On the sandbox the pattern is: token URL `https://keycloak.<switch domain>/realms/dfsps/protocol/openid-connect/token`, MCM base `https://mcm.<switch domain>/pm4mlapi`, FSPIOP host `https://fspiop.<switch domain>`. The realm name and paths are the hub operator's choice. Confirm them.

## 3. Keys and certificates to create

All material is PEM. **RSA only.** MCM reads the RSA modulus when it validates certificates and requests, so EC keys fail validation.

| Item | Requirements | Checked by MCM |
|---|---|---|
| DFSP CA (root, optionally an intermediate chain) | RSA. A CA certificate: it must be usable to sign certificates. Self-signed root is fine | Root verifies, chain verifies, CA usage |
| Server certificate for your callback host | Signed by your CA. Names the callback host. Server-authentication usage. Valid now. RSA, at least the hub's configured key length | Server usage, validity, chain, key length, root, chain |
| Hub client certificate (you sign the hub's request) | Signed by your CA, SHA-256 signature, same public key as the hub's request, valid now. Include the client-authentication extended key usage (recommended: MCM does not check it) | Valid, SHA-256, signed by your CA, same key as the request |
| Your client certificate request (CSR) | RSA, at least the hub's configured key length, signature SHA-256 or stronger, valid signature | CSR signature, algorithm, key length |
| JWS signing key | RSA, 2048 bits or more (the signature specification requires this) | The public key parses as PEM |

Key length: the hub's MCM is configured with a minimum key length of 2048 bits on the reference deployment. Some hubs configure 4096. Ask the hub operator and use that value. Using 4096 is safe under either setting.

The callback host must be named in the server certificate, because the hub verifies it when it calls you.

## 4. Authenticating to MCM

Request a token with the OAuth 2.0 client credentials grant. The client id is your DFSP id.

```
POST <token URL>
Content-Type: application/x-www-form-urlencoded

client_id=<dfsp id>&client_secret=<client secret>&grant_type=client_credentials
```

Send the returned `access_token` as `Authorization: Bearer <token>` on every MCM call. Request a new token before it expires.

You can only use paths that contain your own DFSP id (`/dfsps/<dfsp id>/...`). Another id returns `403 Forbidden`.

## 5. The steps

Paths are relative to the MCM base URL. Bodies are JSON. "Hub" steps are done by the hub operator.

| # | Who | Step | Call |
|---|---|---|---|
| 1 | Hub | Creates your DFSP in MCM and your Keycloak client. MCM also creates the hub's client certificate request for you | — |
| 2 | DFSP | Upload your CA root | `POST /dfsps/{dfspId}/ca` |
| 3 | DFSP | Upload your callback server certificate | `POST /dfsps/{dfspId}/servercerts` |
| 4 | DFSP | Upload your JWS public key | `POST /dfsps/{dfspId}/jwscerts` |
| 5 | DFSP | Register your callback URL | `POST /dfsps/{dfspId}/endpoints/ingress` |
| 6 | DFSP | Sign the hub's client certificate request and return the certificate | `GET /dfsps/{dfspId}/enrollments/outbound`, then `POST …/outbound/{enId}/certificate` |
| 7 | DFSP | Submit your client certificate request | `POST /dfsps/{dfspId}/enrollments/inbound` |
| 8 | Hub | Signs your request in MCM | MCM UI |
| 9 | DFSP | Collect your signed client certificate | `GET /dfsps/{dfspId}/enrollments/inbound/{enId}` |
| 10 | DFSP | Fetch the hub CA and the participants' JWS keys, and keep them current | `GET /hub/ca`, `GET /dfsps/jwscerts` |
| 11 | Hub | Checks your callbacks are registered, then activates, funds and sets limits for your participant | Finance portal |

### Step 2: DFSP CA

```
POST /dfsps/{dfspId}/ca
{ "rootCertificate": "<PEM>", "intermediateChain": "<PEM, optional>" }
```

Never send a private key. Check with `GET /dfsps/{dfspId}/ca`: `validationState` is `VALID`.

### Step 3: server certificate

```
POST /dfsps/{dfspId}/servercerts
{ "rootCertificate": "<PEM>", "intermediateChain": "<PEM or array of PEM>", "serverCertificate": "<PEM>" }
```

Check with `GET /dfsps/{dfspId}/servercerts`: `validationState` is `VALID`.

### Step 4: JWS public key

```
POST /dfsps/{dfspId}/jwscerts
{ "publicKey": "<PEM public key>", "createdAt": <unix time, optional> }
```

Send the public key (PEM, `BEGIN PUBLIC KEY`), not a certificate. Check with `GET /dfsps/{dfspId}/jwscerts`.

### Step 5: callback URL

```
POST /dfsps/{dfspId}/endpoints/ingress
{ "url": "https://<callback host>/" }
```

The hub registers your participant's callback endpoints from this record. Do not ask the hub to add callbacks by hand. If they are missing, the URL record is missing or wrong.

Egress IP addresses: the Payment Manager also posts its egress addresses (`POST /dfsps/{dfspId}/endpoints/egress` with `{ "ipList": [ { "description": "…", "address": "<IP or CIDR>", "ports": ["443"] } ] }`). Whether a hub requires them is the hub operator's decision. Ask.

### Step 6: sign the hub's request

The hub's request exists as soon as your DFSP is created. Poll until it appears.

```
GET /dfsps/{dfspId}/enrollments/outbound?state=CSR_LOADED
```

Each item has an `id` and a PEM `csr`. Sign it with your CA key (SHA-256, valid now, same public key, client-authentication usage), then:

```
POST /dfsps/{dfspId}/enrollments/outbound/{enId}/certificate
{ "certificate": "<PEM>" }
```

The enrollment state becomes `CERT_SIGNED`. This certificate is the one the hub presents when it calls you.

### Step 7 to 9: your client certificate

Generate an RSA key and a CSR, then:

```
POST /dfsps/{dfspId}/enrollments/inbound
{ "clientCSR": "<PEM>" }
```

The response gives the enrollment id. The hub operator signs the request in MCM. It is a deliberate human decision and is not automatic. Poll:

```
GET /dfsps/{dfspId}/enrollments/inbound/{enId}
```

When `state` is `CERT_SIGNED` the `certificate` field holds your client certificate. Use it, with your key, to call the switch FSPIOP host over mutual TLS. If the request is invalid, `state` is `INVALID` and the validation results say why.

### Step 10: trust material

```
GET /hub/ca                 the hub's root and chain: trust these for TLS to the switch
GET /dfsps/jwscerts         every registered participant's JWS public key
```

Refresh the JWS keys regularly. A message from a participant whose key you do not hold cannot be validated. The hub's own JWS key may not appear in the list. Ask the hub operator for it.

## 6. After the hub signs

When your client certificate is signed, the hub registers your participant on its ledger (position and settlement accounts in your currency, net debit cap) and your callback endpoints. The hub operator then checks the callbacks, and activates the participant, funds it and sets its limits in the finance portal. You are ready to exchange payments only after the hub confirms.

Callbacks only work when your callback host resolves, port 443 reaches your service with TLS passed through to it (not terminated by a load balancer), and your service requires and verifies a client certificate signed by your CA, which is how it knows the caller is the hub.

## 7. Renewal and rotation

| Item | Behaviour |
|---|---|
| Your client certificate | Expires. The Payment Manager sends a new request 7 days before expiry. Do the same, or earlier. The hub operator signs a renewal as a new request. Until it is signed you can still receive payments but not send them |
| The hub's client certificate for you | Signed by your CA. Sign each new request the hub makes, as in step 6 |
| Your server certificate | Yours to renew. Upload the new one with step 3. The hub trusts your CA, so nothing is needed on the hub |
| Your CA | Not renewed. Replacing it means onboarding again |
| JWS keys | Publish a new key with step 4 and keep the old one until messages signed with it are finished |

Lifetimes are set by whoever signs: the hub for your client certificate, you for the others. Agree the lifetimes with the hub operator.

## 8. Checking your work

| Check | How |
|---|---|
| CA, server certificate, JWS key accepted | `GET` each resource and read `validationState` and `validations` |
| Hub request signed | `GET …/enrollments/outbound`: your item is `CERT_SIGNED` |
| Your certificate signed | `GET …/enrollments/inbound/{enId}`: `CERT_SIGNED`, certificate present |
| Hub can reach your callbacks | The hub operator confirms the callbacks on your participant. [register.md](register.md) rows `DI-ONB-*` and `DI-SEC-*` |

## 9. Sources

- MCM API definition: [swagger.yaml](https://github.com/mojaloop/connection-manager-api/blob/main/src/api/swagger.yaml)
- Reference client, which performs these steps: [mcm-client](https://github.com/mojaloop/mcm-client/tree/main/src/lib)
- Validation rules: [`ValidationsConfiguration.js`](https://github.com/mojaloop/connection-manager-api/blob/main/src/pki_engine/ValidationsConfiguration.js)
- Token request: [RFC 6749 section 4.4](https://datatracker.ietf.org/doc/html/rfc6749#section-4.4)
