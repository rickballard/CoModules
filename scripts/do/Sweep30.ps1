Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$bin = "$HOME\Downloads\CoCacheLocal\bin"
$p = Join-Path $bin "Sweep.ps1"
if(Test-Path $p){ & $p -MaxAgeDays 30 -Purge } else { Write-Host "Sweep helper not found: $p" }
