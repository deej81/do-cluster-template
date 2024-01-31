

while fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
  echo "Waiting for apt lock"
  sleep 5
done

curl -fsSL https://tailscale.com/install.sh | sh

# TODO: make this more reliable, writes the file even if tailscale install fails
TAILSCALE_KEY=$1
tailscale up --authkey $TAILSCALE_KEY --hostname private-ingress
tailscale ip -4 >> /tmp/tailscale-ip.txt