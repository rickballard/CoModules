param([int]$MaxAgeDays=30,[switch]$Purge)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
. (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "tools\CoDrop.ps1")
Invoke-CoDownloadsSweep -MaxAgeDays $MaxAgeDays -Purge:$Purge
$env:CoDO_FOOTER_DONE="1"