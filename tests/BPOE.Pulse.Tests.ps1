Import-Module "$PSScriptRoot/../tools/BPOE/CoPulse.psm1" -Force
Describe "BPOE Pulse" {
  It "writes a breadcrumb and prints a line" {
    $tmp = Join-Path $env:TEMP ("pul_" + [IO.Path]::GetRandomFileName()); New-Item -ItemType Directory -Path $tmp | Out-Null
    { Write-BpoePulse -Message "TEST: unit" -OutDir $tmp } | Should -Not -Throw
    (Get-ChildItem -LiteralPath $tmp -Filter "BPOE_Status_*.txt").Count | Should -BeGreaterThan 0
    Remove-Item -Recurse -Force $tmp
  }
}