Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$RUN = Join-Path $HOME "Downloads\\CoCacheLocal\\run"
$pidFile = Join-Path $RUN "coword-router.pid"
if (-not (Test-Path $pidFile)) { Write-Host "CoWord router: nothing to stop"; exit 0 }
$watcherPid = Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1
if ($watcherPid -and (Get-Process -Id $watcherPid -ErrorAction SilentlyContinue)) { Stop-Process -Id $watcherPid -Force -ErrorAction SilentlyContinue; Start-Sleep -Milliseconds 200 }
Remove-Item $pidFile -ErrorAction SilentlyContinue
Write-Host "CoWord router: stopped"