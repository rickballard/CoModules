Set-StrictMode -Version Latest
Describe "Hotkeys/Tutorial presence" {
  It "DO-ShowHelp.ps1 exists" {
    Test-Path "$PSScriptRoot/../DO-ShowHelp.ps1" | Should -BeTrue
  }
  It "three-panel doc exists" {
    Test-Path "$PSScriptRoot/../../docs/workflows/three-panel-layout.md" | Should -BeTrue
  }
  It "BPOE Wisdom Log present" {
    ((Get-Content "$PSScriptRoot/../../docs/status/BPOE.md" -Raw) -match "(?m)^##\s+Wisdom Log") | Should -BeTrue
  }
}
