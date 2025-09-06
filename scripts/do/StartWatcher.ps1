Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$bin = "$HOME\Downloads\CoCacheLocal\bin"
$p = Join-Path $bin "Start-CoWrapWatcher.ps1"
if(Test-Path $p){ & $p } else { Write-Host "Start watcher helper not found: $p" }
