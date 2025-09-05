# CoAgent — Ephemeral Agent (Auto-Uninstall ~24h)

**What:** CoAgent is an **ephemeral agent** (ephemeral runner / transient JIT agent).
It installs only what's needed, runs briefly, and then requires **reinstall after ~24h**.

**How enforced:** At **launch** (no background timers) via `Invoke-CoAgentExpiryEnforce -MaxHours 24`.
If expired, the launcher silently handles remediation (under `COAGENT_SILENT=1`) or surfaces a brief note.