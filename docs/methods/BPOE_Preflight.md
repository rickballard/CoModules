# BPOE Preflight (quiet, idempotent)
- Runs at session start via Workbench audit when present.
- Checks profile parse, prompt safety, exit hook, absence of OE timers, and Workbench bits.
- Writes to **docs/methods/BPOE_LOG.md** only if issues are found (no prompt spam).
- Manual run: `& tools\Test-BPOE.ps1 -Quiet`

> See **BPOE_ThreePanel_Handoff.md** for CoWrap/CoUnWrap rules (2025-09-05).
