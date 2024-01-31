# auto generated file. DO NOT EDIT

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
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