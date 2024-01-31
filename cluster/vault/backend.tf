terraform {
  backend "local" {
    path = "/secrets/vault-terraform.tfstate"
   }
}