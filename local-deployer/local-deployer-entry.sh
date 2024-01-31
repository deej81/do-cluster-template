#!/bin/bash

if [[ -z "${DO_TOKEN}" ]]; then
	echo "DO_TOKEN env var not set. Exiting."
	exit 1
fi

if [[ -z "${TAILSCALE_KEY}" ]]; then
	echo "TAILSCALE_KEY env var not set. Exiting."
	exit 1
fi

cd deployer


/bin/bash