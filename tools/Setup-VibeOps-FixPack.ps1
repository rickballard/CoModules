Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'

# Paths
$REPO  = Join-Path $HOME 'Documents\GitHub\CoModules'
$DOCS  = Join-Path $REPO 'docs'
$METHODS = Join-Path $DOCS 'methods'
$SCRIPTS = Join-Path $REPO 'scripts'
$DO = Join-Path $SCRIPTS 'do'
$TOOLS = Join-Path $REPO 'tools'
New-Item -Type Directory -Force -Path $DOCS,$METHODS,$SCRIPTS,$DO,$TOOLS | Out-Null

# Writer
function Write-Utf8NoBomLines {
  param([Parameter(Mandatory)][string]$Path,[Parameter(Mandatory)][string[]]$Lines)
  $enc = New-Object System.Text.UTF8Encoding($false)
  $txt = [string]::Join([Environment]::NewLine,$Lines)
  [IO.File]::WriteAllText($Path,$txt,$enc)
}
function Ensure-Do($name,$lines){ Write-Utf8NoBomLines -Path (Join-Path $DO ($name + '.ps1')) -Lines $lines }

# ---------- Lock to 20 CoWords (moved "coagent settings" to advanced) ----------
$map = @'
{
  "crumbs":           { "task": "Breadcrumbs" },
  "wrap status":      { "task": "WrapStatus" },

  "clean cotemp":     { "task": "CleanCoTemp", "args": ["-MaxAgeDays","30"] },
  "purge cotemp":     { "task": "CleanCoTemp", "args": ["-MaxAgeDays","30","-Purge"] },

  "paste guard on":   { "task": "PasteGuard", "args": ["-Mode","on"] },
  "paste guard off":  { "task": "PasteGuard", "args": ["-Mode","off"] },

  "fix prompt":       { "task": "FixPrompt" },

  "start reminders":  { "task": "RemindersStart" },
  "reminders status": { "task": "RemindersStatus" },
  "stop reminders":   { "task": "RemindersStop" },

  "start watcher":    { "task": "WatcherStart" },
  "watcher status":   { "task": "WatcherStatus" },
  "stop watcher":     { "task": "WatcherStop" },

  "help":             { "task": "Help" },
  "coword map":       { "task": "CoWordMap" },

  "save idea":        { "task": "SaveIdea" },
  "draft issue":      { "task": "DraftIssue" },
  "open issueops":    { "task": "OpenIssueOps" },

  "open copad":       { "task": "OpenCoPad" },
  "ping test":        { "task": "PingTest" }
}
'@
Write-Utf8NoBomLines -Path (Join-Path $METHODS 'CoWords.map.json') -Lines @($map)

# ---------- docs/ISSUEOPS.md (matches the 20 above) ----------
$issueops = @(
'# ISSUEOPS — CoWords (v0)',
'',
'Use these **CoWords** instead of typing commands. They drive DO tasks via CoAgent/CoWord routing.',
'',
'## Everyday CoWords (≤20)',
'- crumbs — show CoWrap & CoPing pointers (Downloads/CoTemp).',
'- wrap status — CoWrap watcher status + last wrap (if any).',
'- clean cotemp — list files >30d old (no delete).',
'- purge cotemp — delete files >30d old.',
'- paste guard on/off — toggle confirm-on-paste.',
'- fix prompt — recover from raw “PS>”/“>>”, snap back to repo.',
'- start reminders / reminders status / stop reminders — exception-only cleanup reminders.',
'- start watcher / watcher status / stop watcher — CoWrap watcher control.',
'- help — print current CoWords.',
'- coword map — show underlying map.',
'- save idea — capture a quick idea note to repo.',
'- draft issue — create a minimal ISSUE.md stub.',
'- open issueops — open this file.',
'- open copad — launch the CoPad button window.',
'- ping test — write a test CoPing.',
'',
'Advanced/rare CoWords live in: `docs/methods/CoWords-advanced.md`.'
)
Write-Utf8NoBomLines -Path (Join-Path $DOCS 'ISSUEOPS.md') -Lines $issueops

