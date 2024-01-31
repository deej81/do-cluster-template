
# Directory and file paths
key_dir="$HOME/.dev"
key_file="$key_dir/dev"
secrets_folder="./secrets"
encrypted_secrets="./secrets.tar.gz.age"

# Function to check and generate dev key
check_generate_key() {
    # Check if 'age' is installed
    if ! command -v age &> /dev/null; then
        echo "Error: 'age' is not installed."
        echo "Please install 'age' from https://github.com/FiloSottile/age#installation"
        exit 1
    fi

    # Check if .wtc-dev directory exists, create if not
    if [ ! -d "$key_dir" ]; then
        mkdir "$key_dir"
        echo "Directory .dev created."
    fi

    # Check if dev key exists, create if not
    if [ ! -f "$key_file" ]; then
        # Placeholder for key generation command
        echo "Generating new dev key..."
        age-keygen -o $key_file  
        chmod 600 "$key_file"  # Set permissions to read/write for owner only
        echo "dev key created and permissions set."
    else
        echo "dev key already exists."
    fi
}

get_variable() {
    local var_name=$1
    local arg_value=$2
    local request_value_message=$3
    local env_value=$(eval echo "\$$var_name")

    if [ ! -z "$arg_value" ]; then
        # Argument value is provided, use it
        echo "Using $var_name from argument."
        eval "$var_name='$arg_value'"
    elif [ ! -z "$env_value" ]; then
        # No argument value, but environment variable is set, use it
        echo "Using $var_name from environment variable."
        eval "$var_name='$env_value'"
    else
        echo "$request_value_message"
        read -s $var_name
    fi

}

decrypt_secrets() {
   # Ensure the extraction directory exists
    if [ ! -d "$secrets_folder" ]; then
        mkdir -p "$secrets_folder"
        echo "Created directory: $secrets_folder"
    fi

    # Decrypt secrets and untar
    echo "Decrypting and extracting secrets..."
    age -d -i $key_file $encrypted_secrets | tar -xz -C $secrets_folder
    echo "Secrets decrypted and extracted."
}

initialise_secrets() {
    get_variable "DO_TOKEN" "$1" "Please enter your DigitalOcean personal access token:"
    get_variable "TAILSCALE_KEY" "$2" "Please enter your Tailscale key:"
    get_variable "GITHUB_USERNAME" "$3" "Please enter your GitHub username:"
    
    # Ensure the secrets folder exists
    if [ ! -d "$secrets_folder" ]; then
        mkdir "$secrets_folder"
        echo "Secrets folder created."
    fi

    # Write the tokens to a .env file in the secrets folder
    echo "Writing tokens to .env file in the secrets folder..."
    echo "DO_TOKEN=$DO_TOKEN" > "$secrets_folder/.env"
    echo "TAILSCALE_KEY=$TAILSCALE_KEY" >> "$secrets_folder/.env"
    echo "GITHUB_USERNAME=$GITHUB_USERNAME" >> "$secrets_folder/.env"
    echo "PKR_VAR_do_token=$DO_TOKEN" >> "$secrets_folder/.env"
    echo "PKR_VAR_tailscale_key=$TAILSCALE_KEY" >> "$secrets_folder/.env"
    echo "TF_VAR_do_token=$DO_TOKEN" >> "$secrets_folder/.env"
    echo "TF_VAR_tailscale_key=$TAILSCALE_KEY" >> "$secrets_folder/.env"
    echo "TF_VAR_github_username=$GITHUB_USERNAME" >> "$secrets_folder/.env"

    # Set file permissions for security
    chmod 600 "$secrets_folder/.env"

    echo ".env file created in the secrets folder with permissions set."
}

encrypt_secrets() {
    echo "Encrypting secrets..."
    public_key=$(grep -o 'age[0-9a-zA-Z+\/=-]*' $key_file)

    # Navigate into the secrets folder and create the tarball
    (cd $secrets_folder && tar cvz .) | age -r $public_key > $encrypted_secrets
    rm -rf $secrets_folder
    echo "Secrets encrypted."
}


validate_ssh() {
    #check for SSH_AUTH_SOCK
    if [ -z "$SSH_AUTH_SOCK" ] ; then
        echo "SSH_AUTH_SOCK is not set. Please run 'eval \$(ssh-agent)' and 'ssh-add' before running this script. (use 'export SSH_AUTH_SOCK=~/.1password/agent.sock' if using 1Password)"
        exit 1
    fi
}

# ensure the SSH_AUTH_SOCK is set so docker container can use it
validate_ssh

# Check age key has been initialised on this machine
check_generate_key

# load existing secrets or create a new setup
if [ -d "./secrets" ]; then
    echo "!! SECRETS LEFT UNENCRYPTED, you must terminate the local deployer session by calling 'exit'!!"
else
    if [ -f "$encrypted_secrets" ]; then
        decrypt_secrets
    else
        initialise_secrets $1 $2 $3
    fi
fi

# Run the local deployer container - this is a bit messy, don't know why I have to have the separate docker-compose.yml file exec command
docker compose -f ./local-deployer/docker-compose.yml up --build local-deployer -d --wait
docker compose -f ./local-deployer/docker-compose.yml exec -w /deployer local-deployer /bin/bash
docker compose -f ./local-deployer/docker-compose.yml down

# Encrypt secrets again on exit
encrypt_secrets