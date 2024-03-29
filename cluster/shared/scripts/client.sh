#!/bin/bash

CONFIGDIR=/ops/shared/config

CONSULCONFIGDIR=/etc/consul.d
NOMADCONFIGDIR=/etc/nomad.d
CONSULTEMPLATECONFIGDIR=/etc/consul-template.d
HOME_DIR=ubuntu

# Wait for network
sleep 15

RETRY_JOIN=$1
NOMAD_BINARY=$2

# Get IP from metadata service
IP_ADDRESS=$(curl http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
# IP_ADDRESS=$(curl http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
# IP_ADDRESS="$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')"

# Consul
sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/consul_client.json
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $CONFIGDIR/consul_client.json
sudo cp $CONFIGDIR/consul_client.json $CONSULCONFIGDIR/consul.json
sudo cp $CONFIGDIR/consul.service /etc/systemd/system/consul.service

# https://learn.hashicorp.com/tutorials/consul/dns-forwarding#systemd-resolved-setup
# Stop port 53 listener
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

sudo rm /etc/systemd/resolved.conf
sudo mv $CONFIGDIR/resolved.conf /etc/systemd/resolved.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

export CONSUL_ALLOW_PRIVILEGED_PORTS=yes
sudo systemctl enable consul.service
sudo systemctl start consul.service
sleep 10

# Nomad

## Replace existing Nomad binary if remote file exists
if [[ `wget -S --spider $NOMAD_BINARY  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
  curl -L $NOMAD_BINARY > nomad.zip
  sudo unzip -o nomad.zip -d /usr/local/bin
  sudo chmod 0755 /usr/local/bin/nomad
  sudo chown root:root /usr/local/bin/nomad
fi

sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/nomad_client.hcl
sudo cp $CONFIGDIR/nomad_client.hcl $NOMADCONFIGDIR/nomad.hcl
sudo cp $CONFIGDIR/nomad.service /etc/systemd/system/nomad.service

sudo systemctl enable nomad.service
sudo systemctl start nomad.service
sleep 10
export NOMAD_ADDR=http://$IP_ADDRESS:4646

# Consul Template
sudo cp $CONFIGDIR/consul-template.hcl $CONSULTEMPLATECONFIGDIR/consul-template.hcl
sudo cp $CONFIGDIR/consul-template.service /etc/systemd/system/consul-template.service

# Add hostname to /etc/hosts
echo "127.0.0.1 $(hostname)" | sudo tee --append /etc/hosts

# Add Docker bridge network IP to /etc/resolv.conf (at the top)
# echo "nameserver $DOCKER_BRIDGE_IP_ADDRESS" | sudo tee /etc/resolv.conf.new
# cat /etc/resolv.conf | sudo tee --append /etc/resolv.conf.new
# sudo mv /etc/resolv.conf.new /etc/resolv.conf


sudo rm /etc/resolv.conf
sudo cp $CONFIGDIR/resolv.conf /etc/resolv.conf

# Make docker also pickup the newest resolv.conf
sudo systemctl restart docker

# Set env vars for tool CLIs
echo "export VAULT_ADDR=http://$IP_ADDRESS:8200" | sudo tee --append /root/.bashrc
echo "export NOMAD_ADDR=http://$IP_ADDRESS:4646" | sudo tee --append /root/.bashrc
