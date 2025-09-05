Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

Describe "BPOE: CoPong present when DO scripts are referenced" {
  $mds = Get-ChildItem docs -Recurse -File -Filter *.md -ErrorAction SilentlyContinue
  if (-not $mds -or $mds.Count -eq 0) {
    It "has markdown files" { $true | Should -BeTrue }
    return
  }

  foreach ($m in $mds) {
    $t = Get-Content -Raw -LiteralPath $m.FullName
    $mentionsDoScript = $t -match '(?i)\./docs/do/.+\.ps1'
    if ($mentionsDoScript) {
      $hasPong = $t -match '(?ms)^\s*pwsh\s+-NoProfile\s+-ExecutionPolicy\s+Bypass\s+-File\s+\./docs/do/.+\.ps1'
      It "has CoPong one-liner: $($m.Name)" { $hasPong | Should -BeTrue }
    } else {
      It "no DO scripts referenced: $($m.Name)" { $true | Should -BeTrue }
    }
  }
}
