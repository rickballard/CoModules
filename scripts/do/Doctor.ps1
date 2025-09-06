Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)  # scripts\do -> scripts -> repo
& (Join-Path $repo 'tools\Test-WorkableRepo.ps1') -Quiet
