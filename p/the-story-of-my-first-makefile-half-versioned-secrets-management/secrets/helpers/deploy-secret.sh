#!/usr/bin/env bash
set -euo pipefail
# set -x # DEBUG

secret_name="$1"
# Use second argument or read stdin
secret_value="${2:-$(cat -)}"

echo "$secret_value"

set +e
aws secretsmanager create-secret --name "$secret_name" &>/dev/null
set -e

aws secretsmanager put-secret-value --secret-id "$secret_name" --secret-string "$secret_value" | cat
