# CoPing (v0) — file-bus ping for inter-pane handoff
* Writes `CoPing_*.json` + updates `CoPing.latest.json` in `COCACHE_DOWNLOADS`.
* Fields: `ts, from, to, msg, data`.
* Future: buttons in DO blocks emit the same payload; watcher can trigger actions.
