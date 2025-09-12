param([int]$Minutes=15,[string]$Temps="$HOME\CoTemps")
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$dir = Join-Path $Temps 'status'; if(!(Test-Path $dir)){ New-Item -ItemType Directory -Force -Path $dir | Out-Null }
$src = "CoHB.$Minutes"
Get-EventSubscriber -SourceIdentifier $src -ErrorAction SilentlyContinue | Unregister-Event | Out-Null
$timer = New-Object Timers.Timer; $timer.Interval=[Math]::Max(1,$Minutes)*60000; $timer.AutoReset=$true
Register-ObjectEvent -InputObject $timer -EventName Elapsed -SourceIdentifier $src -Action {
  $ai = "$HOME/Documents/GitHub/CoModules/docs/status/AI_PREFS.json"
  $obj = [ordered]@{ at=(Get-Date).ToString('o'); ai=(Test-Path $ai ? (Get-Content -Raw $ai | ConvertFrom-Json) : $null) }
  ($obj|ConvertTo-Json -Depth 6) | Out-File -LiteralPath (Join-Path "$HOME\CoTemps\status" 'hb.json') -Encoding UTF8
} | Out-Null
$timer.Start()
Write-Host "[HB] Co heartbeat every $Minutes min → $HOME\CoTemps\status\hb.json"
