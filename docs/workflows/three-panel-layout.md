# FTW multi-panel workspace (pre-CoAgent)

This pattern uses a 3-panel browser layout with **4 concurrent PS7 sessions** in the center column.
CoPingPong moves content via **CoTemps** for fast handoff across windows. *(Great pre-CoAgent, or if you prefer bare-metal.)*

![Three-panel layout](../assets/three-panel-layout.png)

## Key ideas
- Left/right columns: chat, notes, status.
- Middle: one PS7 tab per stream; long runs isolated.
- CoPingPong hotkeys push/pull via **CoTemps**.
- Plays nicely with DO-GUARD and BPOE capture.
## Hotkeys & Pairing (pre-CoAgent)
- **Help anywhere:** Ctrl+Alt+H ? opens quick-help (AHK ? DO-ShowHelp.ps1)
- **Trigger (focused):** Ctrl+Alt+Enter ? drops *context* trigger (DO-CoKey.ps1)
- **Trigger (omni):** Ctrl+Alt+Shift+Enter ? drops *omni* trigger
- **Pair chat ? panel:** DO-CoPairChat.ps1 (AHK) + DO-CoPairPanel.ps1
- Queue files in CoTemps\queue\* for watchers.

## CoNames (shortcut taxonomy)

- **CoHelp** — *Open quick-help.* — Chord: **Ctrl+Alt+H**
- **CoGo.Context** — *Greenlight the focused set.* — Chord: **Ctrl+Alt+Enter** ? writes CoTemps\queue\context_*.json
- **CoGo.Omni** — *Any ready worker may go.* — Chord: **Ctrl+Alt+Shift+Enter** ? writes CoTemps\queue\omni_*.go
- **CoPair.Chat** — *Bind this chat tab to a panel.* — Script: FTWTG/DO-CoPairChat.ps1 ? updates CoTemps\link.json
- **CoPair.Panel** — *Register this PS window as PanelX.* — Script: FTWTG/DO-CoPairPanel.ps1 ? updates CoTemps\link.json
- **CoBPOE.Ticker** — *Nudge every N mins.* — Script: FTWTG/Start-BPOEReminder.ps1 -Minutes 20

**Notes**
- *Context* cares about the **focused window** (title/proc) so watchers route correctly.
- *Omni* is broadcast; watchers must **claim then clear** their flag to avoid double-runs.

