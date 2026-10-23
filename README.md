# petstore-example

A Bidirekt broker with two participants deployed to `production`: `petstore_api`, the provider, and `petstore_web`, its consumer, which reads `Pet.status`. `contracts/petstore_api.yaml` is a proposed change to `petstore_api` that drops `status`, and the check shows that it would break `petstore_web`. It only needs Docker.

```
./demo.sh
```

Without cloning this repo, `curl -sL bidirekt.com/demo | sh` downloads it and runs `./demo.sh`.

`demo.sh` runs by itself in six steps. Each starts with a title, and each command is typed before it runs:

1. **Start the broker**: removes what an earlier run left, starts Postgres and the broker, and pulls the CLI image.
2. **Set up what is in production**: creates `production`, `petstore_api` and `petstore_web`, publishes `1.0.0` of each from `deployed/` and records both as deployed to `production`.
3. **Publish the proposed change**: publishes `contracts/petstore_api.yaml` as `petstore_api 2.0.0`.
4. **Check it**: `can-i-deploy` says `2.0.0` cannot be deployed.
5. **Fix the contract**: puts `status` back under `Pet`, publishes `3.0.0` and checks it again.
6. **Clean up**: `docker compose down -v` removes the containers and the broker's data.

In step 4, `can-i-deploy` answers:

```
$ ./bidirekt can-i-deploy petstore_api --version 2.0.0 --environment production
Broker: http://broker:8080 (from BIDIREKT_BROKER_URL)
petstore_api 2.0.0 cannot be deployed to production

petstore_web (1.0.0, deployed):
  Pet.status — petstore_api doesn't provide it, but petstore_web reads it
    → petstore_api: provide it
    → petstore_web: stop reading it, or handle its absence in the code and mark it optional there
      · GET /pets/* response 200 at "$.status" (petstore_web: Pet.status)
```

In step 5, the fixed contract passes:

```
$ ./bidirekt can-i-deploy petstore_api --version 3.0.0 --environment production
Broker: http://broker:8080 (from BIDIREKT_BROKER_URL)
petstore_api 3.0.0 can be deployed to production
compared with: petstore_web
```

When `demo.sh` ends, `contracts/petstore_api.yaml` goes back to the proposed change, so you can run it again. To set up Bidirekt in your own project, run `curl -sL bidirekt.com/try | sh` there.

| Path | What it is |
|---|---|
| `demo.sh` | runs the demo |
| `deployed/` | the contracts of `petstore_api 1.0.0` and `petstore_web 1.0.0`, deployed to `production` by `demo.sh` |
| `contracts/petstore_api.yaml` | the proposed change to `petstore_api`, published as `2.0.0` by `demo.sh` |
| `bidirekt` | runs the `bidirekt` CLI in a container next to the broker |
| `compose.yaml` | Postgres, the broker and the `bidirekt` CLI image |

The walkthrough is at https://bidirekt.com/docs/start/demo.
