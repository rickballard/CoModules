Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Describe "Profile AST" {
  It "profile parses clean if present" {
    if (Test-Path $PROFILE) {
      [System.Management.Automation.Language.Token[]]$t=$null
      [System.Management.Automation.Language.ParseError[]]$e=$null
      [System.Management.Automation.Language.Parser]::ParseFile($PROFILE,[ref]$t,[ref]$e) | Out-Null
      $e.Count | Should -Be 0
    } else {
      $true | Should -BeTrue
    }
  }
}