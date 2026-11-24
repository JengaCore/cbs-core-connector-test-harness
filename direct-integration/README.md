# Direct integration

Resources for a DFSP that integrates with the hub directly, without the Payment Manager. They define what the DFSP must do to be onboarded and to clear payments, how each behaviour is checked, and what evidence is kept.

The hub's API is ISO 20022 for party lookup, quotes and transfers. Other resources keep their FSPIOP format. In scope are person-to-person and person-to-business payments. FX, request to pay, bulk and third-party initiation are out of scope.

## Contents

| File | Purpose |
|---|---|
| [onboarding.md](onboarding.md) | The certificates and keys to create, the MCM calls to make, and the hub operator's steps |
| [clearing-behaviour.md](clearing-behaviour.md) | How a payment clears, and every message: API path, schema, links to the real payloads, and the rules |
| [field-reference.md](field-reference.md) | Every element of every ISO 20022 message, and how the hub reads it. Generated from the API definition |
| [hub-requests.md](hub-requests.md) | What to ask the hub operator for, and what the hub operator does |
| [register.md](register.md) | The test cases, how each is checked, and the behaviour it covers |
| [evidence/evidence-pack.md](evidence/evidence-pack.md) | The template for recording a run |
| [onboarding-checks](onboarding-checks) | A script that checks onboarding by reading MCM |
| [ttk](ttk) | Testing Toolkit collections, rules and a self-test |
| [tools/generate_field_reference.py](tools/generate_field_reference.py) | Regenerates `field-reference.md` |

## Using these resources

1. Send the first table in [hub-requests.md](hub-requests.md) to the hub operator.
2. Implement onboarding as described in [onboarding.md](onboarding.md), and check each step.
3. Implement the message handling in [clearing-behaviour.md](clearing-behaviour.md). Use the API viewer links in it to see real payloads, and [field-reference.md](field-reference.md) for every element.
4. Run [onboarding-checks/check-onboarding.sh](onboarding-checks/check-onboarding.sh) and keep its output.
5. When the hub operator confirms the participant is ready, run the cases in [register.md](register.md) against the test environment. The hub operator runs the Testing Toolkit cases in [ttk](ttk).
6. Record each result, with the evidence the register names, in the evidence pack.
7. Repeat on production after the test environment passes.

## Regenerating the field reference

`field-reference.md` is generated and must not be edited by hand. To regenerate it, for example after the API definition changes:

```sh
pip install pyyaml
git clone --branch v2.9.0 https://github.com/mojaloop/ml-schema-transformer-lib
python3 tools/generate_field_reference.py \
  --spec ../sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml \
  --mappings ml-schema-transformer-lib/src/mappings/fspiopiso20022 \
  --spec-url https://github.com/JengaCore/cbs-core-connector-test-harness/blob/<commit>/sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml \
  --out field-reference.md
```

Run it from `direct-integration`. `<commit>` is the commit of the API definition, so that the line links stay correct.

## Status

The documents, the onboarding check script and the Testing Toolkit collections are complete. They have been tested as follows:

- The onboarding script passes every check against a mock MCM and fails correctly on faulty data.
- The Testing Toolkit collections pass against a Toolkit that plays the DFSP (`ttk/selftest/run.sh`).
- Neither has been run against a real hub or a real DFSP. The first run may need small adjustments to the environment values and rules.

Register rows whose method is Evidence are not automated. [register.md](register.md) says why for each.

## Sources

The behaviour was read from the Mojaloop source at the versions the hub runs, and from the API definitions:

- The combined API definition used by the Testing Toolkit: [api_spec.yaml](../sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml)
- The MCM API: [connection-manager-api](https://github.com/mojaloop/connection-manager-api)
- The reference client library: [mcm-client](https://github.com/mojaloop/mcm-client)
- The shared components for signing and ILP: [sdk-standard-components](https://github.com/mojaloop/sdk-standard-components)
- The Testing Toolkit: [ml-testing-toolkit](https://github.com/mojaloop/ml-testing-toolkit)

Each document ends with the exact files it relies on.
