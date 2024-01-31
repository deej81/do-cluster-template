

data "external" "github_user_keys" {
  program = ["bash", "-c", "curl -s https://api.github.com/users/${var.github_username}/keys | jq -c 'map({(.id | tostring): .key}) | add'"]
}

locals {
  # Decode the JSON object into a map and then extract the values (SSH keys)
  ssh_keys = values(data.external.github_user_keys.result)
}

resource "digitalocean_ssh_key" "user_key" {
  for_each  = toset(local.ssh_keys)
  name      = "GitHub Key ${each.key}"
  public_key = each.value
}