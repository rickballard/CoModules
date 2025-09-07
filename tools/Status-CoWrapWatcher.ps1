Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$RUN = Join-Path $HOME "Downloads\CoCacheLocal\run"
$pidFile = Join-Path $RUN "cowrap-watcher.pid"
if (-not (Test-Path $pidFile)) { Write-Host "CoWrap watcher: not running (no pid file)"; exit 0 }
$watcherPid = Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1
if ($watcherPid -and (Get-Process -Id $watcherPid -ErrorAction SilentlyContinue)) {
  Write-Host ("CoWrap watcher: RUNNING (pid {0})" -f $watcherPid)
} else {
  Write-Host "CoWrap watcher: NOT running (stale pid file)"
}