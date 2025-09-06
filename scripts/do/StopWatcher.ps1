Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$bin = "$HOME\Downloads\CoCacheLocal\bin"
$p = Join-Path $bin "Stop-CoWrapWatcher.ps1"
if(Test-Path $p){ & $p } else { Write-Host "Stop watcher helper not found: $p" }