# ---------- Ensure required DO tasks exist ----------
Ensure-Do 'Breadcrumbs' @(
  'Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"',
  '$dl = $env:COCACHE_DOWNLOADS; if (-not $dl -or -not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads\CoTemp" }',
  'if (-not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads" }',
  'Write-Host "`n-- CoWrap.latest.json --"',
  'Get-Item -EA SilentlyContinue (Join-Path $dl "CoWrap.latest.json") | Format-List Name,LastWriteTime,Length,FullName',
  'Write-Host "`n-- CoPing.latest.json --"',
  'Get-Item -EA SilentlyContinue (Join-Path $dl "CoPing.latest.json") | Format-List Name,LastWriteTime,Length,FullName',
  '$env:CoDO_FOOTER_DONE="1"'
)
Ensure-Do 'CleanCoTemp' @(
  'param([int]$MaxAgeDays=30,[switch]$Purge)',
  'Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"',
  '$dl = $env:COCACHE_DOWNLOADS; if (-not $dl -or -not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads\CoTemp" }',
  'if (-not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads" }',
  '$cut=(Get-Date).AddDays(-$MaxAgeDays)',
  '$cands=Get-ChildItem $dl -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cut }',
  'if(-not $cands){ Write-Host ("Sweep: nothing older than {0} days in {1}" -f $MaxAgeDays,$dl) }',
  'else { $cands | Select-Object LastWriteTime,Length,FullName | Format-Table -AutoSize }',
  'if($Purge -and $cands){ $cands | Remove-Item -Force -ErrorAction SilentlyContinue; Write-Host ("Sweep: purged {0} files." -f $cands.Count) }',
  '$env:CoDO_FOOTER_DONE="1"'
)
Ensure-Do 'PasteGuard' @(
  'param([ValidateSet("on","off")][string]$Mode="on")',
  'Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"',
  'try { Import-Module PSReadLine -ErrorAction SilentlyContinue } catch {}',
  'try { $o=Get-PSReadLineOption; if ($o.PSObject.Properties.Name -contains "ConfirmOnPaste") { Set-PSReadLineOption -ConfirmOnPaste:($Mode -eq "on") | Out-Null } } catch {}',
  'Write-Host ("PasteGuard: ConfirmOnPaste -> {0}" -f $Mode.ToUpper())',
  'Write-Host "Tip: In Windows Terminal Settings, set: Paste on right-click = Off; Right-click opens menu = On."',
  '$env:CoDO_FOOTER_DONE="1"'
)
Ensure-Do 'FixPrompt' @(
  'param([string]$Repo="$HOME\Documents\GitHub\CoModules")',
  'Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"',
  'if (Test-Path $Repo) { Set-Location $Repo }',
  'try { Import-Module PSReadLine -ErrorAction SilentlyContinue } catch {}',
  'try { $o=Get-PSReadLineOption; if ($o.PSObject.Properties.Name -contains "ConfirmOnPaste") { Set-PSReadLineOption -ConfirmOnPaste:$true | Out-Null } } catch {}',
  'Write-Host ("Prompt reset to repo: {0}" -f (Get-Location).Path)',
  'Write-Host "If you see a bare PS>/>>, press Esc to clear the partial line or Ctrl+C to cancel."',
  '$env:CoDO_FOOTER_DONE="1"'
)
Ensure-Do 'RemindersStart' @(
  'Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"',
  '& (Join-Path (Split-Path $PSScriptRoot -Parent) "tools\Start-CoRemindRouter.ps1")',
  '$env:CoDO_FOOTER_DONE="1"'
)
Ensure-Do 'RemindersStatus' @(
  'Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"',
  '& (Join-Path (Split-Path $PSScriptRoot -Parent) "tools\Status-CoRemindRouter.ps1")',
  '$env:CoDO_FOOTER_DONE="1"'
)
Ensure-Do 'RemindersStop' @(
  'Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"',
  '& (Join-Path (Split-Path $PSScriptRoot -Parent) "tools\Stop-CoRemindRouter.ps1")',
  '$env:CoDO_FOOTER_DONE="1"'
)
Ensure-Do 'OpenCoPad' @(
  'Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"',
  '$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent',
  '$pad  = Join-Path $root "tools\CoPad.Words.ps1"',
  'if(Test-Path $pad){ Start-Process $pad } else { Write-Host "CoPad not found at: $pad" }',
  '$env:CoDO_FOOTER_DONE="1"'
)

Write-Host "FixPack complete."
Write-Host " - CoWords locked to 20"
Write-Host " - ISSUEOPS.md replaced"
Write-Host " - DO tasks ensured (Breadcrumbs, CleanCoTemp, PasteGuard, FixPrompt, Reminders*, OpenCoPad)"
