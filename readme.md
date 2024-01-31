
# Digital Ocean Nomad Cluster

This repository contains a [Terraform](https://www.terraform.io/) configuration to deploy a [Nomad](https://www.nomadproject.io/) cluster on [Digital Ocean](https://www.digitalocean.com/).

## Todo

- [ ] Convert to a copier template

## Usage

Not ready for general usage. For now if you really want to play with it the process is very convoluted:

### You will need
- docker
- a tailscale account and api token
- a digital ocean account and api token
- age (pronounced ah-geh) installed on your machine

### Steps

Clone the repo to your machine and make sure you have the prequisites installed / created.

```bash
./launch-deployer.sh
```
This script will initalise an age keypair and then launch a docker container with all the tools you need. It will also mount the current directory into the container so you can edit the terraform files on your machine and run terraform inside the container.

Once the container is running:

Create the base images for our virtual machines

```bash
make build-images
```
Next we create the basic infrastrucutre on Digital Ocean

```bash
make apply-infrastructure
```
This can be unreliable at times :-( If it fails just run it again. Unfortunately at times this may mean manually clearing down the infrastructure and starting again. The postgres cluster can be very slow to create, sometimes 20 minutes. Once completed this will have created everything you need in Digital Ocean. Once it is done you can ssh into the bastion server and use it as a jump to the other servers.

```bash
make connect
```

This creates tunnels to the running services on the cluster. You can now access the nomad ui at http://localhost:4646/, the consul ui at http://localhost:8500/ and the vault ui at http://localhost:8200/.

Next we need to initialise vault

```bash
make init-vault
make configure-vault
make connect-vault
```

step 1 here initialises the vault saving the unseal keys and root token to the secrets folder. step 2 configures vault with the nomad and consul secrets engines. Running the terraform under the vault folder. step 3 connects the vault to nomad.

Your network is now ready to run jobs. Start traefik by running 

```bash
nomad run jobs/traefik.nomad
```

Type `exit` to exit the docker image and everything stored in the secrets folder will be encrypted with age.

## Credit

This template leans very heavily on work by [@fmeringdal](https://github.com/fmeringdal) in this [project](https://github.com/fmeringdal/do-hashicorp-cluster) 




