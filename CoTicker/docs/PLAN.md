<!-- status: stub; target: 150+ words -->
# CoTicker — Product Plan (public)

## Problem
Agent/workflow feedback needs to be visible without stealing focus.

## Users
Solo builders → small teams running CoAgent.

## Value
Ambient, low-friction status channel (watcher heartbeats, TTFD, consent).

## v0 Prototype (now)
- PS/WPF overlay, file-queue events (blocks, dots, clear)

## v1
- Click-through overlay w/ hover cards
- CoAgent: emit standard events (JSON)
- Settings: theme, height, speed

## v2+
- Cross-platform port (Electron/PWA)
- Rules (flash on anomalies, rate limits)
- Telemetry opt-in (local only in MVP)

## Risks
- Overlay interference → click-through + heuristics
- Perf/tearing → throttle + 60fps cap + GPU accel

