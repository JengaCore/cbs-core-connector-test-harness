# Direct integration

Resources for a DFSP that integrates with the hub directly, without the Payment Manager. They define what the DFSP must do to be onboarded and to clear payments, how each behaviour is checked, and what evidence is kept.

The hub's API is ISO 20022 for party lookup, quotes and transfers. Other resources keep their FSPIOP format. In scope are person-to-person and person-to-business payments. FX, request to pay, bulk and third-party initiation are out of scope.

## Contents

| File | Purpose |
|---|---|
| [onboarding.md](onboarding.md) | The certificates and keys to create, the MCM calls to make, and the hub operator's steps |
| [clearing-behaviour.md](clearing-behaviour.md) | How a payment clears, and every message: API path, schema, fields and rules |
| [hub-requests.md](hub-requests.md) | What to ask the hub operator for, and what the hub operator does |
| [register.md](register.md) | The test cases, how each is checked, and the behaviour it covers |
| [evidence/evidence-pack.md](evidence/evidence-pack.md) | The template for recording a run |

## Using these resources

1. Send the first table in [hub-requests.md](hub-requests.md) to the hub operator.
2. Implement onboarding as described in [onboarding.md](onboarding.md), and check each step.
3. Implement the message handling in [clearing-behaviour.md](clearing-behaviour.md).
4. When the hub operator confirms the participant is ready, run the cases in [register.md](register.md) against the test environment.
5. Record each result, with the evidence the register names, in the evidence pack.
6. Repeat on production after the test environment passes.

## Status

The documents above are complete. The Testing Toolkit collections and the onboarding check scripts that the register refers to are not yet in this folder. Until they are, the hub operator carries out those checks by following the behaviour documents.

## Sources

The behaviour was read from the Mojaloop source at the versions the hub runs, and from the API definitions:

- The combined API definition used by the Testing Toolkit: [api_spec.yaml](../sdk-based-test-harness/config/ttk-hub/spec_files/api_definitions/fspiop_2.0_iso20022/api_spec.yaml)
- The MCM API: [connection-manager-api](https://github.com/mojaloop/connection-manager-api)
- The reference client library: [mcm-client](https://github.com/mojaloop/mcm-client)
- The shared components for signing and ILP: [sdk-standard-components](https://github.com/mojaloop/sdk-standard-components)
- The Testing Toolkit: [ml-testing-toolkit](https://github.com/mojaloop/ml-testing-toolkit)

Each document ends with the exact files it relies on.
