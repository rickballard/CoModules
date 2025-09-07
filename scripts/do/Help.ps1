Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$map = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "docs\methods\CoWords.map.json"
if(Test-Path $map){ $obj = Get-Content $map -Raw | ConvertFrom-Json; $obj.PSObject.Properties.Name | Sort-Object | ForEach-Object { "- $_" } }
$env:CoDO_FOOTER_DONE="1"