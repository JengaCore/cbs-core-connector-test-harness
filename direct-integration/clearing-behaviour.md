# Clearing behaviour

This document defines how a payment clears through the hub, and what a DFSP must send, accept and return at each step. It is written for the engineer building the integration. It gives, for every behaviour, the API path, the message schema and the field rules.

Onboarding (certificates, keys, MCM) is in [onboarding.md](onboarding.md).

## 1. Scope and reference versions

In scope: person-to-person (P2P) and person-to-business (P2B) payments over the hub's ISO 20022 API. Out of scope: FX, request to pay, bulk transfers and third-party initiation.

The hub's API is a merge of two definitions. Party lookup, quotes and transfers use ISO 20022 message structures. Every other resource keeps its FSPIOP format. This document covers the ISO resources.

The hub runs Mojaloop chart 17.2.0. The images that implement these behaviours are:

| Service | Version | Role |
|---|---|---|
| account-lookup-service | v17.15.2 | Party lookup |
| quoting-service | v17.14.4 | Quotes |
| ml-api-adapter | v16.9.2 | Transfers, notifications |
| central-ledger | v19.14.0 | Transfer validation, positions, expiry |

The rules below were read from these versions. Ask the hub operator to confirm the versions that are running.

## 2. How a payment clears

1. **Lookup.** The payer's DFSP asks the hub for a party by identifier type and value. The hub resolves the identifier to the payee DFSP and asks that DFSP. The payee DFSP returns the party's details.
2. **Quote.** The payer's DFSP asks the payee DFSP for terms. The payee returns the amount, its fee, an expiry and an ILPv4 packet. The packet carries the cryptographic condition that will lock the transfer.
3. **Prepare.** The payer's DFSP sends the transfer with the packet and an expiry. The hub's ledger validates it and reserves the payer's position. The hub sends the transfer to the payee DFSP.
4. **Fulfil.** The payee DFSP checks the packet and amount against the quote, makes the funds available and returns a fulfilment: a 32-byte value whose SHA-256 equals the condition. The ledger checks that match.
5. **Commit.** The ledger commits the positions. The payer's DFSP receives the result with the fulfilment. If the payee fulfilled with state `RESV`, the payee DFSP also receives a commit notice.
6. **Failure.** If any DFSP rejects, or the transfer expires, the hub aborts it and releases the reservation. The DFSPs are notified and must treat the payment as failed.

Settlement between the hub and the DFSPs is separate and later.

Every step is asynchronous. A request is acknowledged immediately and the answer arrives later as a separate call, to the endpoint the sender registered.

## 3. Conventions

### 3.1 Who calls whom

| Direction | Address |
|---|---|
| DFSP to hub | `https://fspiop.<switch domain>` plus the path, over mutual TLS with your client certificate |
| Hub to DFSP | Your registered callback URL plus the path, over mutual TLS with the hub's client certificate |

### 3.2 Asynchronous pattern

- A request (`GET`, `POST`) is answered with `202 Accepted` and no result.
- The result is a separate call: a `PUT` to the matching path, or a `PUT` to the path with `/error` appended.
- Callbacks (`PUT`, `PATCH`) are answered with `200 OK`.
- The hub waits **20 seconds** for a DFSP to accept a call it makes. Accept within seconds.

### 3.3 Headers

