# BPOE Update — 3-Panel Handoff Protocol (2025-09-05)

## Intent
Minimize user effort during session handoff. Heavy session types CoWrap → zip lands in Downloads. Fresh session types CoUnWrap → picks best zip (addressed→ANY→newest), unpacks, and marks source as CoWrap_DELETABLE-*.zip.

## Commands (PS7)
- \CoWrap [-To <sessionId>|ANY]\ — create CoWrap zip + breadcrumbs.
- \CoUnWrap\ — consume newest addressed/ANY zip; rename original to \CoWrap_DELETABLE-*.zip\; archive copy under \~/Downloads/CoCacheLocal/archive\.
- \CoWraps\ — show outstanding vs handled zips.
- \CoSweep [-Days N] [-Purge]\ — cleanup old wraps, receipts, and local bus artifacts (default 21 days).

## Conventions
- Zips: \CoWrap-<UTC>-<from_session>-to-<to_session>.zip\
- Handled zips (safe to delete): \CoWrap_DELETABLE-<original>.zip\
- Breadcrumbs: \CoWrap.Breadcrumb-<from>.json\, \CoWrap.latest.json\, \CoUnwrap.Receipt-<to>.json\

## Safety / HumanGate
- Local only; no secrets in logs or packages.
- Append-only NDJSON event bus under \~/Downloads/CoCacheLocal/sessions\.
- Optional Agent tags (L/R/U) for single-PS7 multi-chat setups.

## 3-Panel Eligibility
Recommended: ≥32″ diag **or** ≥3200×2160 px. Otherwise operate as 2-panel.
