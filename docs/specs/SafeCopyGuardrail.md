# SafeCopy Guardrail (CoAgent / BPOE UI)

## Problem
The code-block header “Copy” can capture partial renders while a block is still streaming, leading to broken pastes and accidental mid-DO firing.

## Decision
Remove reliance on header copy. Provide a “Copy (verified)” button below each block. It only renders after the block is fully rendered and verified stable.

## UX
- Header “Copy” hidden/ignored by policy.
- Below-block row shows after completion:
  - Copy (verified) — copies text after stability checks.
  - Save to CoTemp — writes `<stamp>_blockN.txt` via backend if available.
- Small note: “Verified at HH:MM:SS — length L, sha256 abc…”.

## When is a block “fully rendered”?
- The frontend sets `data-render-complete="true"` on the block when its stream ends (or fires a `block:complete` event).
- Additionally, a stability window: no DOM/text changes for ≥ 500ms.
- Optionally compare computed SHA-256/length to metadata (if backend provides).

## Acceptance Criteria
- The below-block button never appears while the block is streaming.
- Copy result matches the final on-screen content (length+sha256).
- No accidental partial copies in manual testing with slow/fast streams.
- Works with very large blocks and code that reflows.

## Telemetry / Breadcrumbs
- Optional: write a `CoCopy.latest.json` in CoTemp with: `{ ts, len, sha256, source }`.
- Shows alongside existing Breadcrumbs (`CoWrap.latest.json`, `CoPing.latest.json`).

## Notes
- This is a UI guardrail; the queue-on-busy CoPing logic remains server/agent-side.
- For ChatGPT host UIs we can’t patch, this spec applies to CoAgent/CoCivium UIs and extensions only.