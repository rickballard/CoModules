# Tools Register (v0.1)

Purpose. Catalog external tools/services we evaluate or adopt, with data contracts, cost, lock-in, and exit plans.  
Status codes. R = Recommend  ·  A = Adopt (in use)  ·  B = Borrow ideas only  ·  H = Hold.

| Category       | Tool                    | Status | Primary Use                 | Data Surface            | Exit Plan                           |
|---             |---                      |---     |---                          |---                      |---                                   |
| Coding Agent   | OpenAI Codex        | A      | PR drafts & refactors       | HTTPS → CoAgent façade  | Swap to local agent (Ollama/vLLM)    |
| Video Gen      | OpenAI Sora         | R      | 10–20s outreach clips       | Prompts & assets only   | Switch to alt video gen; keep prompts|
| GPT Front Door | GPTs + Actions      | R      | Onboarding & shallow ops    | HTTPS → façade only     | Disable Actions; use docs only       |
| IDE Assist     | Copilot / Cody / Cursor | B      | Local code help             | Local editor context    | Uninstall; no retained data          |
| Observability  | Langfuse            | R      | LLM trace/cost logs         | Request/response digests| Export via OpenTelemetry             |
| Vector Store   | Qdrant / pgvector   | R      | Retrieval                   | Redacted content only   | Dump embeddings; reindex elsewhere   |
| Safety         | Presidio            | R      | PII/secret redaction        | Local pipeline          | Keep rules in repo                   |
| SecOps         | gitleaks, Syft  | A      | Secret scan, SBOM           | Repo/CI                 | Keep artifacts in CI                 |
| Policy         | OPA (Rego)          | R      | Policy-as-code              | Local/CI                | Inline policies in repo              |
