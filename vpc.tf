resource "digitalocean_vpc" "cluster" {
  name     = "bastion-vpc"
  region   = var.do_region
  ip_range = "192.168.10.0/24"
}
