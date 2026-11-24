# Test register for direct integrations

This register lists every behaviour a directly integrated DFSP must show before it goes live, how each is checked, and what evidence is kept. The behaviour itself is defined in [onboarding.md](onboarding.md) and [clearing-behaviour.md](clearing-behaviour.md). The register does not repeat it.

A case passes when its expected result is shown and the evidence in [evidence/evidence-pack.md](evidence/evidence-pack.md) is recorded.

## Methods

| Method | What it is |
|---|---|
| Script | A read-only check of MCM, and of the callback host, run by [onboarding-checks/check-onboarding.sh](onboarding-checks/check-onboarding.sh) |
| TTK | A case in the Mojaloop Testing Toolkit, which acts as the other participant through the hub. The collections are in [ttk](ttk) |
| Hub check | The hub operator confirms from the hub's own records |
| Evidence | The DFSP supplies a log extract or screenshot, or shows its own test result |

For every payment case the hub operator also supplies the hub's record of the transfer (ledger state, quote or lookup record, trace id). The DFSP's own records are not enough.

**Status.** The scripts and Testing Toolkit collections exist and have been tested against mocks and against a Toolkit playing the DFSP. They have not yet been run against a real hub or a real DFSP. Rows whose method is TTK or Script and that are marked "not automated" are carried out by the hub operator following the behaviour documents. [ttk/README.md](ttk/README.md) and [onboarding-checks/README.md](onboarding-checks/README.md) say what was tested.

The column "Docs site case" gives the related case in the Payment Manager test register on the documentation site, where there is one.

## Onboarding

