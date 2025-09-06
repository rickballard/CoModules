# BPOE — Pulse (end-of-set status)

**Goal:** a short status line at the end of every instruction set (no background timers), plus a breadcrumb in `Downloads\CoTemp`.

**Use (preferred wrapper):**
```powershell
Import-Module ./tools/BPOE/CoPulse.psm1 -Force
Invoke-WithPulse -Message "SET: <what just happened>" -Script {
  # your safe, idempotent steps here
}
```

**One-liner (append at end of a set):**
```powershell
Import-Module ./tools/BPOE/CoPulse.psm1 -Force; Write-BpoePulse -Message "SET: <what just happened>"
```

Writes `BPOE_Status_*.txt` + JSON and updates `CoStatus.latest.json` in `Downloads\CoTemp`.