# Contributing to the Bidirekt petstore example

## Bugs and feature requests

Open an issue in this repository, with the **Bug report** or the **Feature request** form.

## Questions

For questions about using Bidirekt, read the docs at https://bidirekt.com/docs.

## Pull requests

Fork the repository, create a branch, and open a pull request against `main`. CI runs `demo.sh` on every pull request and fails unless the output shows `petstore_api 2.0.0 cannot be deployed to production`, naming `Pet.status`, then `petstore_api 3.0.0 can be deployed to production`, and `contracts/` is left unchanged. To run the same check on your machine:

```
./demo.sh
git diff --exit-code contracts/
```

CI also runs `petstore_ts.sh` in its own job, `petstore_ts`: it fails unless `petstore_ts/contracts/generated.yaml` matches what `generate` writes from the code, in the `node` service of `compose.yaml`, and `bidirekt validate` accepts it. After changing `petstore_ts/`, write the contract again and run the same check:

```
docker compose run --rm node npx @bidirekt/typescript-sdk-cli generate
./petstore_ts.sh
```

The `petstore_php` job does the same for `petstore_php/`, with `generate` in the `php` service:

```
docker compose run --rm php vendor/bin/php-sdk generate
./petstore_php.sh
```

## Security

Report a vulnerability as [SECURITY.md](SECURITY.md) describes, never in an issue.
