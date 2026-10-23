#!/bin/sh
# Puts petstore_api 1.0.0 and petstore_web 1.0.0 in production. Every command is safe to run again.
set -eu

bidirekt create-environment production
bidirekt create-participant petstore_api
bidirekt create-participant petstore_web

bidirekt publish deployed/petstore_api.yaml --participant petstore_api --version 1.0.0
bidirekt publish deployed/petstore_web.yaml --participant petstore_web --version 1.0.0

bidirekt record-deployment petstore_api --version 1.0.0 --environment production
bidirekt record-deployment petstore_web --version 1.0.0 --environment production
