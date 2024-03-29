source "digitalocean" "default" {
  api_token     = var.do_token
  region        = var.do_region
  image         = "ubuntu-20-04-x64"
  size          = "s-1vcpu-1gb"
  ssh_username  = "root"
  snapshot_name = var.snapshot_name
  droplet_name  = var.droplet_name
}

build {
  sources = ["source.digitalocean.default"]

  provisioner "shell" {
    inline = [
      "sudo mkdir /ops",
      "sudo chmod 777 /ops"
    ]
  }

  provisioner "file" {
    source      = "../scripts"
    destination = "/ops"
  }

  provisioner "shell" {
    script = "../scripts/setup.sh"
  }

  provisioner "ansible" {
    playbook_file = "../scripts/tailscale.yml"
    ansible_env_vars = ["TAILSCALE_KEY=${var.tailscale_key}"]
  }
}

packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.0"
      source  = "github.com/digitalocean/digitalocean"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}