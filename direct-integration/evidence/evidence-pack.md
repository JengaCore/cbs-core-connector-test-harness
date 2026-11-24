# Evidence pack

One pack per DFSP, per environment, per run of the register in [../register.md](../register.md). Copy this file, fill it in and keep it with the evidence files it names.

## Run

| | |
|---|---|
| DFSP id | |
| Environment | |
| Date of run | |
| Register version (commit) | |
| DFSP build identifier | |
| Hub service versions confirmed by the hub operator | |
| Run by (DFSP) | |
| Witnessed by (hub operator) | |

## Results

One row per register case in scope. Result is Pass, Fail or Not applicable. Evidence is a file name from this pack.

| Case | Result | Evidence file | Hub record (ledger, quote or lookup, trace id) | Notes |
|---|---|---|---|---|
| | | | | |

## Evidence to keep, by method

| Method | Keep |
|---|---|
| Script (reads MCM) | The command output with the time it was run |
| TTK | The Testing Toolkit report (JSON and HTML) for the collection |
| Hub check | The hub operator's confirmation, with the hub's own record |
| Evidence (DFSP supplied) | The DFSP's log extract or screenshot, showing the identifiers and times |

For every payment case, attach the hub's record of the transfer. The DFSP's own logs alone are not sufficient.

## Certificates

| Item | Fingerprint (SHA-256) | Expires |
|---|---|---|
| DFSP CA root | | |
| Callback server certificate | | |
| DFSP client certificate | | |
| Hub client certificate for this DFSP | | |

## Defects

| Case | Defect | Raised by | Status |
|---|---|---|---|
| | | | |

## Sign-off

The pack is complete when every in-scope case has a result of Pass, with evidence, and no defect is open.

| Role | Name | Date | Signature |
|---|---|---|---|
| DFSP technical lead | | | |
| Hub operator | | | |
