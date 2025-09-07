Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$tool = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "tools\CoPing.ps1"
if(Test-Path $tool){ & $tool -To "COAGENT" -Msg "ping test" }
$env:CoDO_FOOTER_DONE="1"