# Onboarding checks

`check-onboarding.sh` checks a DFSP's onboarding by reading MCM through its API. It covers `DI-ONB-01` to `DI-ONB-09`, and `DI-SEC-02` to `DI-SEC-04` when the hosts are given. It reads only. It creates and changes nothing, and it does not print the token or the client secret.

It needs `bash`, `curl`, `jq` and `openssl`.

## Settings

| Variable | Required | Meaning |
|---|---|---|
| `MCM_URL` | Yes | MCM API base URL for DFSPs |
| `TOKEN_URL` | Yes | The Keycloak token URL |
| `DFSP_ID` | Yes | Your DFSP id. It is also the Keycloak client id |
| `CLIENT_SECRET_FILE` | Yes | A file that contains the client secret |
| `CALLBACK_HOST` | No | Your callback host. Enables the server certificate checks, `DI-SEC-02` and `DI-SEC-03` |
| `CALLBACK_PORT` | No | Port of the callback host. Default 443 |
| `FSPIOP_HOST` | No | The switch FSPIOP host. With `CLIENT_CERT` and `CLIENT_KEY`, enables `DI-SEC-04` |
| `CLIENT_CERT`, `CLIENT_KEY` | No | Your client certificate and its key |
| `MIN_KEY_BITS` | No | Minimum JWS key length. Default 2048 |

## Use

```sh
export MCM_URL=https://mcm.<switch domain>/pm4mlapi
export TOKEN_URL=https://keycloak.<switch domain>/realms/dfsps/protocol/openid-connect/token
export DFSP_ID=<your DFSP id>
export CLIENT_SECRET_FILE=./client-secret.txt
export CALLBACK_HOST=ml-connect.example.com
./check-onboarding.sh
```

Each line is `PASS`, `FAIL` or `SKIP`, with the case id. The exit status is 0 when no check failed, 1 when one failed and 2 when the settings are incomplete. Keep the output as evidence for [../register.md](../register.md).

## What each check reads

| Case | Call | Passes when |
|---|---|---|
| `DI-ONB-01` | Token request, then `GET /dfsps/{id}/ca` | A token is returned and MCM accepts it |
| `DI-ONB-02` | `GET /dfsps/{id}/ca` | `validationState` is `VALID` and the root is a CA certificate |
| `DI-ONB-03` | `GET /dfsps/{id}/servercerts` | `VALID`, chains to the CA, and names `CALLBACK_HOST` |
| `DI-ONB-04` | `GET /dfsps/{id}/jwscerts`, `GET /dfsps/jwscerts` | An RSA public key of the minimum length, listed for the DFSP |
| `DI-ONB-05` | `GET /dfsps/{id}/endpoints` | An ingress URL is registered |
| `DI-ONB-06` | `GET /dfsps/{id}/enrollments/outbound` | The hub's request is `CERT_SIGNED` and was issued by the DFSP CA |
| `DI-ONB-07` | `GET /dfsps/{id}/enrollments/inbound` | A request was submitted and is not `INVALID` |
| `DI-ONB-08` | `GET /dfsps/{id}/enrollments/inbound` | The client certificate is `CERT_SIGNED` and has not expired |
| `DI-ONB-09` | `GET /hub/ca` | The hub CA is available. The check prints its fingerprint for you to compare |
| `DI-SEC-02` | TLS to the callback host | A client with no certificate is refused |
| `DI-SEC-03` | TLS to the callback host | The certificate presented is issued by the DFSP CA and names the host |
| `DI-SEC-04` | TLS to the switch | Your certificate is accepted and a client without one is refused |

## What was tested

The script was run against a mock MCM and a mock callback host that requires a client certificate. Every check passed on correct data and failed on faulty data, and a wrong client secret stopped it at `DI-ONB-01`. `DI-SEC-04` and the real MCM have not been tested. Run it against the test environment first.
