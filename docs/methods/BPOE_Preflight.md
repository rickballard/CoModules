# BPOE Preflight (quiet, idempotent)
- Runs at session start via Workbench audit when present.
- Checks profile parse, prompt safety, exit hook, absence of OE timers, and Workbench bits.
- Writes to **docs/methods/BPOE_LOG.md** only if issues are found (no prompt spam).
- Manual run: `& tools\Test-BPOE.ps1 -Quiet`

> See **BPOE_ThreePanel_Handoff.md** for CoWrap/CoUnWrap rules (2025-09-05).


<!-- 2025-09-05 :: 3-panel preflight + anti-bloat hygiene -->
## 3-Panel Readiness (Preflight)

- Display: ≥32″ or ≥3200×2160 **required** for 3-panel; else default to 2-panel.
- PS7: single shared instance; verify minimal profile; NDJSON bus writeable.
- CoCacheLocal: present under Downloads/CoCacheLocal (or overridden `COCACHE_DOWNLOADS`).

## Anti-Bloat Hygiene & Daily Retirement

- Work in a **heavy** pane but **retire daily** (≤1 day) or on lag.  
- Hand-off routine: `CoWrap` → close heavy tab → open **fresh** pane → `CoUnWrap` (or watcher).  
- Rationale: keeps context crisp, reduces hallucination risk, preserves reproducible handovers.
