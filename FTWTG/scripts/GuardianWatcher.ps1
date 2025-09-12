# policy: read-only (planning; enforced by DO-GUARD)
# FTWTG/scripts/GuardianWatcher.ps1
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
param([string]$PolicyPath = "$PSScriptRoot/../policy/guardian-policy.json")

function Get-ActiveWindowTitle {
  Add-Type -Namespace Win32 -Name User32 -MemberDefinition @"
    [System.Runtime.InteropServices.DllImport("user32.dll")]
    public static extern System.IntPtr GetForegroundWindow();
    [System.Runtime.InteropServices.DllImport("user32.dll")]
    public static extern int GetWindowText(System.IntPtr hWnd, System.Text.StringBuilder text, int count);
"@
  $h = [Win32.User32]::GetForegroundWindow()
  if ($h -eq [IntPtr]::Zero) { return "" }
  $buf = [System.Text.StringBuilder]::new(1024)
  [void][Win32.User32]::GetWindowText($h, $buf, $buf.Capacity)
  $buf.ToString()
}

function Get-ProcessNameFromTitle {
  try {
    $title = Get-ActiveWindowTitle
    if (-not $title) { return "" }
    $p = Get-Process | Where-Object { $_.MainWindowTitle -eq $title } | Select-Object -First 1
    if ($p) { return $p.ProcessName } else { return "" }
  } catch { return "" }
}

function Load-Policy($path) { (Get-Content -LiteralPath $path -Raw) | ConvertFrom-Json }
function Ensure-Dir($p) { if (-not (Test-Path $p)) { New-Item -Force -ItemType Directory -Path $p | Out-Null } }

function In-Downtime($policy) {
  $now = Get-Date
  $dow = @("Sun","Mon","Tue","Wed","Thu","Fri","Sat")[$now.DayOfWeek.value__]
  foreach ($slot in $policy.downtime) {
    if ($slot.days -contains $dow) {
      $start = [datetime]::ParseExact($slot.start,"HH:mm",$null)
      $end   = [datetime]::ParseExact($slot.end,  "HH:mm",$null)
      $todayStart = (Get-Date -Hour $start.Hour -Minute $start.Minute -Second 0)
      $todayEnd   = (Get-Date -Hour $end.Hour   -Minute $end.Minute   -Second 0)
      if ($todayEnd -lt $todayStart) {
        if ($now -ge $todayStart -or $now -le $todayEnd) { return $true }
      } else {
        if ($now -ge $todayStart -and $now -le $todayEnd) { return $true }
      }
    }
  }
  return $false
}

function Classify($policy, $procName, $title) {
  $p = $procName.ToLower()
  $t = $title.ToLower()
  foreach ($c in $policy.categories.PSObject.Properties.Name) {
    foreach ($needle in $policy.categories.$c) {
      if ($p -like "*$needle*" -or $t -like "*$needle*") { return $c }
    }
  }
  "neutral"
}

function Read-State($statePath) {
  if (Test-Path $statePath) { return (Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json) }
  [pscustomobject]@{
    date = (Get-Date).ToString("yyyy-MM-dd")
    minutes = @{ games = 0; learning = 0; rewards_earned = 0; rewards_spent = 0 }
    last_prompt_utc = $null
  }
}
function Write-State($statePath, $state) { $state | ConvertTo-Json -Depth 5 | Out-File -LiteralPath $statePath -Encoding UTF8 }

$policy = Load-Policy -path (Resolve-Path $PolicyPath)
$stateDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(($policy.storage.state_dir -replace '%LOCALAPPDATA%', $env:LOCALAPPDATA))
$logsDir  = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(($policy.storage.logs_dir  -replace '%LOCALAPPDATA%', $env:LOCALAPPDATA))
Ensure-Dir $stateDir; Ensure-Dir $logsDir
$statePath = Join-Path $stateDir 'state.json'
$logPath   = Join-Path $logsDir  ("guardian_"+(Get-Date -Format 'yyyyMMdd')+".log")

$state = Read-State $statePath
if ($state.date -ne (Get-Date).ToString("yyyy-MM-dd")) { $state = Read-State $statePath }

$intervalSec = 5; $accum = 0
while ($true) {
  Start-Sleep -Seconds $intervalSec
  $accum += $intervalSec
  $title = Get-ActiveWindowTitle
  $proc  = Get-ProcessNameFromTitle
  $cat   = Classify $policy $proc $title

  if ($cat -eq 'games')       { $state.minutes.games    += [math]::Round($intervalSec/60,2) }
  elseif ($cat -eq 'learning'){ $state.minutes.learning += [math]::Round($intervalSec/60,2) }

  if ($accum -ge 60) {
    $accum = 0
    ("{0} | {1} | {2} | {3}" -f (Get-Date -Format 'HH:mm:ss'), $proc, $cat, $title) | Out-File -Append -FilePath $logPath -Encoding UTF8
    Write-State $statePath $state
  }

  if (In-Downtime $policy) { continue }

  $gamesUsed = [int][math]::Round($state.minutes.games)
  $nearLimit = ($gamesUsed -ge ($policy.budgets.games_minutes_per_day - $policy.budgets.grace_minutes_before_prompt))
  $cooldown  = $false
  if ($state.last_prompt_utc) {
    $cooldown = ((Get-Date).ToUniversalTime() - ([datetime]$state.last_prompt_utc)).TotalMinutes -lt $policy.budgets.cooldown_minutes_after_decline
  }

  if ($nearLimit -and -not $cooldown) {
    $state.last_prompt_utc = (Get-Date).ToUniversalTime().ToString('o'); Write-State $statePath $state
    $r = $Host.UI.PromptForChoice(
      $policy.ui.coach_name,
      ("You've used {0}/{1} min of game time. Do a {2}-min quest for +{3} min?" -f $gamesUsed, $policy.budgets.games_minutes_per_day, $policy.quests.duration_minutes, $policy.quests.reward_minutes_games),
      @('&Do Quest','+ &Movement Break','&No thanks'),
      0
    )
    switch ($r) {
      0 { & "$PSScriptRoot/QuestPrompt.ps1" -PolicyPath $PolicyPath -Mode 'quest' }
      1 { & "$PSScriptRoot/QuestPrompt.ps1" -PolicyPath $PolicyPath -Mode 'movement' }
      default { }
    }
  }
}


