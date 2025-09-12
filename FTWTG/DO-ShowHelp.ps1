# FTWTG/DO-ShowHelp.ps1 — open canonical quick-help
Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop"
$repo = "$HOME\Documents\GitHub\CoModules"
$paths = @()
$paths += (Join-Path $repo "docs\workflows\three-panel-layout.md")
$paths += (Join-Path $repo "ISSUEOPS.md")
$paths += (Join-Path $repo "docs\status\BPOE.md")
$paths  = $paths | Where-Object { Test-Path $_ }
if ($paths.Count -gt 0) { foreach ($p in $paths) { Start-Process $p } }
else { Write-Host "No docs found yet in $repo\docs." }
