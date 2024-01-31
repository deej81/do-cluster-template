#!/bin/bash

sudo bash /ops/shared/scripts/client.sh "${retry_join}"
sudo bash /ops/shared/scripts/install-tailscale.sh "${tailscale_key}"
