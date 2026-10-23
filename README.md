# petstore-example

A Bidirekt broker with two participants deployed to `production`: `petstore_api`, the provider, and `petstore_web`, its consumer, which reads `Pet.status`. `contracts/petstore_api.yaml` is a proposed change to `petstore_api` that drops `status`, and the check shows that it would break `petstore_web`. It only needs Docker.

```
./try.sh
```

Without cloning this repo, `curl -sL bidirekt.com/try | sh` downloads it and runs `./try.sh`.

`try.sh` starts Postgres and the broker, deploys `petstore_api 1.0.0` and `petstore_web 1.0.0` to `production`, publishes the proposed change as `petstore_api 2.0.0` and asks `can-i-deploy` whether it can go to `production`. It prints each command before running it, and `can-i-deploy` answers:

```
petstore_api 2.0.0 cannot be deployed to production

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

Then publish the fixed contract as a new version and check it again:

```
./bidirekt publish contracts/petstore_api.yaml --participant petstore_api --version 3.0.0
./bidirekt can-i-deploy petstore_api --version 3.0.0 --environment production
```

This time `can-i-deploy` prints `petstore_api 3.0.0 can be deployed to production`. Run `./try.sh` again to start over: it removes the broker's data first. To remove the containers and the broker's data when you're done:

```
docker compose down -v
```

| Path | What it is |
|---|---|
| `deployed/` | the contracts of `petstore_api 1.0.0` and `petstore_web 1.0.0`, deployed to `production` by `try.sh` |
| `contracts/petstore_api.yaml` | the proposed change to `petstore_api`, published as `2.0.0` by `try.sh` |
| `bidirekt` | runs the `bidirekt` CLI in a container next to the broker |
| `compose.yaml` | Postgres, the broker and the `bidirekt` CLI image |

The walkthrough is at https://bidirekt.com/docs/start/try.
