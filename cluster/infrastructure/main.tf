terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_images" "cluster_server" {
  filter {
    key    = "private"
    values = ["true"]
  }
  filter {
    key    = "name"
    values = ["nomad_cluster"]
  }
  sort {
    key       = "created"
    direction = "desc"
  }
}

data "template_file" "user_data_server" {
  template = file("cluster/infrastructure/user-data-server.sh")

  vars = {
    nomad_servers_count = var.nomad_servers_count
    retry_join = chomp(
      join(
        " ",
        formatlist("%s=%s", keys(local.retry_join), values(local.retry_join)),
      ),
    )
  }
}

data "template_file" "user_data_client" {
  template = file("cluster/infrastructure/user-data-client.sh")

  vars = {
    retry_join = chomp(
      join(
        " ",
        formatlist("%s=%s ", keys(local.retry_join), values(local.retry_join)),
      ),
    )
  }
}

resource "digitalocean_droplet" "nomad_server" {
  count = var.nomad_servers_count
  image = data.digitalocean_images.cluster_server.images[0].id
  # Consul members name must be unique
  name   = "nomad-cluster-server-${count.index}"
  region = var.do_region
  size   = var.server_droplet_size
  user_data = data.template_file.user_data_server.rendered
  ssh_keys  = var.ssh_keys
  vpc_uuid  = var.vpc_config.id

  tags = [
    local.retry_join.tag_name
  ]
}

resource "digitalocean_droplet" "nomad_client" {
  count = var.nomad_clients_count
  image = data.digitalocean_images.cluster_server.images[0].id
  # Consul members name must be unique
  name   = "nomad-cluster-general-client-${count.index}"
  region = var.do_region
  size   = var.client_droplet_size
  user_data = data.template_file.user_data_client.rendered
  ssh_keys  = var.ssh_keys
  vpc_uuid  = var.vpc_config.id

  tags = [
    local.retry_join.tag_name
  ]
}

locals {
  cluster_droplet_ids = concat(
    digitalocean_droplet.nomad_client.*.id,
    digitalocean_droplet.nomad_server.*.id
  )
}

# Firewall
resource "digitalocean_firewall" "cluster_traffic" {
  name = "nomad-cluster-intra-traffic"

  droplet_ids = concat(
    digitalocean_droplet.nomad_client.*.id,
    digitalocean_droplet.nomad_server.*.id
  )

  #ssh from vpc - TODO change this to bastion only
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.vpc_config.ip_range]
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "1-65535"
    source_addresses = [var.vpc_config.ip_range]
  }
  inbound_rule {
    protocol           = "udp"
    port_range         = "1-65535"
    source_addresses = [var.vpc_config.ip_range]
  }
  inbound_rule {
    protocol           = "icmp"
    port_range         = "1-65535"
    source_addresses = [var.vpc_config.ip_range]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
