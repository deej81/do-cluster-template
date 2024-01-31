
# Place your custom A records here

resource "digitalocean_record" "example" {
    domain = var.domain_id
    type   = "A"
    name   = "example"
    value  = var.private_ingress_ip
}
