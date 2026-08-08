# PMOVES NATS — the POWERFULMOVES treatment

Stock `nats-server` (this repo tracks `nats-io/nats-server` upstream, **no Go patches**) given
the PMOVES treatment: everything good-for-PMOVES turned **on**, wired to the PMOVES services, with
CHIT as an orthogonal payload-trust layer. Upstream repo **+** PMOVES **=** POWERFULMOVES.

This `pmoves/` directory is the PMOVES config + packaging. The runtime image is the official
`nats:2.11-alpine` with our config baked in — the fork exists to carry this config, track upstream
for CVE currency (fork-sync discipline), and be the home for any future PMOVES-specific work.

## What's turned on (`pmoves-nats.conf`)

| Feature | Why |
|---|---|
| **Accounts** (SYS/CORE/EDGE/CLOUD via memory resolver) | Multi-tenant trust zones — transport-trust boundary at the network edge |
| **Leafnodes** (`listen: 7422`) | Real leaf federation — the thing that was never actually working (see spec) |
| **JetStream** | Durable streams for CHIT trails, tokenism, mesh |
| **Websocket** (`8080`) | A2UI / browser clients over the tailnet |
| **MQTT** (ready, commented) | Edge/IoT devices (jetson prosodic ears, sensors) — enable per-account |
| **SYS system account** | Guards `$SYS.*`; fixes the historically-unguarded monitoring gap |

CHIT signing rides **inside** messages (`chit.signed.v1`, `chit.cgp.v1`) — the account model says
who may cross a boundary; the CHIT signature proves origin. A leaf message is trusted only if it
clears **both** gates.

## Trust material (never in git)

- Minted with `nsc`: operator **PMOVES** → SYS/CORE/EDGE/CLOUD accounts → user `.creds`.
- Account **JWTs** (public) render into `resolver_preload.conf` via `nsc generate config --mem-resolver`,
  injected by PMOVES.AI secrets-funnel at deploy time (see `examples/resolver_preload.conf.example`).
- Operator seed + user `.creds` are **file-mounted Docker secrets** (custody per PMOVES #1901;
  CHIT-vault custody is the follow-up). They live in the CHIT vault, never here.

## Run (hub)

```
docker build -t pmoves-nats:local pmoves/
docker run --rm -p 4222:4222 -p 7422:7422 -p 127.0.0.1:9223:8222 -p 8080:8080 \
  -v $PWD/resolver_preload.conf:/etc/nats/resolver_preload.conf:ro \
  -v /path/to/creds:/etc/nats/creds:ro \
  -v pmoves-nats-jetstream:/data/jetstream \
  pmoves-nats:local
```
Publish `8222` **loopback only** (never `0.0.0.0`). See `examples/` for the leaf-edge / leaf-cloud
remote configs and the compose stanza the PMOVES.AI repo consumes.

## References
- Spec: `PMOVES.AI pmoves/docs/specs/nats-accounts-leaf-topology-v0-spec-2026-08-07.md`
- Runbook: `PMOVES.AI pmoves/docs/operations/NATS_LEAF_TOPOLOGY_ROLLOUT_RUNBOOK.md`
- NATS: accounts / leafnodes / JWT memory resolver (official docs)
