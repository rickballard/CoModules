Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
foreach($n in @("CoOpActions.md","CoOpSettings.md","CoOpWisdom.md")){ $p = Join-Path (Join-Path $root "docs") $n; if(Test-Path $p){ Start-Process $p } }
$env:CoDO_FOOTER_DONE="1"