#!/usr/bin/env bash
set -euo pipefail
# set -x # DEBUG

secret_name="$1"
# Use second argument or read stdin
secret_value="${2:-$(cat -)}"

echo "$secret_value" # DEBUG

# Create secret in idempotent way, avoid script from failing
set +e
aws secretsmanager create-secret --name "$secret_name" &> /dev/null
set -e

# Put secret value and output response to stdout
aws secretsmanager put-secret-value --secret-id "$secret_name" \
  --secret-string "$secret_value" | cat
