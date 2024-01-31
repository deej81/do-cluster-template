#!/bin/bash

TAILSCALE_KEY=$1
tailscale up --authkey $TAILSCALE_KEY --hostname bastion
tailscale ip -4 >> /tmp/tailscale-ip.txt