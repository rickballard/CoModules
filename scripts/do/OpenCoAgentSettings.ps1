Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$p = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "docs\specs\CoAgent_Settings_UI.md"
if(Test-Path $p){ Start-Process $p } else { Write-Host "Settings spec not found yet." }
$env:CoDO_FOOTER_DONE="1"