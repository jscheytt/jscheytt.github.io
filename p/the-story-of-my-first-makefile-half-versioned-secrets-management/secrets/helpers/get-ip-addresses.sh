#!/usr/bin/env bash
set -euo pipefail
# set -x # DEBUG

# Prerequisites
which kubectl >/dev/null

commands=(
	"curl -s https://checkip.amazonaws.com"
	"wget -qO- https://checkip.amazonaws.com"
)

# Get all namespaces
for namespace in $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'); do
	# Get ready pods - see https://stackoverflow.com/a/58993731/6435726
	# shellcheck disable=SC2016
	for pod in $(kubectl -n "$namespace" get pods -o go-template='{{range $index, $element := .items}}{{range .status.containerStatuses}}{{if .ready}}{{$element.metadata.name}}{{"\n"}}{{end}}{{end}}{{end}}'); do
		for command in "${commands[@]}"; do
			set +e
			# Execute all commands on the pod, hoping that one of the executables is installed.
			# Ignore errors from stderr so we can harvest just the IP addresses.
			kubectl -n "$namespace" exec "$pod" -- sh -c "$command" 2>/dev/null
			set -e
		done
	done
done
