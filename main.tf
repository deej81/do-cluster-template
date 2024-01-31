terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_project" "project" {
  name = "ProjectName"
  resources = concat(
    [
      module.bastion_server.bastion_urn,
      digitalocean_domain.example_dot_com.urn,
      module.cluster_infrastructure.postgres_cluster_urn,
    ],
    module.cluster_infrastructure.cluster_droplet_urns,
  )
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

module "bastion_server" {
  source = "./bastion"
  do_token = var.do_token
  tailscale_key = var.tailscale_key
  domain_id = digitalocean_domain.example_dot_com.id
  vpc_id = digitalocean_vpc.cluster.id
  ssh_keys = concat([for key in digitalocean_ssh_key.user_key : key.fingerprint])
}

module "cluster_infrastructure" {
  source = "./cluster/infrastructure"
  do_token = var.do_token
  tailscale_key = var.tailscale_key
  vpc_config = {
    id = digitalocean_vpc.cluster.id
    ip_range = digitalocean_vpc.cluster.ip_range
  }
  ssh_keys = concat([for key in digitalocean_ssh_key.user_key : key.fingerprint])
}

module "custom_dns" {
  source = "./jobs/dns"
  domain_id = digitalocean_domain.example_dot_com.id
  private_ingress_ip = module.cluster_infrastructure.tailscale_ip_address
  public_ingress_ip = "none"
}
