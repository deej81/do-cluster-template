variable "do_token" {
  type = string
  sensitive = true
}

variable "tailscale_key" {
  type = string
  sensitive = true
}

variable "do_region" {
  type = string
  default = "lon1"
}

variable "droplet_name" {
  type = string
  default = "bastion-imager"
}

variable "snapshot_name" {
  type = string
  default = "bastion-image"
}

