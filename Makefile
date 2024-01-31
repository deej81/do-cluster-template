
SHELL := /bin/bash

build-images:
	cd bastion/image && packer init . && packer build .
	cd cluster/image && packer init . && packer build .

init-infrastructure:
	terraform init

plan-infrastructure: init-infrastructure
	terraform plan

apply-infrastructure: plan-infrastructure
	terraform apply

full-deploy: build-images apply-infrastructure connect-to-infrastructure

init-vault:
	cd cluster/vault && ./init-vault.sh && terraform init

configure-vault:
	source ./cluster/infrastructure/setup-db-env.sh && source ./cluster/vault/setup-vault-env.sh && cd cluster/vault && terraform apply

connect-vault:
	source ./cluster/vault/setup-vault-env.sh && cd cluster/infrastructure && ./connect-vault.sh

connect:
	cd cluster/infrastructure && ./setup-tunnels.sh

destroy:
	terraform destroy && rm -rf secrets && rm secrets.tar.gz.age && exit

deploy-jobs:
	for FILE in ./jobs/*.nomad.hcl; do \
		nomad job run $$FILE; \
	done

psql:
	source ./cluster/infrastructure/setup-db-env.sh && psql postgres://$${TF_VAR_db_username}:$${TF_VAR_db_password}@localhost:25060/ghostfolio
