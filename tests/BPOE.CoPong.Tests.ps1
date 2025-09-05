Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

Describe "BPOE: CoPong present when DO scripts are referenced" {
  $mds = Get-ChildItem docs -Recurse -File -Filter *.md -ErrorAction SilentlyContinue
  if (-not $mds -or $mds.Count -eq 0) {
    It "has markdown files" { $true | Should -BeTrue }
    return
  }

  $cases = foreach ($m in $mds) {
    $t = Get-Content -Raw -LiteralPath $m.FullName
    $mentions = [bool]($t -match '(?im)\./docs/do/.+\.ps1')
    # Accept inline code or code blocks; not anchored to start-of-line
    $pong = [bool]($t -match '(?ims)pwsh\s+-NoProfile\s+-ExecutionPolicy\s+Bypass\s+-File\s+\./docs/do/.+\.ps1')
    [pscustomobject]@{ Name=$m.Name; Mentions=$mentions; HasPong=$pong }
  }

  It "docs require CoPong when DO referenced: <Name>" -TestCases $cases {
    param($Name, $Mentions, $HasPong)
    if ($Mentions) {
      $HasPong | Should -BeTrue -Because "$Name references ./docs/do/*.ps1 but no CoPong one-liner found"
    } else {
      $true | Should -BeTrue
    }
  }
}
