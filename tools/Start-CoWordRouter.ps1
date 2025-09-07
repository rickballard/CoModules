Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$RUN = Join-Path $HOME "Downloads\\CoCacheLocal\\run"
New-Item -Type Directory -Force -Path $RUN | Out-Null
$pidFile = Join-Path $RUN "coword-router.pid"
$dl = $env:COCACHE_DOWNLOADS; if (-not $dl -or -not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads\\CoTemp" }
if (-not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads" }
$daemon = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "CoWord.RouterDaemon.ps1"
$map = Join-Path (Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent) "docs\\methods\\CoWords.map.json"
$shell = (Get-Command pwsh -ErrorAction SilentlyContinue).Source; if (-not $shell) { $shell = (Get-Command powershell -ErrorAction SilentlyContinue).Source }
if (-not $shell) { throw "No PowerShell host (pwsh/powershell) found." }
if (Test-Path $pidFile) { $watcherPid = Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1; if ($watcherPid -and (Get-Process -Id $watcherPid -ErrorAction SilentlyContinue)) { Write-Host ("CoWord router already running (PID {0}) — Folder: {1}" -f $watcherPid,$dl); exit 0 } }
$args = @("-NoProfile","-File",$daemon,"-Watch",$dl,"-MapPath",$map)
$p = Start-Process -FilePath $shell -WindowStyle Hidden -ArgumentList $args -PassThru
$p.Id | Set-Content -Path $pidFile
Write-Host ("CoWord router started. Folder: {0}  (pid: {1})" -f $dl,$p.Id)