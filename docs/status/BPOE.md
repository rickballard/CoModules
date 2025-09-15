<<<<<<< Updated upstream

- **GM PR bloat:** OK: none open — _as of 2025-09-12 02:43:37Z_


- **GM PR bloat:** OK: none open — _as of 2025-09-12 02:47:47Z_
=======
﻿
- **GM PR bloat:** OK: none open Ã¢â‚¬â€ _as of 2025-09-12 02:43:37Z_


- **GM PR bloat:** OK: none open Ã¢â‚¬â€ _as of 2025-09-12 02:47:47Z_

## Wisdom Log
### 2025-09-12 00:49 [session-close]
- **Watcher**: added -Root param + robust fallbacks for pasted runs; clear PS7 hint; logs to CoTemps/status/watcher.log.
- **Queueing**: Process-CoQueue.ps1 PS5-safe patterns; session **fence** respected; lock-claiming & hand-back OK.
- **Hotkeys/CoNames**: CONAMES.json stable; context trigger writes sid.
- **BPOE guard**: DO-Precheck.ps1 throws on fail; .hooks/pre-commit LF; workbench preflight warns if tools/hooks missing.
- **Known rough edges (logged)**: (a) $PSCommandPath empty when pasted, (b) PS5 ternary/multi-filter incompat, (c) CRLF/LF drift, (d) attempted $PID write in panel pairer.
- Marking this session **successful + closed**; further mediation can key off these notes.
### 2025-09-11 23:36 [guard enforced, hooks, conames]
- **Precommit guard** now *blocks* unsafe commits (DO-Precheck throws; .hooks/pre-commit runs with LF).
- **Workbench** hardened (null-safe summary) + heartbeat OK.
- **CoNames** finalized with explainer tags for onboarding.
### 2025-09-11 23:06 [workbench, legal, conames]
- Fixed **pre-commit hook**; added **Start-Workbench.ps1** (heartbeat + CoHotkeys + AI prefs + precheck summary).
- Added **TERMS_OF_ENGAGEMENT.md** and **AI_VENDOR_USE.md**.
- Tutorial now includes **CoNames** table (CoGoSession / CoGoAll / CoPaneLink / CoTabSet / CoPingStatusBPOE / CoPrtScrn).
### 2025-09-11 22:51 [reliability, ai-prefs]
- Added **DO-Precheck** (PSScriptAnalyzer + AST safety + Pester) and a **pre-commit hook**.
- Heartbeat script (**Start-CoHeartbeat.ps1**) writes \CoTemps\status\hb.json\.
- Pinned preferred model in **docs/status/AI_PREFS.json** (for traceability).




- **GM PR bloat:** OK: none open ï¿½ _as of 2025-09-12 03:08:17Z_


- **GM PR bloat:** OK: none open ï¿½ _as of 2025-09-12 03:17:09Z_


- **GM PR bloat:** OK: none open ï¿½ _as of 2025-09-12 03:29:53Z_


>>>>>>> Stashed changes


- **GM PR bloat:** OK: none open — _as of 2025-09-12 17:58:01Z_


- **GM PR bloat:** OK: none open — _as of 


- **GM PR bloat:** OK: none open — _as of 
- [2025-09-12T20:24:28.6200092Z] Nightly refresh queued


- **GM PR bloat:** OK: none open — _as of 
- [2025-09-12T20:29:55.9208065Z] Nightly refresh queued


- **GM PR bloat:** OK: none open — _as of 
- [2025-09-13T17:42:57.6072114Z] UX: standardize 5 blank lines between CoPing/CoPong blocks in PS7 transcripts.
- [2025-09-13T19:11:09.3398882Z] UX: Adopt 'CoPong Demark' — 2 blank lines, rainbow rule with label, 2 blank lines. Use: CoPongDemark or alias 'cpd'.
- [2025-09-13T19:19:19.2746391Z] UX: Adopt 'CoPong Demark' — 2 blank lines, rainbow rule with label, 2 blank lines. Use: CoPongDemark or alias 'cpd'.
- [2025-09-14T00:46:43.4511397Z] CoTemp messages: use top-level 'inbox\\*.json' with keys: kind,to,session,tag,ts,summary,details.


- **GM PR bloat:** OK: none open — _as of 


- **GM PR bloat:** OK: none open — _as of 


- **GM PR bloat:** OK: none open — _as of 
