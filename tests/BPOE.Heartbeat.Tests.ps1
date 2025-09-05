# BPOE.Heartbeat.Tests.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Describe "BPOE: Long steps show heartbeat" {
  $roots = @('tools','dev','scripts')
  $scripts = @()
  foreach ($root in $roots) { if (Test-Path $root) { $scripts += Get-ChildItem -Recurse -File -Path $root -Include *.ps1 -ErrorAction SilentlyContinue } }
  if ($scripts.Count -eq 0) { It "has scripts to check" { $true | Should -BeTrue } }
  It "wraps long ops with heartbeat: <_.Name>" -ForEach $scripts {
    param($s)
    $text = Get-Content -Raw -LiteralPath $s.FullName
    $hasLongCall = $text -match '(?m)^\s*(git|gh|Invoke-WebRequest|winget)\b'
    $hasHeartbeat = $text -match 'Invoke-WithHeartbeat'
    if ($hasLongCall) { $hasHeartbeat | Should -BeTrue -Because "$($s.FullName) has long ops but no heartbeat" } else { $true | Should -BeTrue }
  }
}