# CoAgent Advisory — 3-Panel + Heartbeat Interop (2025-09-05)

**Summary.** Ship an advanced CoAgent mode that: (a) runs two chats flanking one PS7, (b) coordinates via a local append-only bus, and (c) standardizes handoff with CoWrap/CoUnWrap. This PoC doubles as a stepping stone to Heartbeat/CoCacheGlobal.

## User Experience
- **One command each side**: origin types \CoWrap\; receiver types \CoUnWrap\. Zero clipboard.
- Clear state in Downloads: outstanding vs \DELETABLE\ zips.
- Works even when chats don’t overlap in time; breadcrumbs/receipts ensure discoverability.

## Engineering
- Local bus: \~/Downloads/CoCacheLocal/sessions/<session>/log.ndjson\.
- Handoff package: handover.json (repo/branch/status, last events), diffs, status, changed files.
- Deterministic selection: addressed → ANY → newest.
- Cleanup: \CoSweep\ with age threshold.

## Guardrails
- No secrets; local-only by default.
- Eligibility gate for 3-Panel (≥32″ or ≥3200×2160).
- Future Heartbeat: promote NDJSON API to signed, append-only service; safe-haven hosting; org governance.

## Next Increments
- Auto-address peer if \CoWrap.latest.json\ names a receiver.
- Auto-open \NEXT.md\ from handover content on Unwrap.
- Optional watcher (manual start/stop) for auto-CoPong.


<!-- 2025-09-05 :: training + pingpong + naming policy -->
## User Training: Heavy/Fresh & Daily Rhythm

- **Heavy pane** does the work; **fresh pane** receives wraps.  
- Users should expect a **button on each DO block** to autopaste into PS7.  
- **PS7 autolaunch**: CoAgent starts PS7 once and keeps it resident while the session is active.

## Async CoPingPong Today vs Tomorrow

- **Today (local)**: CoWrap/CoUnWrap + `CoWrap.latest.json` + NDJSON bus. Two+ chats can coordinate without clipboard.  
- **Tomorrow (global)**: CoCacheGlobal (signed append-only), multi-agent routing, org retention policies.

## Session Naming Policy (Tab/Pane Titles)

- Target format: **`<purpose> • <YYYY-MM-DD> • <shortid>`**.  
- CoAgent MUST ensure uniqueness at creation time (append timestamp + shortid), and SHOULD refresh titles after long idles.  
- This label surfaces at: chat tab title, panel header, wrap receipts, and DO block headers.

## Guardrails & Controls

- Local-only by default; no secrets in wraps.  
- Watcher is opt-in; manual `CoUnWrap` always available.  
- Downgrade to 2-panel when screen/attention is limited.

### BPOE Status & Demark (standard footer)
Add this at the end of each DO block:
\\\powershell
Write-BPOEStatusLine -Color
Write-BPOELine -Gradient Sunset -Char '─'
\\\
<!-- 2025-09-05 :: injected by CoAgent lead -->
