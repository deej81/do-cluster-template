variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive = true
}

variable "tailscale_key" {
  description = "Tailscale authentication key"
  type        = string
  sensitive = true
}

variable "do_region" {
  description = "DigitalOcean region for the resources"
  type        = string
  default     = "lon1"
}

variable "server_droplet_size" {
  description = "Size of the droplet for the server"
  type        = string
  default = "s-1vcpu-1gb"
}

variable "domain_id" {
  description = "DigitalOcean domain ID"
  type        = string
}

variable "vpc_id" {
  description = "DigitalOcean VPC ID"
  type        = string
}

variable "ssh_keys" {
  description = "SSH keys to add to the droplet"
  type        = list(string)
}

