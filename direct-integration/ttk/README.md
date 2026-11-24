# Testing Toolkit collections

Collections for the [Mojaloop Testing Toolkit](https://github.com/mojaloop/ml-testing-toolkit) (TTK) that test a directly integrated DFSP through the hub. They cover the cases marked TTK in [../register.md](../register.md).

The Toolkit runs in the hub operator's environment, as a participant on the hub. The DFSP installs nothing.

## How the cases work

```
DFSP under test  <--->  hub  <--->  Testing Toolkit (a participant, for example ttkdfsp)
```

- **Incoming payments** (`collections/di-inc.json`). The Toolkit is the payer. It sends the lookup, quote and transfer to the hub, addressed to the DFSP, and checks what the DFSP answers.
- **Outgoing payments** (`collections/di-out.json`). The Toolkit is the payee. It waits for the messages the DFSP sends, checks each one, and answers as the payee through its callback rules. A person or the DFSP's system starts the payment while the case waits.

## What the hub operator sets up

1. A participant for the Toolkit on the hub, with its own FSPIOP endpoints, and the Toolkit's JWS public key in MCM.
2. The Toolkit's callback endpoint set to the hub's FSPIOP address, with the certificates the hub requires.
3. The Toolkit reachable by the hub at its participant callback address.
4. The files in [rules](rules) loaded as the Toolkit's callback and validation rules, with the identifiers in them replaced by the real test identifiers (see [Rules](#rules)).
5. A static oracle rule that routes the test identifiers to the DFSP under test.

## Environment

Copy [environments/direct-integration.json](environments/direct-integration.json) and replace every `<...>`.

| Value | Meaning |
|---|---|
| `HUB_FSPIOP_URL` | The hub's FSPIOP address |
| `TTK_SELF_URL` | The Toolkit's own inbound address. The outgoing cases use it |
| `DFSP_ID` | The DFSP id under test |
| `TTK_FSP_ID` | The Toolkit's participant id |
| `CURRENCY`, `AMOUNT` | The currency and amount of test payments |
| `LOOKUP_ID_TYPE` | The identifier type used (for example `MSISDN`) |
| `PAYEE_ID`, `PAYEE_NAME` | An existing customer at the DFSP |
| `PAYER_ID`, `PAYER_NAME` | A customer at the testing counterparty |
| `UNSUPPORTED_ID_TYPE` | An identifier type the DFSP does not support |
| `UNKNOWN_ID` | An identifier that does not exist at the DFSP |
| `UNSUPPORTED_CURRENCY` | A currency the hub supports and the DFSP does not |
| `OVER_LIMIT_AMOUNT` | An amount above the DFSP's limit |
| `BLOCKED_ID` | An identifier of a blocked account at the DFSP |
| `MISMATCH_AMOUNT` | An amount different from `AMOUNT` |
| `OUT_WAIT_MS` | How long an outgoing case waits for the DFSP's message |
| `OUT_QUIET_MS` | How long a case waits to see that the DFSP sends nothing |
| `DFSP_JWS_PUBLIC_KEY` | The DFSP's JWS public key, PEM, from MCM. When set, signatures are checked. When empty, those checks are skipped |

## Running

With the Toolkit client (`npm install -g @mojaloop/ml-testing-toolkit-client-lib`), against the Toolkit's API:

```sh
ml-ttk-cli -m outbound -u https://<toolkit api address> \
  -i collections/di-inc.json -e environments/direct-integration.json \
  --report-format html --report-target file://incoming.html

ml-ttk-cli -m outbound -u https://<toolkit api address> \
  -i collections/di-out.json -e environments/direct-integration.json \
  --report-format html --report-target file://outgoing.html
```

Run the incoming cases before the outgoing cases. The collections can also be imported in the Toolkit's web interface.

### Outgoing cases

Start `di-out.json`, then start the payments from the DFSP's system when the case is waiting.

| Case | The DFSP must |
|---|---|
| `DI-OUT-01, 03 and 04` | Make one payment from its system to `PAYEE_ID` at the testing counterparty, for `AMOUNT` in `CURRENCY`: lookup, quote and transfer |
| `DI-OUT-02` | Start a payment to `UNKNOWN_ID`. The Toolkit answers that the party is not found. The case passes if no quote follows within `OUT_QUIET_MS` |

Each wait ends after `OUT_WAIT_MS`, and the case fails if the message did not arrive. A Toolkit test case needs a request to run its scripts and assertions, so each wait is carried by a lookup that the Toolkit sends to itself (`TTK_SELF_URL`, identifier `ttk-wait`). The callback rules give that request no callback.

## Cases

| Case | Register | Checks |
|---|---|---|
| `DI-INC-01` | DI-INC-01 | Lookup answered, with headers, party, currency, DFSP and assignment |
| `DI-INC-02` | DI-INC-02 | Unsupported identifier type: error `3100`, no party |
| `DI-INC-03` | DI-INC-03 | Party not found: error `3204`, no party |
| `DI-INC-04` | DI-INC-04 | Quote answered, with amount, expiry and a well-formed unexpired ILPv4 packet |
| `DI-INC-06` | DI-INC-06 | Unsupported currency: error `5106` |
| `DI-INC-07` | DI-INC-07 | Above the limit: error `5200` |
| `DI-INC-08` | DI-INC-08 | Blocked account: a `5xxx` payee error |
| `DI-INC-09` | DI-INC-09 | Quote lookup answered with the quote |
| `DI-INC-10` | DI-INC-10 | Transfer fulfilled: state, fulfilment hashes to the condition, completion time within the hub's window |
| `DI-INC-12` | DI-INC-12 | A transfer that differs from its quote gets an error and no fulfilment |
| `DI-OUT-01, 03, 04` | DI-OUT-01, 03, 04 | The DFSP's lookup, quote and transfer are well formed |
| `DI-OUT-02` | DI-OUT-02 | No quote follows a failed lookup |

When `DFSP_JWS_PUBLIC_KEY` is set, every case also checks that the DFSP's signature validates and that its protected header is complete (DI-SEC-05, DI-SEC-06).

## Rules

The Toolkit answers the DFSP's outgoing messages with the rules in [rules](rules):

- `counterparty-callback-rules.json` gives success answers: lookup, quote (the Toolkit builds the ILP packet and the fulfilment itself), quote lookup and transfer.
- `counterparty-validation-rules.json` gives error answers, chosen by a value in the request.

The values the rules react to are those in [selftest/incoming.env.json](selftest/incoming.env.json): `UNKNOWN_ID` `9999999999` (error `3204`), type `ALIAS` (`3100`), currency `EUR` (`5106`), amount `999999999` (`5200`), payee `2200000099` (`5400`), and a transfer amount of `7` (error). Currency `XTS` is used in answers. Replace these values in the rules with the real test values before using them on a hub.

## Self-test

[selftest/run.sh](selftest/run.sh) starts a Toolkit that plays the DFSP, runs both collections against it, and removes everything it started. It proves that the collections and their assertions work. It does not test a DFSP.

```sh
selftest/run.sh
```

It needs Docker and takes about two minutes. It uses `docker cp` only, so it works with a remote Docker daemon. Reports are written to `selftest/reports`.

What it covered when written: both collections pass (98 of 98 incoming assertions and 31 of 31 outgoing). The assertions were also seen to fail when the answer was wrong: a fulfilment that did not hash to the condition, a missing callback, and a callback with the wrong source and destination.

## Limits

- The collections have been run against a Toolkit playing the DFSP, not yet against a real hub. The first run on the hub may need small adjustments to the environment values and rules.
- The signature checks were tested on the library functions the Toolkit uses (valid key, wrong key, altered body). They have not yet seen a real DFSP's signatures.
- Cases the register marks Evidence are not automated. The hub validates message structure before it reaches the DFSP, so malformed requests (DI-INC-05, DI-INC-15) cannot be sent to the DFSP through the hub. The hub also answers repeated transfers itself (DI-INC-14).
- Tested with Toolkit v18.19.2 and client library 1.12.
