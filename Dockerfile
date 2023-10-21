FROM ghcr.io/tailscale/tailscale:stable

COPY tailscale-entrypoint.sh /usr/local/bin/tailscale-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/tailscale-entrypoint.sh"]
