Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$p = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "docs\ISSUE.md"
if(-not (Test-Path $p)){
  $lines = @("# Issue","- Context:","- Goal:","- Acceptance:","","## Notes")
  $enc = New-Object System.Text.UTF8Encoding($false); [IO.File]::WriteAllBytes($p,$enc.GetBytes([string]::Join([Environment]::NewLine,$lines)))
}
Start-Process $p
Write-Host ("Opened: {0}" -f $p)
$env:CoDO_FOOTER_DONE="1"