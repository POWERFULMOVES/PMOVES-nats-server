# PMOVES NATS hub - thin image: stock nats-server + baked PMOVES config.
# No Go patches (spec 7a / 11). Tracks the official image for CVE currency;
# the fork's value is config + packaging, not a patched binary.
#
# Build context = this directory (pmoves/). Pin the base by digest in the
# consuming compose for reproducibility (fleet convention).
# 2.15.3 = newest maintained line (2026-11-11); multi-arch index digest, so the
# same pin serves amd64 hubs and arm64 Jetson leaves.
FROM nats:2.15.3-alpine@sha256:558394a23dd3c36f2d3a64b51865fd09908010e80a542cea5e75c2af543ed62a

# Baked hub config. resolver_preload.conf (public account JWTs) and the
# per-account .creds are MOUNTED at runtime (funnel-rendered / Docker secrets),
# never baked - see entrypoint validation.
COPY pmoves-nats.conf /etc/nats/pmoves-nats.conf
COPY --chmod=0755 entrypoint.sh /usr/local/bin/pmoves-nats-entrypoint.sh

# 4222 client - 7422 leafnodes - 8222 monitoring (publish LOOPBACK only) - 8080 websocket
EXPOSE 4222 7422 8222 8080

ENTRYPOINT ["/usr/local/bin/pmoves-nats-entrypoint.sh"]
