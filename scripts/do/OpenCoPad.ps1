Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$pad  = Join-Path $root "tools\CoPad.Words.ps1"
if(Test-Path $pad){ Start-Process $pad } else { Write-Host "CoPad not found at: $pad" }
$env:CoDO_FOOTER_DONE="1"