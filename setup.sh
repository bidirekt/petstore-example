#!/bin/sh
# Runs in the setup service of compose.yaml, which shares the broker's network: there the broker answers at its public URL.
# Signs in as the admin, setting up a new broker first, then creates an API key that can write and prints it.
set -eu

broker=http://localhost:8080
email=admin@petstore.example.com
password=petstore-admin-password
cookies=$(mktemp)

post_form() {
  path=$1
  shift
  curl -sS --max-time 5 -b "$cookies" -c "$cookies" \
    -H "Origin: $broker" \
    --data-urlencode "email=$email" \
    --data-urlencode "password=$password" \
    "$@" "$broker$path"
}

status=$(post_form /setup -o /dev/null -w '%{http_code}')
if [ "$status" = 404 ]; then
  status=$(post_form /sign-in -o /dev/null -w '%{http_code}')
fi

case $status in
  3*) ;;
  *)
    echo "could not sign in as $email at $broker (HTTP $status)" >&2
    exit 1
    ;;
esac

if ! form=$(curl -fsS --max-time 5 -b "$cookies" "$broker/profile/api-keys/new"); then
  echo "could not open $broker/profile/api-keys/new" >&2
  exit 1
fi
token=$(printf '%s\n' "$form" | sed -n 's/.*"X-CSRF-Token": "\([^"]*\)".*/\1/p')

if ! created=$(curl -fsS --max-time 5 -b "$cookies" \
  -H "Origin: $broker" \
  -H "X-CSRF-Token: $token" \
  --data name=petstore-example --data permission=write --data expiration=never \
  "$broker/profile/api-keys/new"); then
  echo "could not create an API key at $broker" >&2
  exit 1
fi

key=$(printf '%s\n' "$created" | sed -n 's/.*<input class="copy" type="text" readonly value="\([^"]*\)".*/\1/p')
if [ -z "$key" ]; then
  echo "found no API key in the page $broker/profile/api-keys/new answered" >&2
  exit 1
fi

echo "$key"
