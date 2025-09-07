# Tool Guardrails (v0.1)

Principles. Repo-first.  Minimal HTTPS façade.  HumanGate before irreversible ops.  Secrets never in prompts.  Redact by default.

Data Contract.
- External tools (GPT Actions, Codex) may call only `https://coagent.local/` allowlisted endpoints.
- Every request carries scoped bearer tokens; over-broad scopes are rejected.
- Tracing: request/response digests logged to Langfuse + CI artifacts (no raw secrets).

Retention & Training. Use ChatGPT Business/Enterprise/API data controls; disable training on our content; set minimal retention.

Vendor Exit. Maintain local fallbacks (Ollama/vLLM, pgvector/Qdrant).  Store prompts, schemas, and assets in-repo.
