# petstore-example

A Bidirekt broker with two participants deployed to `production`: `petstore_api`, the provider, and `petstore_web`, its consumer, which reads `Pet.status`. `contracts/petstore_api.yaml` is a proposed change to `petstore_api` that drops `status`, and the check shows that it would break `petstore_web`. It only needs Docker.

```
docker compose up
```

The check ends with:

```
petstore_api local contract cannot be deployed to production

petstore_web (1.0.0, deployed):
  Pet.status — petstore_api doesn't provide it, but petstore_web reads it
    → petstore_api: provide it
    → petstore_web: stop reading it, or handle its absence in the code and mark it optional there
      · GET /pets/* response 200 at "$.status" (petstore_web: Pet.status)
```

To fix it, put `status` back under `Pet` in `contracts/petstore_api.yaml`:

```yaml
      status:
        type: string
```

Then check again, and it prints `petstore_api local contract can be deployed to production`:

```
docker compose run --rm check
```

To remove the containers and the broker's data:

```
docker compose down -v
```

| Path | What it is |
|---|---|
| `deployed/` | the contracts of `petstore_api 1.0.0` and `petstore_web 1.0.0`, deployed to `production` by `scripts/seed.sh` |
| `contracts/petstore_api.yaml` | the proposed change to `petstore_api`, checked by `scripts/check.sh` with `bidirekt validate` |
| `compose.yaml` | Postgres, the broker and the two scripts, run with the `bidirekt` CLI image |

The walkthrough is at https://bidirekt.com/docs/start/try.
