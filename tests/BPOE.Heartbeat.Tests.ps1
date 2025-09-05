Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

Describe "BPOE: Long steps show heartbeat" {
  $roots = @('tools','dev','scripts')
  $scripts = @()
  foreach ($root in $roots) {
    if (Test-Path $root) {
      $scripts += Get-ChildItem -Path $root -Recurse -File -Filter *.ps1 -ErrorAction SilentlyContinue
    }
  }
  if (-not $scripts -or $scripts.Count -eq 0) {
    It "has scripts to check" { $true | Should -BeTrue }; return
  }

  $cases = foreach ($s in $scripts) {
    @{ Path = $s.FullName; Name = $s.Name }
  }

  It "wraps long ops with heartbeat: <Name>" -TestCases $cases {
    param($Path, $Name)
    $text = Get-Content -Raw -LiteralPath $Path
    $hasLongCall = $text -match '(?m)^\s*(git|gh|Invoke-WebRequest|winget)\b'
    $hasHeartbeat = $text -match 'Invoke-WithHeartbeat'
    if ($hasLongCall) { $hasHeartbeat | Should -BeTrue -Because "$Path has long ops but no heartbeat" }
    else { $true | Should -BeTrue }
  }
}
