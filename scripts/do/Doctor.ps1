Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
& (Join-Path (Split-Path -Parent $PSScriptRoot) "tools\Test-WorkableRepo.ps1") -Quiet
