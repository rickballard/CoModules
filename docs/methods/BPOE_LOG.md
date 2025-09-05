
## Session log — 2025-09-05 15:30:39 -04:00
- Stabilized **Workbench launcher**: split `Start-CoCiviumWorkbench.ps1` → `Workbench-Inner.ps1`; zero popups; no here-strings.
- Converted **OE Status** to prompt-driven heartbeat; removed background timers; persisted profile hook.
- Added **Desktop & Start Menu** shortcuts targeting the launcher (no in-shell kills).
- Wrote **Preflight.ps1** (check-only) and documented usage.
- Fixed profile parse edge case (``$rel:`` → ``${rel}:``) and guarded optional imports.
- Updated **branch protection** (Minimal gating & admin bypass) and merged PR #347 in CoCivium; opened tracker #362.
- Appended BPOE and README guidance (DO blocks, prompt-driven OE, troubleshooting).