| ID | Case | Expected result | Method | Behaviour |
|---|---|---|---|---|
| DI-ONB-01 | Token obtained | The token endpoint returns an access token for the DFSP client, and MCM accepts it | Script | [onboarding §4](onboarding.md#4-authenticating-to-mcm) |
| DI-ONB-02 | DFSP CA registered | `GET /dfsps/{id}/ca` returns the root, `validationState` is `VALID` | Script | [§5 step 2](onboarding.md#step-2-dfsp-ca) |
| DI-ONB-03 | Server certificate registered | `GET /dfsps/{id}/servercerts` is `VALID`, issued by the DFSP CA, and names the callback host | Script | [§5 step 3](onboarding.md#step-3-server-certificate) |
| DI-ONB-04 | JWS key registered | The DFSP's public key appears in `GET /dfsps/jwscerts` | Script | [§5 step 4](onboarding.md#step-4-jws-public-key) |
| DI-ONB-05 | Callback URL registered | The ingress endpoint URL is present for the DFSP | Script | [§5 step 5](onboarding.md#step-5-callback-url) |
| DI-ONB-06 | Hub request signed by the DFSP CA | The outbound enrollment is `CERT_SIGNED`, its validations pass, and its issuer is the DFSP CA | Script | [§5 step 6](onboarding.md#step-6-sign-the-hubs-request) |
| DI-ONB-07 | DFSP request accepted | The inbound enrollment exists and is not `INVALID`: RSA key of the required length, valid signature | Script | [§5 steps 7 to 9](onboarding.md#step-7-to-9-your-client-certificate) |
| DI-ONB-08 | DFSP certificate signed | The inbound enrollment is `CERT_SIGNED` and carries the certificate | Script | [§5 steps 7 to 9](onboarding.md#step-7-to-9-your-client-certificate) |
| DI-ONB-09 | Trust material held | The DFSP shows the hub CA fingerprint it holds equals `GET /hub/ca`, and it holds the participants' JWS keys | Evidence | [§5 step 10](onboarding.md#step-10-trust-material) |
| DI-ONB-10 | Participant ready | The hub confirms the callbacks, the participant's activation and the sub id | Hub check | [onboarding §6](onboarding.md#6-after-the-hub-signs) |
| DI-ONB-11 | Renewal rehearsed | A new client certificate request is sent, signed by the hub and installed with no payment lost. Done on the test environment | Evidence | [onboarding §7](onboarding.md#7-renewal-and-rotation) |

## Security

| ID | Case | Expected result | Method | Behaviour |
|---|---|---|---|---|
| DI-SEC-01 | Hub reaches the callback host | A message from the hub arrives over mutual TLS using the hub's client certificate. It is shown by DI-INC-01 passing | TTK | [clearing §3.1](clearing-behaviour.md#31-who-calls-whom) |
| DI-SEC-02 | Callback host refuses an unauthenticated client | A TLS client with no certificate, or one not signed by the DFSP CA, is refused in the handshake | Script | [onboarding §6](onboarding.md#6-after-the-hub-signs) |
| DI-SEC-03 | Callback certificate is correct | The server certificate chains to the DFSP CA and names the callback host | Script | [onboarding §3](onboarding.md#3-keys-and-certificates-to-create) |
| DI-SEC-04 | Switch requires the client certificate | A call to the switch FSPIOP host with the DFSP's certificate succeeds. One without it is refused in the handshake | Script | [onboarding §5](onboarding.md#5-the-steps) |
| DI-SEC-05 | DFSP messages are signed | Every message the DFSP sends carries a signature that validates with the DFSP's key from MCM. Checked in every TTK case when `DFSP_JWS_PUBLIC_KEY` is set | TTK | [clearing §7](clearing-behaviour.md#7-jws) |
| DI-SEC-06 | Protected header is correct | `alg` is `RS256`, and `FSPIOP-URI`, `FSPIOP-HTTP-Method`, `FSPIOP-Source`, `FSPIOP-Destination` and `Date` equal the real values. Checked in every TTK case when `DFSP_JWS_PUBLIC_KEY` is set | TTK | [clearing §7](clearing-behaviour.md#7-jws) |
| DI-SEC-07 | Invalid signature rejected | A message signed with the wrong key is rejected with `3105` and not processed. Not automated: the DFSP shows its own test result | Evidence | [clearing §7](clearing-behaviour.md#7-jws) |
| DI-SEC-08 | Hub signature accepted | A message the hub originated, such as the commit notice or an expiry error, is validated against the hub's key and processed. The hub confirms delivery, and the DFSP shows it was processed | Hub check | [clearing §7](clearing-behaviour.md#7-jws) |

## Incoming payments (the DFSP is the payee)

TTK is the payer. The messages are ISO 20022. "Case" is the TTK case in [ttk/collections/di-inc.json](ttk/collections/di-inc.json).

| ID | Case | Expected result | Method | Docs site case | Behaviour |
|---|---|---|---|---|---|
| DI-INC-01 | Successful lookup | `202`, then `PUT /parties` with name, identifier, type, DFSP id and currencies, the ISO content type, and a valid signature | TTK | INC-01 | [clearing §4](clearing-behaviour.md#4-party-lookup) |
| DI-INC-02 | Unsupported identifier type | Error callback `3100`, no party data | TTK | INC-02 | [clearing §4.3](clearing-behaviour.md#43-error) |
| DI-INC-03 | Party not found | Error callback `3204` | TTK | INC-03 | [clearing §4.3](clearing-behaviour.md#43-error) |
| DI-INC-04 | Successful quote | `202`, then `PUT /quotes/{id}` with the amount, expiry and an `IlpV4PrepPacket` that is a well-formed, unexpired ILPv4 packet with a 32-byte condition | TTK | INC-04 | [clearing §5](clearing-behaviour.md#5-quote) |
| DI-INC-05 | Quote with missing fields | The DFSP rejects a quote request with required elements missing. The hub validates structure first, so the request cannot reach the DFSP through the hub. The DFSP shows its own test result | Evidence | INC-05 | [clearing §5.3](clearing-behaviour.md#53-error) |
| DI-INC-06 | Quote in an unsupported currency | Error callback `5106` | TTK | INC-07 | [clearing §5.3](clearing-behaviour.md#53-error) |
| DI-INC-07 | Quote above the DFSP's limit | Error callback `5200` | TTK | INC-15 | [clearing §5.3](clearing-behaviour.md#53-error) |
| DI-INC-08 | Quote for a blocked account | A payee error callback (`5xxx`) | TTK | INC-08 | [clearing §5.3](clearing-behaviour.md#53-error) |
| DI-INC-09 | Quote lookup | `GET /quotes/{id}` is answered with `202`, then `PUT /quotes/{id}` with a well-formed ILP packet and the quote id | TTK | | [clearing §5.4](clearing-behaviour.md#54-quote-lookup) |
| DI-INC-10 | Successful transfer | `202`, funds reserved, then `PUT /transfers/{id}` with a fulfilment whose SHA-256 equals the condition, a state of `COMM` or `RESV`, and a completion time within 200 ms ahead and 300 s behind. The hub's ledger shows the credit once | TTK | INC-09 | [clearing §9](clearing-behaviour.md#9-transfer) |
| DI-INC-11 | Commit notice | When the DFSP fulfilled with `RESV`, `PATCH /transfers/{id}` is answered `200` and the credit is finalised. The hub confirms delivery and the DFSP shows the credit finalised | Hub check | | [clearing §9.3](clearing-behaviour.md#93-commit-notice) |
| DI-INC-12 | Transfer that differs from its quote | A transfer whose amount differs from the amount in its quote's packet is rejected with an error callback, with no fulfilment and no credit | TTK | INC-10, INC-11 | [clearing §9.5](clearing-behaviour.md#95-rejection-and-failure) |
| DI-INC-13 | Transfer aborted or expired | The reservation is released and the case is flagged for reconciliation. The hub supplies the expiry or abort record, and the DFSP shows the release | Evidence | INC-12, INC-16 | [clearing §9.5](clearing-behaviour.md#95-rejection-and-failure) |
| DI-INC-14 | Repeated transfer | A repeated `POST /transfers` the DFSP receives, for a transfer it already handled, credits once. The hub answers repeats of identical requests itself, so the DFSP shows its own test result | Evidence | INC-18 | [clearing §10](clearing-behaviour.md#10-repeats-and-recovery) |
| DI-INC-15 | Malformed request | A request missing or with wrong `Accept`, `Content-Type`, `Date` or `FSPIOP-Source` is rejected and not processed. The hub validates first, so the DFSP shows its own test result | Evidence | | [clearing §3.3](clearing-behaviour.md#33-headers) |
| DI-INC-16 | Core system timeout | A lookup or quote that cannot be answered ends with a clean payee error, with no request left hanging | Evidence | INC-19 | [clearing §3.2](clearing-behaviour.md#32-asynchronous-pattern) |

## Outgoing payments (the DFSP is the payer)

The DFSP starts each payment from its own system. TTK is the payee. It waits for what the DFSP sends, validates it, and answers through its callback rules. P2P and P2B use the same cases, with a business party for P2B. The TTK cases are in [ttk/collections/di-out.json](ttk/collections/di-out.json).

| ID | Case | Expected result | Method | Docs site case | Behaviour |
|---|---|---|---|---|---|
| DI-OUT-01 | Lookup is well formed | `GET /parties/{Type}/{ID}/{SubId}` with the required headers, the sub id the hub gave, and a valid signature. TTK answers, and the DFSP handles the callback | TTK | OUT-P2P-01 | [clearing §4.1](clearing-behaviour.md#41-request) |
| DI-OUT-02 | Lookup fails | After error `3204` the DFSP sends no quote | TTK | OUT-A04 | [clearing §4.3](clearing-behaviour.md#43-error) |
| DI-OUT-03 | Quote is well formed | `POST /quotes` with unique ULID ids, the amount and currency, payer and payee DFSPs and identifiers, and a future expiry | TTK | OUT-P2P-01 | [clearing §5.1](clearing-behaviour.md#51-request) |
| DI-OUT-04 | Transfer follows an accepted quote | `POST /transfers` carries a well-formed ILPv4 packet, the quote's amount and currency, a future expiry, a unique ULID transfer id and the payer and payee DFSPs | TTK | OUT-P2P-04 | [clearing §9.1](clearing-behaviour.md#91-request) |
| DI-OUT-05 | Bad quote refused | Wrong arithmetic, an unsupported currency or an expired quote: no transfer is sent. The DFSP shows its own test result | Evidence | OUT-P2P-05 | [clearing §5.5](clearing-behaviour.md#55-quote-expiry) |
| DI-OUT-06 | Successful completion | The DFSP receives the result, checks the fulfilment against its condition, and finalises the debit once. The hub supplies the ledger state and the DFSP shows the debit | Evidence | OUT-P2P-02 | [clearing §9.4](clearing-behaviour.md#94-result-to-the-payer) |
| DI-OUT-07 | Payee rejects | After `PUT /transfers/{id}/error` the customer is refunded | Evidence | OUT-P2P-07 | [clearing §9.5](clearing-behaviour.md#95-rejection-and-failure) |
| DI-OUT-08 | No answer before expiry | The DFSP asks `GET /transfers/{id}` before refunding. A transfer the hub reports as committed is never refunded | Evidence | OUT-A06 | [clearing §10](clearing-behaviour.md#10-repeats-and-recovery) |
| DI-OUT-09 | Expiry notice | After `PUT /transfers/{id}/error` with `3303` the DFSP releases the funds | Evidence | OUT-P2P-06 | [clearing §9.5](clearing-behaviour.md#95-rejection-and-failure) |
| DI-OUT-10 | Status query | `GET /transfers/{id}` is sent correctly, and the DFSP handles `COMM`, `RESV`, `RECV` and `ABOR` | Evidence | OUT-P2P-08 | [clearing §9.6](clearing-behaviour.md#96-status) |
| DI-OUT-11 | No blind resend | A retry reuses the same transfer id and content and creates no second transfer | Evidence | OUT-A07 | [clearing §10](clearing-behaviour.md#10-repeats-and-recovery) |
| DI-OUT-12 | Refund failure is visible | If a refund fails, a manual refund item is raised and visible to operations | Evidence | OUT-A03 | [clearing §10](clearing-behaviour.md#10-repeats-and-recovery) |

## Completion

The register is complete for an environment when every in-scope case has a result of Pass with evidence, the hub's records match the results, and no defect is open. Record it in the [evidence pack](evidence/evidence-pack.md).
