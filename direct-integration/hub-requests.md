# Hub hand-over sheet

A DFSP that integrates directly depends on the hub operator for some values and some actions. The hub operator fills in this sheet once for each environment and sends it to the DFSP. The DFSP does not have to ask for anything item by item.

Secrets (the client secret in particular) must be sent over a secure channel and never by chat, email or ticket.

Repeat everything for each environment. A DFSP is onboarded on the test environment first and on production after, with its own client, certificates and records in each.

## 1. What the hub operator sends

| # | Value | Where the hub operator reads it | Used in |
|---|---|---|---|
| 1 | Your DFSP id | Chosen when the DFSP is created in MCM. It is permanent and case-sensitive. It is the path of every MCM call and the `FSPIOP-Source` of every message | [onboarding.md](onboarding.md) |
| 2 | Your settlement currency | The currency of the participant on the hub's ledger. The hub only settles currencies it has accounts for | [clearing-behaviour.md](clearing-behaviour.md) |
| 3 | Your Keycloak client id and client secret | Keycloak, realm for DFSPs, client named by your DFSP id, Credentials tab. The client id is your DFSP id | [onboarding.md](onboarding.md#4-authenticating-to-mcm) |
| 4 | The token URL | `https://keycloak.<domain>/realms/<realm>/protocol/openid-connect/token`. The realm for DFSPs is named `dfsps` unless the hub operator changed it | [onboarding.md](onboarding.md#4-authenticating-to-mcm) |
| 5 | The MCM API address for DFSPs | `https://mcm.<domain>/pm4mlapi` | [onboarding.md](onboarding.md#5-the-steps) |
| 6 | The FSPIOP address | `https://fspiop.<domain>` | [clearing-behaviour.md](clearing-behaviour.md#31-who-calls-whom) |
| 7 | The API type of the environment | The `api_type` setting of the hub environment: `iso20022` or `fspiop`. The default is `fspiop`. **The documents in this folder apply only when it is `iso20022`.** Every DFSP on an environment must use the same API type, and with `iso20022` the ILP version is 4 | [clearing-behaviour.md](clearing-behaviour.md#1-scope-and-reference-versions) |
| 8 | The identifier types enabled, and the sub id that routes lookups to your DFSP | The hub's oracle settings and `GET /oracles` on the account lookup service, and the static oracle's rules. The sub id is a key in those rules that maps to your DFSP id. It is chosen by the hub operator and is not always your DFSP id | [clearing-behaviour.md](clearing-behaviour.md#41-request) |
| 9 | The versions of the hub services that are running | The installed releases of the hub. Needed only so that the evidence names them | [clearing-behaviour.md](clearing-behaviour.md#1-scope-and-reference-versions) |
| 10 | The turnaround for signing your client certificate and for renewals, and the contact | A commitment by the hub operator. The lifetime of the certificate itself is read from the signed certificate | [onboarding.md](onboarding.md#7-renewal-and-rotation) |
| 11 | For testing: the testing counterparty's participant id, its test identifiers and what each one returns, and the amounts and currency to use | The Testing Toolkit participant the hub operator set up | [register.md](register.md) |

## 2. What the DFSP gives the hub operator

| Value | Why | Where it goes |
|---|---|---|
| The currency you will use | The hub creates your accounts in it | Item 2 above |
| Your egress addresses: the public addresses your calls to the switch come from. At least one | The hub's onboarding builds its allow-list from them and fails when there is none | You register them yourself, in [onboarding.md](onboarding.md#step-5-callback-url-and-egress-addresses) |
| Your callback URL | The hub registers your callback endpoints from it | You register it yourself, in the same step |
| A contact for signing and renewals | The hub operator signs your client certificate by hand | Item 10 above |

## 3. What you do not need to ask for

These are public or you can read them yourself, so they are not on the sheet.

| Value | How you get it |
|---|---|
| The hub's CA | `GET /hub/ca` |
| The hub's JWS public key | `GET /dfsps/jwscerts`. The hub's own key is in the list as the entry `Hub`. The hub signs what it originates with it. Check that the entry is present, as in [onboarding.md](onboarding.md#step-10-trust-material) |
| The other participants' JWS keys | `GET /dfsps/jwscerts` |
| The minimum key length | Use 4096. It is accepted whichever minimum the hub sets |
| The lifetime of your client certificate | Read `notAfter` on the certificate once the hub has signed it |
| The name the hub uses as `FSPIOP-Source` | It is the id of the `Hub` entry above |

## 4. What the hub operator does

| When | Action | How you know it is done |
|---|---|---|
| Before you start | Creates your DFSP in MCM and your Keycloak client. MCM creates the hub's client certificate request for you | You receive items 1 to 6 above. Your request appears under `GET /dfsps/{dfspId}/enrollments/outbound` |
| After you submit your client certificate request | Signs it in MCM. This is a deliberate decision and is not automatic | `GET …/enrollments/inbound/{enId}` shows `CERT_SIGNED` |
| After you register your callback URL and egress addresses | The hub registers your participant's callback endpoints and its allow-list | The hub confirms the callbacks on your participant in the finance portal |
| After signing | Registers your participant on the ledger with accounts in your currency and a net debit cap, then activates it and funds it | The hub confirms the participant is active, with its limit |
| Before lookups can reach you | Adds the static oracle rule that maps a sub id to your DFSP id | The hub confirms the sub id to use (item 8) |
| During testing | Provides the ledger, quote and lookup records for each test transaction, matched by trace id | The records are attached to the test evidence |
| Before each certificate expires | Signs your renewal request | Your new certificate shows `CERT_SIGNED` |

## 5. Before you test

Do not start the test cases until all of these are true:

- Every row of `DI-ONB-*` in [register.md](register.md) passes.
- The hub has confirmed your callbacks, your participant's activation and your sub id.
- You hold the testing counterparty details (item 11).
- The API type (item 7) is `iso20022`.
