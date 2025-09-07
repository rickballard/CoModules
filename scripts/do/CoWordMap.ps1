Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$map = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "docs\methods\CoWords.map.json"
if(Test-Path $map){ Get-Content $map -Raw | Write-Output }
$env:CoDO_FOOTER_DONE="1"