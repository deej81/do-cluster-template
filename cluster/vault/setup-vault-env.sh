#!/bin/bash

CREDENTIALS_FILE=../../secrets/vault-credentials.json

VAULT_ROOT_TOKEN=$(cat $CREDENTIALS_FILE | jq '.root_token')
# Remove double quotes
VAULT_ROOT_TOKEN=$(echo "$VAULT_ROOT_TOKEN" | tr -d '"')

export VAULT_TOKEN=$VAULT_ROOT_TOKEN