output "tailscale_ip_address" {
  value = split("\n", trimspace(data.local_file.tailscale_ip.content))[0]
}

output "server_droplet_ips" {
  value = join(",", digitalocean_droplet.nomad_server[*].ipv4_address_private)
}

output "cluster_droplet_urns" {
  value = concat(
    digitalocean_droplet.nomad_client.*.urn,
    digitalocean_droplet.nomad_server.*.urn,
    [
      digitalocean_droplet.ingress_client.urn,
    ]
  )
}

output "ingress_droplet_ip" {
  value = digitalocean_droplet.ingress_client.ipv4_address_private
}

output "postgres_cluster_ip" {
  value = digitalocean_database_cluster.postgres-cluster.private_host
}

output "postgres_cluster_port" {
  value = digitalocean_database_cluster.postgres-cluster.port
}

output "postgres_cluster_database" {
  value = digitalocean_database_cluster.postgres-cluster.database
}

output "postgres_cluster_user" {
  value = digitalocean_database_cluster.postgres-cluster.user
}

output "postgres_cluster_password" {
  value = digitalocean_database_cluster.postgres-cluster.password
  sensitive = true
}

output "postgres_cluster_private_uri" {
  value = digitalocean_database_cluster.postgres-cluster.private_uri
  sensitive = true
}

output "postgres_cluster_urn" {
  value = digitalocean_database_cluster.postgres-cluster.urn
}