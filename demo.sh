#!/bin/sh
set -eu
cd "$(dirname "$0")"

contract=contracts/petstore_api.yaml
# Step 5 fixes the contract in place; on exit it goes back to the proposed change, so the demo can run again.
proposed=$(mktemp)
cp "$contract" "$proposed"
trap 'cp "$proposed" "$contract"; rm -f "$proposed"' EXIT
# dash and busybox ash skip the EXIT trap when a signal kills the shell.
trap 'exit 1' HUP INT TERM

letter_delay=0.04

step() {
  printf '\nStep %s of 6 — %s\n' "$1" "$2"
}

type_line() {
  if [ -t 1 ]; then
    text=$1
    while [ -n "$text" ]; do
      rest=${text#?}
      printf '%s' "${text%"$rest"}"
      text=$rest
      sleep "$letter_delay"
    done
    sleep 0.6
    printf '\n'
  else
    printf '%s\n' "$1"
  fi
}

type_command() {
  printf '\n$ '
  type_line "$*"
}

type_run() {
  type_command "$@"
  "$@"
}

# A vim drawn on the screen, so the demo doesn't need vim installed.
edit_contract() {
  type_command vim "$contract"
  awk 'NR >= 13 && NR <= 20 { printf "%3d %s\n", NR, $0 }' "$contract"
  printf ' 21 '
  type_line '      status:'
  printf ' 22 '
  type_line '        type: string'
  awk 'NR >= 21 && NR <= 22 { printf "%3d %s\n", NR + 2, $0 }' "$contract"
  type_line ':wq'
  awk 'NR == 21 { print "      status:"; print "        type: string" } { print }' "$proposed" >"$contract"
}

step 1 'Start the broker'
type_run docker compose down -v --remove-orphans
type_run docker compose up -d --wait
type_run docker compose pull cli

step 2 'Set up what is in production'
# Setting up is not the story: type it fast.
letter_delay=0.01
type_run ./bidirekt create-environment production
type_run ./bidirekt create-participant petstore_api
type_run ./bidirekt create-participant petstore_web
type_run ./bidirekt publish deployed/petstore_api.yaml --participant petstore_api --version 1.0.0
type_run ./bidirekt publish deployed/petstore_web.yaml --participant petstore_web --version 1.0.0
type_run ./bidirekt record-deployment petstore_api --version 1.0.0 --environment production
type_run ./bidirekt record-deployment petstore_web --version 1.0.0 --environment production
letter_delay=0.04

step 3 'Publish the proposed change'
type_run ./bidirekt publish contracts/petstore_api.yaml --participant petstore_api --version 2.0.0

step 4 'Check it'
if type_run ./bidirekt can-i-deploy petstore_api --version 2.0.0 --environment production; then
  printf '\nthe proposed change should break petstore_web\n' >&2
  exit 1
fi
printf '\nThe proposed change breaks petstore_web, which is deployed in production.\n'

step 5 'Fix the contract'
edit_contract
type_run ./bidirekt publish contracts/petstore_api.yaml --participant petstore_api --version 3.0.0
type_run ./bidirekt can-i-deploy petstore_api --version 3.0.0 --environment production

step 6 'Clean up'
type_run docker compose down -v
printf '\nReady for your own services? Run this in your project: curl -sL bidirekt.com/try | sh\n'
