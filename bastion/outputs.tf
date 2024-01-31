output "bastion_ip" {
  value = digitalocean_droplet.bastion_server.*.ipv4_address
}

output "bastion_id" {
  value = digitalocean_droplet.bastion_server.*.id
}

output "bastion_urn" {
  value = digitalocean_droplet.bastion_server.urn
}