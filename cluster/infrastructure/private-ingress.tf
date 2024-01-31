
data "template_file" "user_data_ingress" {
  template = file("cluster/infrastructure/user-data-ingress.sh")

  vars = {
    tailscale_key = var.tailscale_key
    retry_join = chomp(
      join(
        " ",
        formatlist("%s=%s ", keys(local.retry_join), values(local.retry_join)),
      ),
    )
  }
}

resource "digitalocean_droplet" "ingress_client" {
  image = data.digitalocean_images.cluster_server.images[0].id
  # Consul members name must be unique
  name     = "nomad-cluster-ingress"
  region   = var.do_region
  vpc_uuid = var.vpc_config.id
  size   = var.ingress_droplet_size
  user_data = data.template_file.user_data_ingress.rendered
  ssh_keys  = var.ssh_keys

  tags = [
    local.retry_join.tag_name
  ]
}


resource "null_resource" "download_file" {
  depends_on = [digitalocean_droplet.ingress_client]

  provisioner "local-exec" {
    command = <<EOF
      #!/bin/bash
      while ! ssh -o StrictHostKeyChecking=no root@${digitalocean_droplet.ingress_client.ipv4_address} test -f /tmp/tailscale-ip.txt; do
        echo "Waiting for file /tmp/tailscale-ip.txt to be present..."
        sleep 5
      done
      scp -o StrictHostKeyChecking=no root@${digitalocean_droplet.ingress_client.ipv4_address}:/tmp/tailscale-ip.txt /secrets/ingress-tailscale-ip.txt
    EOF
  }
}

data "local_file" "tailscale_ip" {
  depends_on = [null_resource.download_file,digitalocean_droplet.ingress_client]
  filename = "/secrets/ingress-tailscale-ip.txt"
}


resource "digitalocean_firewall" "private_ingress" {
  depends_on = [null_resource.download_file]
  name = "nomad-cluster-ingress"

  droplet_ids = [digitalocean_droplet.ingress_client.id]

  #ssh from vpc - TODO change this to bastion only
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.vpc_config.ip_range]
  }

  # All traffic from cluster
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


