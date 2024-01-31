variable "vault_admin_password" {
  type     = string
  default = "admin"
}

variable "db_username" {
  type = string
  sensitive = true
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "postgres_ip" {
  type = string
}

variable "postgres_port" {
  type = string
}
