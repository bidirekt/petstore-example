#!/bin/sh
# Checks petstore_php/contracts/generated.yaml against the code, then validates it on a broker of its own.
set -eu
cd "$(dirname "$0")"

# A project of its own, so it never touches the demo's broker or another run.
COMPOSE_PROJECT_NAME=petstore-php-$$
export COMPOSE_PROJECT_NAME
failed=0
cleanup() {
  if [ "$failed" != 0 ]; then
    docker compose logs broker
  fi
  docker compose down -v --remove-orphans
}
trap 'failed=$?; cleanup' EXIT
# dash and busybox ash skip the EXIT trap when a signal kills the shell.
trap 'exit 1' HUP INT TERM

contract=petstore_php/contracts/generated.yaml

# docker compose run reads all of a stdin that is not a terminal, such as a script piped to sh.
docker compose --progress quiet run --rm php vendor/bin/php-sdk generate --check </dev/null
printf '%s matches the code\n' "$contract"

docker compose up -d --wait
BIDIREKT_API_KEY=$(docker compose --progress quiet run --rm setup </dev/null)
export BIDIREKT_API_KEY

./bidirekt create-environment production
./bidirekt create-participant petstore_php
./bidirekt validate "$contract" --participant petstore_php --environment production
