Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
& (Join-Path (Split-Path $PSScriptRoot -Parent) "tools\Status-CoRemindRouter.ps1")
$env:CoDO_FOOTER_DONE="1"