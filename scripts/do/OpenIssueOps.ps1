Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$p = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "docs\ISSUEOPS.md"
if(Test-Path $p){ Start-Process $p }
$env:CoDO_FOOTER_DONE="1"