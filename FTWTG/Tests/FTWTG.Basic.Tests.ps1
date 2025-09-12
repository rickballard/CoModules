Set-StrictMode -Version Latest

Describe "FTWTG seed sanity" {
  It "Policy file exists" { Test-Path "$PSScriptRoot/../policy/guardian-policy.json" | Should -BeTrue }

  It "Policy parses and has required keys" {
    $pol = (Get-Content "$PSScriptRoot/../policy/guardian-policy.json" -Raw) | ConvertFrom-Json
    $required = 'timezone','categories','budgets','downtime','quests','ui','storage'
    foreach($k in $required){ ($pol.PSObject.Properties.Name -contains $k) | Should -BeTrue }
  }

  It "Scripts parse cleanly" {
    $paths = @("$PSScriptRoot/../scripts/GuardianWatcher.ps1",
               "$PSScriptRoot/../scripts/QuestPrompt.ps1",
               "$PSScriptRoot/../scripts/GrantMinutesFromToken.ps1")
    foreach($p in $paths){
      $t=$null;$a=$null;$e=$null
      [System.Management.Automation.Language.Parser]::ParseFile($p,[ref]$t,[ref]$a,[ref]$e) | Out-Null
      ($e -eq $null -or $e.Count -eq 0) | Should -BeTrue -Because "Parse errors in $p: $($e | % Message -join '; ')"
    }
  }

  It "Grant calculation respects cap" {
    $cap=45; $reward=15; $already=40
    $room=[Math]::Max(0,$cap-$already)
    $grant=[Math]::Min($reward,$room)
    $grant | Should -Be 5
  }
}

