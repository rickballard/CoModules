Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$RUN = Join-Path $HOME "Downloads\\CoCacheLocal\\run"
$pidFile = Join-Path $RUN "coremind-router.pid"
if (-not (Test-Path $pidFile)) { Write-Host "CoRemind router: not running (no pid file)"; exit 0 }
$watcherPid = Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1
if ($watcherPid -and (Get-Process -Id $watcherPid -ErrorAction SilentlyContinue)) { Write-Host ("CoRemind router: RUNNING (pid {0})" -f $watcherPid) } else { Write-Host "CoRemind router: NOT running (stale pid file)" }