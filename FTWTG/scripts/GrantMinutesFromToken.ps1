param(
  [int]$alreadyGrantedToday = 0  # pass what FTW has already granted today
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$policyPath = Join-Path $PSScriptRoot '..\policy\guardian-policy.json' | Resolve-Path
$policy = (Get-Content -LiteralPath $policyPath -Raw) | ConvertFrom-Json
$stateDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(($policy.storage.state_dir -replace '%LOCALAPPDATA%', $env:LOCALAPPDATA))
$earned   = Join-Path $stateDir 'earned.json'

if(-not (Test-Path $earned)){ Write-Output (@{granted=0; reason='no_token'} | ConvertTo-Json); exit 0 }

try{
  $t = Get-Content -LiteralPath $earned -Raw | ConvertFrom-Json
} catch {
  Write-Output (@{granted=0; reason='bad_token'} | ConvertTo-Json); exit 0
}

$today = (Get-Date).ToString('yyyy-MM-dd')
if($t.date -ne $today){ Remove-Item $earned -Force; Write-Output (@{granted=0; reason='stale_token'} | ConvertTo-Json); exit 0 }

$cap    = [int]$t.minutes.daily_cap
$reward = [int]$t.minutes.quest_reward
$room   = [Math]::Max(0, $cap - [int]$alreadyGrantedToday)

$grant  = [Math]::Min($reward, $room)
if($grant -gt 0){
  # consume token
  Set-Content -LiteralPath $earned -Value '' -Encoding UTF8
  Remove-Item $earned -Force -ErrorAction SilentlyContinue
  Write-Output (@{granted=$grant; reason='ok'} | ConvertTo-Json)
} else {
  Set-Content -LiteralPath $earned -Value '' -Encoding UTF8
  Remove-Item $earned -Force -ErrorAction SilentlyContinue
  Write-Output (@{granted=0; reason='cap_reached'} | ConvertTo-Json)
}
