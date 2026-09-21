# Bluebank / Greenbank Test Configuration

JengaCore-specific configuration for testing `bluebank-zm-dfsp-cc` against
this harness. This is a separate, self-contained folder — nothing here
edits the harness's own root `environments/`/`collections/` files in place.

## What's testing what

Only **one** connector is actually under test here — `core-connector1`
(`bluebank-zm-dfsp-cc`). The second participant in the compose stack,
`core-connector2` (`greenbank-zm-dfsp-cc`), exists purely so there's a real
counterparty for two-DFSP scenarios (P2P/P2B transfers need a sender and a
receiver). Since Greenbank isn't the thing being verified, it's left as the
harness's own default, unmodified example image
(`elijahokello/test-dfsp-cc:v2`) — stateless, no real ledger, nothing to set
up. If you're the one testing *Greenbank's* connector instead, swap the roles.

**`bluebank-zm-dfsp-cc` is tested against `bluebank-mock`** (a separate,
real FastAPI + SQLite service with an actual ledger — reserve/commit/
unreserve genuinely change a real balance) rather than the harness's
built-in `dfsp-api` (Prism) mock. Prism is stateless — every response is
canned from an OpenAPI spec, with nothing persisting between calls — which
isn't sufficient to properly exercise a reserve-then-commit lifecycle. The
`dfsp-api` service block in `docker-compose.yml` has been commented out by
default; uncomment it if you specifically want to test against the
stateless default instead.

## Networking: the mock lives outside the Docker network

`bluebank-mock` runs on the host machine directly, **not** as a container
inside `mojaloop-net`. `core-connector1` reaches it via
`http://host.docker.internal:4040`, which requires:

```yaml
# core-connector.yaml, on the core-connector service
extra_hosts:
  - "host.docker.internal:host-gateway"
```

Without this, `core-connector1` gets `ENOTFOUND host.docker.internal`. If
that resolves but requests still fail with `ECONNREFUSED`, check that
`bluebank-mock` itself is bound to `0.0.0.0`, not just `127.0.0.1`
(`uvicorn app.main:app --host 0.0.0.0 --port 4040`) — traffic arriving via
the Docker bridge looks like it's coming from a different interface than
plain loopback, and gets refused if the mock is only listening on
`127.0.0.1`.

## Setup

1. Run `bluebank-mock` locally (see its own repo/README)
2. Confirm `extra_hosts` is set as above, and `core-connector.env`'s
   `BLUE_BANK_URL=http://host.docker.internal:4040`
3. `docker compose up -d --force-recreate core-connector1` after any config
   change — editing `.env`/`.yaml` files never affects an already-running
   container, it has to be recreated
4. Load `environments/cc_golden_path_env_bluebank.json` in TTK (not the
   harness's own `cc_golden_path_env_local.json`)
5. Load `collections/cc_golden_path-positive-tests.json` (and the negative
   test collection, if needed)

## To Note:

- **Currency has to be aligned across *every* participant in the compose
  stack, not just the connector under test.