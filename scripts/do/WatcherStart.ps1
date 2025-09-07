Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
& (Join-Path (Split-Path $PSScriptRoot -Parent) "tools\Start-CoWrapWatcher.ps1")
$env:CoDO_FOOTER_DONE="1"