
data "digitalocean_images" "bastion-image" {
  filter {
    key    = "private"
    values = ["true"]
  }
  filter {
    key    = "name"
    values = ["bastion-image"]
  }
  sort {
    key       = "created"
    direction = "desc"
  }
}

data "template_file" "init-bastion" {
  template = file("./bastion/scripts/cloud-init-bastion.sh")

  vars = {
    tailscale_key = var.tailscale_key
  }
}

resource "digitalocean_droplet" "bastion_server" {
  image = data.digitalocean_images.bastion-image.images[0].id
  name   = "bastion-server"
  region = var.do_region
  size   = var.server_droplet_size
  user_data = data.template_file.init-bastion.rendered
  ssh_keys  = var.ssh_keys
  vpc_uuid  = var.vpc_id
}

resource "null_resource" "download_file" {
  depends_on = [digitalocean_droplet.bastion_server]

  provisioner "local-exec" {
    command = <<EOF
      #!/bin/bash
      while ! ssh -o StrictHostKeyChecking=no root@${digitalocean_droplet.bastion_server.ipv4_address} test -f /tmp/tailscale-ip.txt; do
        echo "Waiting for file /tmp/tailscale-ip.txt to be present on bastion server..."
        sleep 5
      done
      scp -o StrictHostKeyChecking=no root@${digitalocean_droplet.bastion_server.ipv4_address}:/tmp/tailscale-ip.txt /secrets/bastion-tailscale-ip.txt
    EOF
  }
}

data "local_file" "tailscale_ip" {
  depends_on = [null_resource.download_file,digitalocean_droplet.bastion_server]
  filename = "/secrets/bastion-tailscale-ip.txt"
}

output "tailscale_ip_address" {
  value = split("\n", trimspace(data.local_file.tailscale_ip.content))[0]
}

resource "digitalocean_firewall" "bastion-firewall" {
  depends_on = [null_resource.download_file]
  name = "bastion-firewall"

  droplet_ids = [digitalocean_droplet.bastion_server.id]
  
	# 443 needed for updates and tailscale
  outbound_rule {
    protocol = "tcp"
    port_range = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

	# 80 needed for updates
	outbound_rule {
    protocol = "tcp"
    port_range = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

	# needed for DNS resolution
	outbound_rule {
    protocol = "udp"
    port_range = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
	
	# needed to jump to webhosts
	outbound_rule {
    protocol = "tcp"
    port_range = "22"
		destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}