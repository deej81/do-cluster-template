resource "digitalocean_database_cluster" "postgres-cluster" {
  name       = "postgres-cluster"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = var.do_region
  node_count = 1
  private_network_uuid = var.vpc_config.id
}

resource "digitalocean_database_db" "postgres" {
  cluster_id = digitalocean_database_cluster.postgres-cluster.id
  name       = "postgres"
}

resource "digitalocean_database_firewall" "postgres-cluster-firewall" {
  cluster_id = digitalocean_database_cluster.postgres-cluster.id

  rule {
    type  = "ip_addr"
    value = var.vpc_config.ip_range
  }
}