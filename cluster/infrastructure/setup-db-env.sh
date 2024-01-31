#!/bin/bash

# extract outputs into needed environment variables

export TF_VAR_postgres_ip=$(terraform output -raw postgres_cluster_ip)
export TF_VAR_postgres_port=$(terraform output -raw postgres_cluster_port)
export TF_VAR_db_username=$(terraform output -raw postgres_cluster_user)
export TF_VAR_db_password=$(terraform output -raw postgres_cluster_password)