<!-- status: stub; target: 150+ words -->
# CoTicker (Concept + Prototype)
A thin, always-on-top ticker just above the taskbar that streams BPOE/CoAgent status:
- cryptic status **blocks** (icons + colors), expandable on click (later)
- **thinking dots** row (auto-clears)
- file-queue API: `~/Downloads/CoTemp/coticker/inbox/*.json`

### Prototype
- Runtime: PowerShell + WPF (Windows)
- Start: `~/Downloads/CoTemp/tools/CoTicker/Start-CoTicker.ps1 -ClickThrough`
- Send:  `~/Downloads/CoTemp/tools/CoTicker/Demo-CoTicker.ps1`

### Roadmap (sketch)
- Click-to-expand hover cards
- “Do not overlap input fields” heuristics
- Web overlay alt (Electron / PWA) for cross-platform
- CoAgent integration: watcher heartbeats, TTFD, consent prompts, repo ops

