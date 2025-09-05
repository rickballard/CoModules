Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Describe "BPOE Preflight" {
  It "runs without throwing" {
    $root = (Resolve-Path "$PSScriptRoot/..").Path
    { & (Join-Path $root "tools/Test-BPOE.ps1") -Quiet } | Should -Not -Throw
  }
  It "does not start OEStatusTimer" {
    $evt = Get-EventSubscriber -SourceIdentifier OEStatusTimer -ErrorAction SilentlyContinue
    $job = Get-Job -Name OEStatusTimer -ErrorAction SilentlyContinue
    ($evt -eq $null -and $job -eq $null) | Should -BeTrue
  }
}