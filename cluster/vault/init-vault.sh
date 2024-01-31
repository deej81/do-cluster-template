#!/bin/bash

KEY_SHARES=5
KEY_THRESHOLD=3
CREDENTIALS_FILE=../../secrets/vault-credentials.json

vault operator init \
    -key-shares=$KEY_SHARES \
    -key-threshold=$KEY_THRESHOLD \
    -format=json | tee $CREDENTIALS_FILE

VAULT_ROOT_TOKEN=$(cat $CREDENTIALS_FILE | jq '.root_token')
# Remove double quotes
VAULT_ROOT_TOKEN=$(echo "$VAULT_ROOT_TOKEN" | tr -d '"')

echo "VAULT_TOKEN=$VAULT_ROOT_TOKEN" >> ~/.bashrc  
# Make sure vault token is sourced, so start new shell
echo "Vault is initialized"
echo "Unsealing vault ..."

unseal_keys=$(cat $CREDENTIALS_FILE | jq -r '.unseal_keys_b64[]' | head -$KEY_THRESHOLD)
for unseal_key in ${unseal_keys[@]}; do
   vault operator unseal $unseal_key
done

echo "Vault is unsealed and ready for use"