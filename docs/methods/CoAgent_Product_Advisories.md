# CoAgent — Product Advisories (BPOE-aligned)

## Ephemeral policy (auto-uninstall ~24h)
- Enforced at **launch**; no timers; reinstall when expired.

## Silent Ops
- Set `COAGENT_SILENT=1` to suppress prompts in CoAgent contexts.
- All actions remain idempotent and logged minimally.
# CoAgent — Product Advisories (BPOE-aligned)

## Ephemeral agent (~24h)
- Treat installs older than ~24h as expired; enforcement happens at launch (no background timers).
- Expect quick reinstall as a guardrail.

## Silent Ops
- Set `COAGENT_SILENT=1` to suppress prompts; all interaction stays in chat.

## Cross-pane coordination
- CoClaim writes `Downloads\CoTemp\CoClaim_<session>.json` + `CoClaim.latest.json` with repo/branch/paths/message.
- CoPulse writes `CoStatus.latest.json` so other panes can see state (HG/Jobs/Events/Timers).

## Handoff
- Prefer CoWrap/CoUnWrap flow; pointer is `Downloads\CoWrap.latest.json`.
