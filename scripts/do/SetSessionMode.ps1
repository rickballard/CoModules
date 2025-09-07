param([ValidateSet("demo","live")][string]$Mode)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
& (Join-Path (Split-Path $PSScriptRoot -Parent) "tools\Set-CoSessionMode.ps1") -Mode $Mode
$env:CoDO_FOOTER_DONE="1"