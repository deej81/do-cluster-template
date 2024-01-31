
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_record" "example" {
    domain = var.domain_id
    type   = "A"
    name   = "example"
    value  = var.private_ingress_ip
}

variable "domain_id" {
  description = "DigitalOcean domain ID"
  type        = string
}

variable "private_ingress_ip" {
  description = "IP address of the private ingress server"
  type        = string
}

variable "public_ingress_ip" {
  description = "IP address of the public ingress server"
  type        = string
}