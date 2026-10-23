#!/bin/sh
set -eu
cd "$(dirname "$0")"

run() {
  printf '\n$ %s\n' "$*"
  "$@"
}

run docker compose down -v --remove-orphans
run docker compose up -d --wait
run docker compose pull cli

run ./bidirekt create-environment production
run ./bidirekt create-participant petstore_api
run ./bidirekt create-participant petstore_web
run ./bidirekt publish deployed/petstore_api.yaml --participant petstore_api --version 1.0.0
run ./bidirekt publish deployed/petstore_web.yaml --participant petstore_web --version 1.0.0
run ./bidirekt record-deployment petstore_api --version 1.0.0 --environment production
run ./bidirekt record-deployment petstore_web --version 1.0.0 --environment production
run ./bidirekt publish contracts/petstore_api.yaml --participant petstore_api --version 2.0.0

if run ./bidirekt can-i-deploy petstore_api --version 2.0.0 --environment production; then
  printf '\nThe proposed change can be deployed: it breaks nothing in production.\n'
  exit 0
fi

cat <<'EOF'

The proposed change breaks petstore_web, which is deployed in production.

Fix it: put status back under Pet in contracts/petstore_api.yaml:

      status:
        type: string

Then publish the fixed contract as a new version and check it again:

  ./bidirekt publish contracts/petstore_api.yaml --participant petstore_api --version 3.0.0
  ./bidirekt can-i-deploy petstore_api --version 3.0.0 --environment production

Run ./try.sh again to start over.
EOF
