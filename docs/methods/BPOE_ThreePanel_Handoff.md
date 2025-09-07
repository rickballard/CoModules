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


<!-- 2025-09-05 :: heavy/fresh/autopaste/watcher/identity -->
## Heavy vs Fresh Pane (BPOE Model)

- **Heavy pane** = the “working” chat that accumulates context (and bloat).  
  - **Rule:** retire after ≤ 1 day of work or when it feels sluggish.  
  - **Action:** run **`CoWrap`** to package state → zip lands in Downloads (or `CoTemp`), then close the tab.
- **Fresh pane** = the “receiver” chat with minimal context.  
  - **Action:** `CoUnWrap` (or let the **auto-pickup watcher** do it) to import the newest addressed/ANY wrap.

> Both panes share the same PS7 instance. Coordination is **file-based** (pointer + zips + NDJSON bus).

## Autopaste Buttons & PS7 Autolaunch

- Each **DO** block in docs/tasks may expose an **“Autopaste to PS7”** button.  
- If **CoAgent** is active, PS7 is **auto-launched once** and stays up for the session; subsequent buttons paste/execute without relaunch.
- Safety: commands are **idempotent**, local-only, and avoid leaving PS7 in continuation prompts.

## Asynchronous CoPingPong (Human-Gate)

- Today: interop via **file bus (NDJSON)** under `~/Downloads/CoCacheLocal/sessions`, **wrap zips**, and the **pointer** `CoWrap.latest.json`.  
- Tomorrow: promote to **CoCacheGlobal** for org-wide, signed, append-only events.  
- Multiple chats (2 for now; N later) can **HumanGate-async CoPingPong** via the bus. Heavy builds a wrap; fresh consumes.

## Auto-Pickup (optional but recommended)

- The **watcher** listens for `CoWrap*.zip` and `CoWrap.latest.json` in your downloads area (or `CoTemp`).  
- On change, it triggers `CoUnWrap` automatically: unwraps → marks source `CoWrap_DELETABLE-…` → archives a copy → writes a receipt.

## 3-Panel Eligibility

- Use 3-panel only on **large displays** (≥32″ or ≥3200×2160).  
- Otherwise, run in **2-panel** to keep PS7 readable and reduce cognitive load.

## Session Identity & Tab Titles

- **Canonical ID**: `$env:COSESSION_ID` (UTC timestamp + GUID). This is what payloads/breadcrumbs use.
- **Human label**: `purpose-YYYYMMDDThhmm-shortid` (shortid = first 6–8 of GUID).  
- Until CoAgent can set browser tab titles, include the human label at the **top of each DO block** and in your status banners.  
- CoAgent SHOULD ensure new chats get a unique, timestamped title to avoid collisions and “stale tab” confusion.

### BPOE Status & Demark (standard footer)
Add this at the end of each DO block:
\\\powershell
Write-BPOEStatusLine -Color
Write-BPOELine -Gradient Sunset -Char '─'
\\\
<!-- 2025-09-05 :: injected by CoAgent lead -->
