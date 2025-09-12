Set-StrictMode -Version Latest
Describe "BPOE canon" {
  It "BPOE.md exists" {
    Test-Path "$PSScriptRoot/../../docs/status/BPOE.md" | Should -BeTrue
  }
  It "has Wisdom Log header" {
    ((Get-Content "$PSScriptRoot/../../docs/status/BPOE.md" -Raw) -match '(?m)^##\s+Wisdom Log') | Should -BeTrue
  }
}

