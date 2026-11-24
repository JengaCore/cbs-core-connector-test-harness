# Requests to the hub operator

A DFSP that integrates directly depends on the hub operator for some information and some actions. This sheet lists both. Send the first table to the hub operator as one request at the start. Track the second table as the onboarding proceeds.

Secrets (the client secret in particular) must be sent over a secure channel and never by chat, email or ticket.

Repeat everything for each environment. A DFSP is onboarded on the test environment first and on production after, with its own client, certificates and records in each.

## 1. What to ask the hub operator for

| # | Ask for | Why you need it | Used in |
|---|---|---|---|
| 1 | Your DFSP id | It is permanent. It is the path of every MCM call and the `FSPIOP-Source` of every message | [onboarding.md](onboarding.md) |
| 2 | Your settlement currency or currencies | The hub only settles the currencies it has accounts for. Yours must be one of them | [clearing-behaviour.md](clearing-behaviour.md) |
| 3 | Your Keycloak client id and client secret | To authenticate to MCM | [onboarding.md](onboarding.md#4-authenticating-to-mcm) |
| 4 | The token URL (the Keycloak realm) | To request a token | [onboarding.md](onboarding.md#4-authenticating-to-mcm) |
| 5 | The MCM API base URL for DFSPs | All onboarding calls | [onboarding.md](onboarding.md#5-the-steps) |
| 6 | The FSPIOP host | Your payment traffic | [clearing-behaviour.md](clearing-behaviour.md#31-who-calls-whom) |
| 7 | The API type and ILP version | The hub's ISO 20022 mode and ILPv4 | [clearing-behaviour.md](clearing-behaviour.md#1-scope-and-reference-versions) |
| 8 | The minimum RSA key length MCM enforces | For your CSR and server certificate | [onboarding.md](onboarding.md#3-keys-and-certificates-to-create) |
| 9 | The hub's JWS public key, and the name the hub uses as `FSPIOP-Source` | To validate messages the hub originates | [clearing-behaviour.md](clearing-behaviour.md#7-jws) |
| 10 | The identifier types enabled, and the sub id value that routes to your DFSP | Lookups are routed by a static oracle the hub operator maintains | [clearing-behaviour.md](clearing-behaviour.md#41-request) |
| 11 | Whether the hub requires your egress IP addresses to be registered | The Payment Manager registers them. Whether a hub needs them is its decision | [onboarding.md](onboarding.md#step-5-callback-url) |
| 12 | The versions of the hub services that are running | The behaviour in this folder was read from specific versions | [clearing-behaviour.md](clearing-behaviour.md#1-scope-and-reference-versions) |
| 13 | Lifetimes of the certificates the hub signs, and the contact and turnaround for signing and renewals | Your client certificate expires, and signing is a manual decision | [onboarding.md](onboarding.md#7-renewal-and-rotation) |
| 14 | For testing: the testing counterparty's participant id, its test identifiers and what each one returns, and the amounts and currency to use | The test cases need a counterparty that answers predictably | [register.md](register.md) |

## 2. What the hub operator does

| When | Action | How you know it is done |
|---|---|---|
| Before you start | Creates your DFSP in MCM and your Keycloak client. MCM creates the hub's client certificate request for you | You receive items 1 to 5 above. Your request appears under `GET /dfsps/{dfspId}/enrollments/outbound` |
| After you submit your client certificate request | Signs it in MCM. This is a deliberate decision and is not automatic | `GET …/enrollments/inbound/{enId}` shows `CERT_SIGNED` |
| After you register your callback URL | The hub registers your participant's callback endpoints | The hub confirms the callbacks on your participant in the finance portal |
| After signing | Registers your participant on the ledger with accounts in your currency and a net debit cap, then activates it and funds it | The hub confirms the participant is active, with its limit |
| Before lookups can reach you | Adds the oracle rule that routes your sub id to your DFSP | The hub confirms the sub id to use |
| During testing | Provides the ledger, quote and lookup records for each test transaction, matched by trace id | The records are attached to the test evidence |
| Before each certificate expires | Signs your renewal request | Your new certificate shows `CERT_SIGNED` |

## 3. Before you test

Do not start the test cases until all of these are true:

- Every row of `DI-ONB-*` in [register.md](register.md) passes.
- The hub has confirmed your callbacks, your participant's activation and your sub id.
- You hold the testing counterparty details (item 14).
