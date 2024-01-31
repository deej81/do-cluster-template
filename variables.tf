variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "tailscale_key" {
  description = "Tailscale authentication key"
  type        = string
  sensitive   = true
}

variable "do_region" {
  description = "DigitalOcean region for the resources"
  type        = string
  default     = "lon1"
}

variable "github_username" {
  type = string
  sensitive = true
}

variable "server_droplet_size" {
  description = "Size of the droplet for the server"
  type        = string
  default = "s-1vcpu-1gb"
}
