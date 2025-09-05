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
