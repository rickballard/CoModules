param([int]$Minutes = 20)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$source = "BPOE.Ticker.$Minutes"
Get-EventSubscriber -SourceIdentifier $source -ErrorAction SilentlyContinue | Unregister-Event | Out-Null
$timer = New-Object Timers.Timer
$timer.Interval = [Math]::Max(1,$Minutes)*60000
$timer.AutoReset = $true
Register-ObjectEvent -InputObject $timer -EventName Elapsed -SourceIdentifier $source -Action {
  Write-Host "[BPOE] realign → docs/status/BPOE.md | FTWTG/DO-GUARD.ps1" -ForegroundColor Yellow
} | Out-Null
$timer.Start()
Write-Host "[OK] BPOE reminder every $Minutes min. Use 'Get-EventSubscriber | Unregister-Event' to stop."
