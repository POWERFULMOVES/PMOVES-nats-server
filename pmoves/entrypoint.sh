#!/bin/sh
# PMOVES NATS hub entrypoint — fail fast if the trust material isn't mounted.
# The account JWTs (resolver_preload.conf) and per-user .creds are provided at
# runtime (funnel-rendered / Docker secrets), never baked into the image.
set -e

CONF=/etc/nats/pmoves-nats.conf
RESOLVER=/etc/nats/resolver_preload.conf

if [ ! -f "$RESOLVER" ]; then
  echo "FATAL: $RESOLVER not mounted." >&2
  echo "  Render it from the nsc-minted account JWTs and mount it, e.g.:" >&2
  echo "    nsc generate config --mem-resolver > resolver_preload.conf   # public JWTs" >&2
  echo "  then bind/secret-mount it to $RESOLVER (see pmoves/README.md)." >&2
  exit 1
fi

exec nats-server -c "$CONF" "$@"
