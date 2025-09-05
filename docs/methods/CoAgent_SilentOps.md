# CoAgent — Silent Ops

**Principles**
- No background timers or persistent services.
- No console prompts when `COAGENT_SILENT=1` (automation contexts).
- All operator interaction stays in chat; scripts are quiet + idempotent.

**Launcher pattern**
```powershell
Import-Module "$Repo/tools/CoAgent/CoAgent.Auto.psm1" -Force
$env:COAGENT_SILENT = "1"   # automation context
Invoke-CoAgentAuto -RepoRoot $Repo -MaxHours 24 -Quiet
```