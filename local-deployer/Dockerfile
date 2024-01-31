FROM ubuntu:latest

# Update
RUN apt-get -y update \
	&& apt-get -y dist-upgrade

# Install some prerequisites and utils
RUN apt-get update && \
	apt-get -y install \
		curl \
		make \
		net-tools \
		dnsutils \
		gnupg2 \
		lsb-release \
		software-properties-common \
		vim \
		openssh-client \
		jq \
		unzip \
		postgresql-client
	

# Install vault, nomad, terraform, packer and consul
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt-get -y install vault nomad consul terraform packer

# https://github.com/hashicorp/vault/issues/10924#issuecomment-846123151
RUN apt-get install --reinstall -y vault

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
	&& apt-get -y install --no-install-recommends \
	python3 \
	python3-pip \
	&& pip3 install ansible \
	&& apt-get clean autoclean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

RUN ansible-galaxy install artis3n.tailscale

ENV CONSUL_HTTP_ADDR=127.0.0.1:8500
ENV VAULT_ADDR=http://127.0.0.1:8200
ENV NOMAD_ADDR=http://127.0.0.1:4646

COPY local-deployer-entry.sh /scripts/local-deployer-entry.sh
RUN chmod +x /scripts/local-deployer-entry.sh
ENTRYPOINT ["/scripts/local-deployer-entry.sh"]
