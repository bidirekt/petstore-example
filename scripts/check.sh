#!/bin/sh
# Checks the proposed petstore_api contract in contracts/ against what is deployed in production.
set -eu

if bidirekt validate contracts/ --participant petstore_api --environment production; then
  exit 0
fi

echo
echo "To fix it, put status back under Pet in contracts/petstore_api.yaml:"
echo
echo "      status:"
echo "        type: string"
echo
echo "Then run: docker compose run --rm check"
exit 1