| Header | Required | Rule |
|---|---|---|
| `Content-Type` | Yes | `application/vnd.interoperability.iso20022.<resource>+json;version=2.0`. `<resource>` is `parties`, `quotes` or `transfers` |
| `Accept` | Yes | The same media type, on requests |
| `Date` | Yes | HTTP date of the call |
| `FSPIOP-Source` | Yes | The sender's DFSP id |
| `FSPIOP-Destination` | When known | The recipient's DFSP id |
| `FSPIOP-Signature` | Yes in practice | The JWS (see [section 7](#7-jws)). Optional in the specification, but the hub signs what it originates, and peers that validate signatures reject unsigned messages |
| `FSPIOP-URI` | With a signature | The path and query of the call |
| `FSPIOP-HTTP-Method` | With a signature | The method of the call |
| `Content-Length`, `X-Forwarded-For`, `FSPIOP-Encryption` | No | Optional |

A call with a missing or malformed required header is rejected.

### 3.4 Identifiers

In an ISO message the identifiers in the body (`TxId`, `EndToEndId`, `InstrId`) must be an uppercase ULID: 26 characters matching `^[0-9A-HJKMNP-TV-Z]{26}$`. The `{ID}` in a path is a correlation id: an uppercase ULID or a lowercase UUID (versions 1 to 5). Use the ULID for a quote or transfer so that the path id and the body id are the same value. Identifiers must be unique. Reusing a transfer id is treated as a repeat of the same transfer (see [section 10](#10-repeats-and-recovery)).

### 3.5 Message contents

Each message below links to the API viewer, where its real payload can be seen, and to its definition in the combined API. [field-reference.md](field-reference.md) lists every element of every message, with its type, whether it is required, its constraints and its meaning, and gives the fields the hub reads and how it reads them. Validate your messages against the OpenAPI schema before sending. The ISO messages also carry the DFSP ids in their bodies, and the hub maps them to the `FSPIOP-Source` and `FSPIOP-Destination` headers. Keep body and headers consistent.

## 4. Party lookup

### 4.1 Request

| | |
|---|---|
| Sent by | Payer DFSP, to the hub |
| Call | `GET /parties/{Type}/{ID}`, or `GET /parties/{Type}/{ID}/{SubId}` |
| Body | None |
| Answer | `202` |
| Payload | [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/parties/PartiesByTypeAndID) · [definition, line 699](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L699) (with sub id: [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/parties/PartiesSubIdByTypeAndID) · [definition, line 832](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L832)) |

`{Type}` is the identifier type (for example `MSISDN`, `ACCOUNT_ID`) and `{ID}` its value.

The hub uses a static oracle: customers are not registered in an account lookup. The sender names the destination DFSP in `{SubId}`, and the hub routes the lookup to that DFSP. The documented rule is that the sub id is the destination DFSP's id. A payer must therefore use the `…/{SubId}` form. Ask the hub operator which identifier types are enabled and which sub id value routes to your DFSP. The hub maps the sub id to a DFSP with an oracle rule that the hub operator adds.

### 4.2 Response

| | |
|---|---|
| Sent by | Payee DFSP, to the hub, after receiving the hub's `GET /parties/...` and answering `202` |
| Call | `PUT /parties/{Type}/{ID}` (or with `/{SubId}`) |
| Schema | `GetParties_IdentificationVerificationReportV03` |
| Answer | `200` |
| Payload | [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/parties/PartiesByTypeAndID2) · [definition, line 731](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L731) (with sub id: [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/parties/PartiesSubIdByTypeAndIDPut) · [definition, line 864](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L864)) |
| Fields | [every element](field-reference.md#put-partiestypeid) |

Rules:

- The sender, the payee DFSP, goes in `Assgnmt.Assgnr.Agt.FinInstnId.Othr.Id`. The recipient, the payer DFSP, goes in `Assgnmt.Assgne.Agt.FinInstnId.Othr.Id`. The hub reads them as `FSPIOP-Source` and `FSPIOP-Destination`.
- `Rpt.Vrfctn` is `true` when the party was found.
- The party's name is the single field `Rpt.UpdtdPtyAndAcctId.Pty.Nm`. The hub derives the display name and the first, middle and last names from it. The Testing Toolkit's bundled sample callbacks use `Name`, which does not match the hub's contract.
- The identifier is under `Pty.Id.PrvtId` for a person or `Pty.Id.OrgId` for a business. `Othr.Id` is its value and `Othr.SchmeNm.Prtry` its type.
- `Rpt.UpdtdPtyAndAcctId.Agt.FinInstnId.Othr.Id` is the payee DFSP id. `…ClrSysMmbId.MmbId` is the sub id. `Acct.Ccy` is the currency or currencies the party can receive.

### 4.3 Error

| | |
|---|---|
| Sent by | Payee DFSP, to the hub |
| Call | `PUT /parties/{Type}/{ID}/error` (or with `/{SubId}`) |
| Schema | `GetPartiesError_IdentificationVerificationReportV03` |
| Answer | `200` |
| Payload | [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/parties/PartiesErrorByTypeAndID) · [definition, line 769](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L769) (with sub id: [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/parties/PartiesSubIdErrorByTypeAndID) · [definition, line 902](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L902)) |
| Fields | [every element](field-reference.md#put-partiestypeiderror) |

`Rpt.Rsn.Cd` is the error code. `Assgnmt` carries the DFSP ids as in 4.2. Use `3204` when the party does not exist, and `3100` for an unsupported identifier type. The full list is in [section 8](#8-error-codes).

## 5. Quote

### 5.1 Request

| | |
|---|---|
| Sent by | Payer DFSP, to the hub. The hub forwards it to the payee DFSP, which answers `202` |
| Call | `POST /quotes` |
| Schema | `TermsRequest_FIToFICustomerCreditProposal` |
| Answer | `202` |
| Payload | [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/quotes/Quotes) · [definition, line 1134](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1134) |
| Fields | [every element](field-reference.md#post-quotes) |

Rules:

- `GrpHdr.PmtInstrXpryDtTm` is when the quote request expires.
- `CdtTrfTxInf.PmtId.TxId` is the quote id, `…EndToEndId` the transaction id and `…InstrId` the transaction request id if there is one. Each is an uppercase ULID (see [3.4](#34-identifiers)).
- `CdtTrfTxInf.IntrBkSttlmAmt` is the amount and currency.
- The payer is `CdtTrfTxInf.Dbtr` (identifier and name) and `CdtTrfTxInf.DbtrAgt` (DFSP). The payee is `CdtTrfTxInf.Cdtr` and `CdtTrfTxInf.CdtrAgt`. In each, the identifier is under `Id.PrvtId` (person) or `Id.OrgId` (business), the DFSP id is `FinInstnId.Othr.Id`, and the sub id is `FinInstnId.ClrSysMmbId.MmbId`.
- `CdtTrfTxInf.Purp.Prtry` is the transaction scenario.

### 5.2 Response

| | |
|---|---|
| Sent by | Payee DFSP, to the hub |
| Call | `PUT /quotes/{ID}` |
| Schema | `TermsResponse_FIToFICustomerCreditConfirmation` |
| Answer | `200` |
| Payload | [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/quotes/QuotesByID1) · [definition, line 1222](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1222) |
| Fields | [every element](field-reference.md#put-quotesid) |

Rules:

- `GrpHdr.PmtInstrXpryDtTm` is when the quote expires.
- `CdtTrfTxInf.IntrBkSttlmAmt` is the amount the payer's DFSP must transfer. `CdtTrfTxInf.InstdAmt` is the amount the payee receives. `CdtTrfTxInf.ChrgsInf.Amt` is the payee DFSP's fee.
- `CdtTrfTxInf.VrfctnOfTerms.IlpV4PrepPacket` is the ILPv4 packet (see [section 6](#6-ilp-packet-condition-and-fulfilment)). The hub takes the transfer condition from it. You do not send a separate condition.
- `CdtTrfTxInf.PmtId.TxId` is the quote id, echoed.
- The hub derives `FSPIOP-Source` and `FSPIOP-Destination` from `CdtTrfTxInf.Cdtr.Id.OrgId.Othr.Id` and `CdtTrfTxInf.Dbtr.Id.OrgId.Othr.Id`. Set the headers and these elements consistently.

### 5.3 Error

| | |
|---|---|
| Sent by | Payee DFSP, to the hub |
| Call | `PUT /quotes/{ID}/error` |
| Schema | `PacsError_FIToFIPaymentStatusReportV15` |
| Answer | `200` |
| Payload | [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/quotes/QuotesByIDAndError) · [definition, line 1261](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1261) |
| Fields | [every element](field-reference.md#put-quotesiderror) |

`TxInfAndSts.StsRsnInf.Rsn.Prtry` is the error code and `TxInfAndSts.StsRsnInf.AddtlInf` a description. Typical codes: `3100` invalid request, `3102` missing element, `5106` unsupported currency, `5200` limit exceeded, `5400` blocked party.

### 5.4 Quote lookup

`GET /quotes/{ID}` asks for a quote again ([API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/quotes/QuotesByID) · [definition, line 1192](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1192)). The hub forwards it to the payee DFSP, which answers `202` and sends the same `PUT /quotes/{ID}` as in 5.2.

### 5.5 Quote expiry

The hub stores a quote's expiry but does **not** enforce it. Every DFSP must enforce it. A payer must not start a transfer from an expired quote, and a payee should refuse a transfer that refers to one.

## 6. ILP packet, condition and fulfilment

The hub requires only this: the transfer carries a well-formed ILPv4 Prepare packet whose execution condition is a valid SHA-256 crypto-condition, and the fulfilment returned has a SHA-256 equal to that condition. How the payee derives the fulfilment is its own choice.

The reference library's algorithm ([sdk-standard-components](https://github.com/mojaloop/sdk-standard-components/tree/main/src/lib/ilp), `IlpV4.js`) is stateless, and is a safe model to port:

1. Build the transaction object from the quote: `quoteId`, `transactionId`, `transactionType`, `payee`, `payer`, `expiration`, `amount` (the transfer amount), and `note` if present. Serialise it with a stable key order and no whitespace.
2. `fulfilment = HMAC-SHA256(key = ASCII of base64(secret), data = ASCII of base64(serialised object))`, encoded base64url. It is 32 bytes.
3. `condition = SHA-256(fulfilment bytes)`, encoded base64url.
4. Build an ILPv4 Prepare packet with: `amount` = the transfer amount shifted by the currency's decimal places, as an integer string; `destination` = `g.mojaloop`; `expiresAt` = the transaction `expiration`; `executionCondition` = the condition bytes; `data` = base64url of the serialised object. Encode the packet base64url. This is `IlpV4PrepPacket`.
5. When the transfer arrives, decode the packet's `data`, recompute the fulfilment from your secret, and compare payer, payee, currency and amount with the transfer request. Reject a mismatch.

The secret must be the same across restarts and across all instances. A transfer quoted before a restart cannot be fulfilled with a different secret.

## 7. JWS

Every message you originate is signed, and you validate messages from others. The specification is [Signature v1.1](https://github.com/mojaloop/mojaloop-specification/blob/master/fspiop-api/documents/Signature_v1.1.md).

To sign:

1. The payload is the full HTTP body.
2. Build the protected header as JSON: `alg` (`RS256`; RS384 and RS512 are also allowed), `FSPIOP-URI` (the path and query), `FSPIOP-HTTP-Method`, `FSPIOP-Source`, `FSPIOP-Destination` (when known) and `Date`.
3. The signing input is `BASE64URL(protected header) + "." + BASE64URL(payload)`. Sign it with your RSA key (2048 bits or more).
4. Set the `FSPIOP-Signature` header to the JSON object `{"signature": "<BASE64URL signature>", "protectedHeader": "<BASE64URL protected header>"}`.

To validate: parse the header, decode the protected header, check `alg`, and check that `FSPIOP-URI`, `FSPIOP-HTTP-Method`, `FSPIOP-Source` and, if present, `FSPIOP-Destination` and `Date` equal the real request values. Then verify the signature with the sender's public key from MCM (`GET /dfsps/jwscerts`), looked up by `FSPIOP-Source`.

**Canonical body.** The reference library signs, and re-serialises when validating, the body in stable key order with no whitespace (`safe-stable-stringify`). A peer or the hub that uses the library recomputes the payload that way. Sign the same canonical serialisation you send, so that validation does not depend on how each side formats the JSON.

The hub signs the messages it originates. It does not validate the signatures on messages you send. A DFSP's signatures are therefore proven by the receiving DFSP, and in testing by the Testing Toolkit. Signing is still required.

## 8. Error codes

An error is returned as a `PUT …/error` with a code. The hub raises the `3xxx` codes. A payee DFSP raises the `5xxx` codes.

| Code | Name | Meaning |
|---|---|---|
| 3100 | Generic validation error | A message failed validation |
| 3101 | Malformed syntax | The message could not be parsed |
| 3102 | Missing mandatory element | A required element is missing |
| 3103 | Too many elements | |
| 3104 | Too large payload | |
| 3105 | Invalid signature | The JWS did not validate |
| 3106 | Modified request | A repeat of an earlier request with different content |
| 3107 | Missing mandatory extension | |
| 3204 | Party not found | The identifier does not resolve |
| 3302 | Quote expired | |
| 3303 | Transfer expired | |
| 5100 | Generic payee rejection | |
| 5101, 5103 | Payee rejected quote | |
| 5102 | Unsupported transaction type | |
| 5104, 5105 | Payee rejected transaction | |
| 5106 | Payee unsupported currency | |
| 5107 | Payee identifier no longer valid | |
| 5200 | Payee limit error | |
| 5300 | Payee permission error | |
| 5400 | Generic payee blocked error | |

Source: [`errors.js`](https://github.com/mojaloop/central-services-error-handling/blob/v13.1.6/src/errors.js).

## 9. Transfer

### 9.1 Request

| | |
|---|---|
| Sent by | Payer DFSP, to the hub. The hub forwards it to the payee DFSP, which answers `202` |
| Call | `POST /transfers` |
| Schema | `Execute_FIToFICustomerCreditTransferV13` |
| Answer | `202` |
| Payload | [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/transfers/transfers) · [definition, line 1473](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1473) |
| Fields | [every element](field-reference.md#post-transfers) |

Rules:

- `GrpHdr.PmtInstrXpryDtTm` is the transfer's expiry. It is required, and must be in the future.
- `CdtTrfTxInf.PmtId.TxId` is the transfer id. It is unique and an uppercase ULID.
- `CdtTrfTxInf.DbtrAgt.FinInstnId.Othr.Id` is the payer DFSP id. `CdtTrfTxInf.CdtrAgt.FinInstnId.Othr.Id` is the payee DFSP id.
- `CdtTrfTxInf.IntrBkSttlmAmt` is the currency and amount. It must equal the quote's transfer amount.
- `CdtTrfTxInf.VrfctnOfTerms.IlpV4PrepPacket` is the packet from the quote response.

The ledger rejects a transfer whose condition is missing or invalid, or whose expiry is missing or in the past.

### 9.2 Fulfil

| | |
|---|---|
| Sent by | Payee DFSP, to the hub |
| Call | `PUT /transfers/{ID}` |
| Schema | `PacsStatus_FIToFIPaymentStatusReportV15` |
| Answer | `200` |
| Payload | [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/transfers/TransfersByIDPut) · [definition, line 1603](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1603) |
| Fields | [every element](field-reference.md#put-transfersid) |

Rules:

- `TxInfAndSts.ExctnConf` is the fulfilment.
- `TxInfAndSts.TxSts` is the state: `COMM` (committed) or `RESV` (reserved). With `RESV` the hub commits and sends the payee a commit notice.
- `TxInfAndSts.PrcgDt.DtTm` is the time of completion.
- `SHA-256(fulfilment)` must equal the transfer's condition.
- `PrcgDt.DtTm` must not be more than 200 milliseconds in the future, and not more than 300 seconds in the past. Otherwise the hub rejects it with `3100`. Keep your clock synchronised.

The ISO states map as `COMM` committed, `RESV` reserved, `RECV` received and `ABOR` aborted.

### 9.3 Commit notice

| | |
|---|---|
| Sent by | The hub, to the payee DFSP, when it fulfilled with `RESV` |
| Call | `PATCH /transfers/{ID}` |
| Schema | `PacsStatus_FIToFIPaymentStatusReportV15`, with `TxSts` `COMM`, `PrcgDt.DtTm`, and no fulfilment |
| Answer | `200` |
| Payload | [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/transfers/TransfersByIDPatch) · [definition, line 1563](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1563) |
| Fields | [every element](field-reference.md#patch-transfersid) |

The payee DFSP finalises the credit when it receives this.

### 9.4 Result to the payer

| | |
|---|---|
| Sent by | The hub, to the payer DFSP |
| Call | `PUT /transfers/{ID}` |
| Schema | `PacsStatus_FIToFIPaymentStatusReportV15`, with the fulfilment, `TxSts` and `PrcgDt.DtTm` |
| Payload | As 9.2 |

The payer DFSP finalises the debit. It should also check the fulfilment against the condition it sent.

### 9.5 Rejection and failure

| Event | Call | Who receives it |
|---|---|---|
| The payee rejects the transfer | `PUT /transfers/{ID}/error` from the payee to the hub. Schema `PacsError_FIToFIPaymentStatusReportV15`: `StsRsnInf.Rsn.Prtry` is the code ([API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/transfers/TransfersByIDAndError) · [definition, line 1642](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1642) · [every element](field-reference.md#put-transfersiderror)) | The hub aborts. The payer DFSP receives `PUT /transfers/{ID}/error` |
| The transfer expires | The hub's timeout handler aborts it. It runs every 15 seconds. It sends `PUT /transfers/{ID}/error` with code `3303` (transfer expired) | If the payee had not yet fulfilled, the payer DFSP only. If the payee had already fulfilled with `RESV`, both the payer and the payee DFSPs. Treat the transfer as failed and release funds |

### 9.6 Status

The payer DFSP can ask for a transfer's state with `GET /transfers/{ID}` to the hub ([API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022#/transfers/TransfersByIDGet) · [definition, line 1532](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1532)). The hub answers `202` and then sends `PUT /transfers/{ID}` with the state. The hub answers from its ledger. The payee DFSP is not asked.

## 10. Repeats and recovery

How the hub treats a repeated transfer request:

| Repeat | Result |
|---|---|
| Same transfer id, same content, transfer already finished (committed, aborted or reserved) | The hub sends the result again |
| Same transfer id, same content, still in progress | Ignored |
| Same transfer id, different content | Error `3106` |

For DFSPs:

- Record a payment by your own id before you send it. After an error or timeout, ask the hub for the transfer's state with `GET /transfers/{ID}` before you retry or refund. A payment can be reported failed and still be committed.
- Resend only with the same transfer id and the same content.
- Never refund a payment the hub reports as committed.
- As payee, a repeated `POST /transfers` for a transfer you already handled must not credit twice.

## 11. Resources in FSPIOP format

The combined API keeps every resource that has no ISO 20022 representation in its FSPIOP format. Their payloads can be seen in the [FSPIOP API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0). Their definitions in the combined API are:

| Resource | Paths | Definition |
|---|---|---|
| Participants (oracle registration) | `/participants`, `/participants/{Type}/{ID}`, `/participants/{Type}/{ID}/{SubId}` | [line 589](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L589) |
| Transaction requests | `/transactionRequests`, `/transactionRequests/{ID}` | [line 952](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L952) |
| Authorizations | `/authorizations/{ID}` | [line 1310](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1310) |
| Transactions | `/transactions/{ID}` | [line 1691](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1691) |
| Bulk quotes | `/bulkQuotes`, `/bulkQuotes/{ID}` | [line 1821](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1821) |
| Bulk transfers | `/bulkTransfers`, `/bulkTransfers/{ID}` | [line 1999](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L1999) |
| FX service discovery | `/services/FXP`, `/services/FXP/{SourceCurrency}/{TargetCurrency}` | [line 2576](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L2576) |
| Ping and interface | `/ping`, `/interface` | [line 37](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml#L37) |

In ISO mode the hub applies the ISO content-type pattern to `participants` as well: Mojaloop's own hub test collection sends `application/vnd.interoperability.iso20022.participants+json;version=2.0`. None of the flows in this document uses these resources. The hub's oracle is static, so a DFSP does not register customers with `/participants`. Transaction requests, authorizations, transactions, bulk and FX service discovery are out of scope. `/ping` and `/interface` are in the combined API definition, but they are not in the contracts of the hub's lookup, quoting and transfer services.

## 12. To confirm with the hub operator

These could not be settled from the source and must be confirmed before go-live:

- Which of `COMM` or `RESV` the hub prefers for the fulfil.
- How the ISO quote expresses whether the amount is a send amount or a receive amount.
- Which identifier types are enabled and how they route to your DFSP.
- The versions of the hub services that are running.

## 13. Sources

- Every element of every message, generated from the API definition: [field-reference.md](field-reference.md)
- ISO 20022 payloads in the [API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0_ISO20022); FSPIOP payloads in the [FSPIOP API viewer](https://mojaloop.github.io/api-snippets/?urls.primaryName=v2.0)
- The combined API definition: [api_spec.yaml](https://github.com/JengaCore/cbs-core-connector-test-harness/blob/932dd41cca79c385ef5ab00caef1977edf1f46e8/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml)
- Hub ISO contracts: [parties](https://github.com/mojaloop/account-lookup-service/blob/v17.15.2/src/interface/api-swagger-iso20022-parties.yaml), [quotes](https://github.com/mojaloop/quoting-service/blob/v17.14.4/src/interface/QuotingService-swagger_iso20022.yaml), [transfers](https://github.com/mojaloop/ml-api-adapter/blob/v16.9.2/src/interface/api-swagger-iso20022-transfers.yaml)
- Field mapping: [discovery](https://github.com/mojaloop/ml-schema-transformer-lib/blob/v2.9.0/src/mappings/fspiopiso20022/discovery.ts), [quotes](https://github.com/mojaloop/ml-schema-transformer-lib/blob/v2.9.0/src/mappings/fspiopiso20022/quotes.ts), [transfers](https://github.com/mojaloop/ml-schema-transformer-lib/blob/v2.9.0/src/mappings/fspiopiso20022/transfers.ts)
- Ledger validation: [`validator.js`](https://github.com/mojaloop/central-ledger/blob/v19.14.0/src/handlers/transfers/validator.js), duplicates in [`prepare.js`](https://github.com/mojaloop/central-ledger/blob/v19.14.0/src/handlers/transfers/prepare.js)
- Fulfil timing: [`validator.js`](https://github.com/mojaloop/ml-api-adapter/blob/v16.9.2/src/lib/validator.js); commit notice: [`notification/index.js`](https://github.com/mojaloop/ml-api-adapter/blob/v16.9.2/src/handlers/notification/index.js)
- Generic transaction patterns: [Generic-Transaction-Patterns.md](https://github.com/mojaloop/mojaloop-specification/blob/master/fspiop-api/documents/Generic-Transaction-Patterns.md)
