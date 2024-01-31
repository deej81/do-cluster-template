
# Add an A record to the domain for www.example.com.
resource "digitalocean_record" "bastion" {
    depends_on = [data.local_file.tailscale_ip]
    domain = var.domain_id
    type   = "A"
    name   = "bastion"
    value  = split("\n", trimspace(data.local_file.tailscale_ip.content))[0]
}