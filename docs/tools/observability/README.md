# Observability (v0.1)

We log request/response digests (no secrets) to `tools/logs/telemetry.ndjson`.  
Next steps: add Langfuse or OTEL exporter at the façade boundary.

## Planned fields
- `ts` (ms), `event`, `digest`, `fields.method|path|query|status`

## TODO
- Env-gated Langfuse client (disabled by default)
- Per-endpoint cost + latency tags
