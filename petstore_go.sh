#!/bin/sh
# Checks petstore_go/contracts/generated.yaml against the code, then validates it on a broker of its own.
set -eu
cd "$(dirname "$0")"

# A project of its own, so it never touches the demo's broker or another run.
COMPOSE_PROJECT_NAME=petstore-go-$$
export COMPOSE_PROJECT_NAME
# compose takes the go container, kept for the down on exit, for an orphan and would warn about it on every command.
COMPOSE_IGNORE_ORPHANS=1
export COMPOSE_IGNORE_ORPHANS
failed=0
cleanup() {
  if [ "$failed" != 0 ]; then
    docker compose logs broker
  fi
  # Without the go profile, down keeps the module cache volume. Quiet: down removes the kept go container twice, as the
  # go service's and as an orphan, and calls the second an error.
  docker compose --progress quiet --profile go down -v --remove-orphans
}
trap 'failed=$?; cleanup' EXIT
# dash and busybox ash skip the EXIT trap when a signal kills the shell.
trap 'exit 1' HUP INT TERM

contract=petstore_go/contracts/generated.yaml

# docker compose run reads all of a stdin that is not a terminal, such as a script piped to sh.
# Without --rm, the down on exit removes the container before its module cache volume: with --rm, a container that
# Ctrl-C stopped is still being removed when down tries the volume, which then stays.
docker compose --progress quiet run go go tool go-sdk generate --check </dev/null
printf '%s matches the code\n' "$contract"

docker compose up -d --wait
BIDIREKT_API_KEY=$(docker compose --progress quiet run --rm setup </dev/null)
export BIDIREKT_API_KEY

./bidirekt create-environment production
./bidirekt create-participant petstore_go
./bidirekt validate "$contract" --participant petstore_go --environment production
