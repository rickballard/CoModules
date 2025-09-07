Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$doc = Join-Path (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "docs\backlog") "CoBacklog.md"
if(Test-Path $doc){ Start-Process $doc } else { Write-Host "Backlog missing at $doc" }
$env:CoDO_FOOTER_DONE="1"