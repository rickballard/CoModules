Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$branch = git branch --show-current
$prUrl  = "https://github.com/rickballard/CoModules/pull/16"
$path   = "docs/SESSION_SUMMARY_20250905.md"
$body = @"
# Session Summary — 2025-09-05

## What we did
- Landed **CoPing** (tools/BPOE) and documented usage.
- Added **BPOE Session Card** with handy links.
- Added **BPOE wisdom log** and appended entries throughout.
- Created **labels** and updated **PR #16**.
- Hardened **heartbeat test**; added **CoPong linter** (ensures CoPong line when docs reference `./docs/do/*.ps1`).
- Added **CODEOWNERS** for BPOE surfaces (if present).
- Added **CoPong rule** to Session Card and **DO Authoring** notes.

## What we fixed just now
- Wrapped `scripts/pr-admin-merge.ps1` and `scripts/pr-solo-merge.ps1` with `Invoke-WithHeartbeat` (idempotent).
- Re-ran local tests and nudged CI.

## What remains / handoff to grand migration
- Watch CI for green on branch **$branch**; merge **PR #16** when green: $prUrl
- Roll CoPing & heartbeat/CoPong norms across other repos (see Issues #17, #18).
- Keep `main` **unprotected** until the grand migration completes; then enable minimal protections (PS Tests).
- Future: auto-render CoPong in sets via CoAgent (not yet; repo linter enforces meanwhile).

## Pointers (this branch)
- BPOE hub: https://github.com/rickballard/CoModules/blob/$branch/docs/methods/BPOE_SESSION_CARD.md
- Wisdom log: https://github.com/rickballard/CoModules/blob/$branch/docs/methods/BPOE_WISDOM.md
- This summary: https://github.com/rickballard/CoModules/blob/$branch/docs/SESSION_SUMMARY_20250905.md
"@
if(Test-Path $path){ Set-Content -Path $path -Value $body -Encoding utf8 } else { $body | Set-Content -Path $path -Encoding utf8 }
