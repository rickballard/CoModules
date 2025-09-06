Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

function Invoke-BpoeHumanGate {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$Action,
    [switch]$AllowEnterAsDo
  )
  $enterOk = $AllowEnterAsDo -or ($env:BPOE_HUMANGATE_ENTER_OK -match '^(1|true|yes|on)$')
  if ($enterOk) { $hint = "[ENTER]=DO, type 'no' to abort" } else { $hint = "Type DO to proceed" }
  $resp = Read-Host ($hint + " → " + $Action)
  if ($enterOk) {
    if ([string]::IsNullOrWhiteSpace($resp)) { return $true }
    if ($resp -match '^(do|y|yes)$') { return $true }
    return $false
  } else {
    return ($resp -match '^(do|y|yes)$')
  }
}

function Set-BpoeHumanGateDefault {
  [CmdletBinding()] param([switch]$Enable,[switch]$Disable)
  $val = if ($Disable) { '0' } else { '1' }
  [Environment]::SetEnvironmentVariable('BPOE_HUMANGATE_ENTER_OK', $val, 'User')
  $env:BPOE_HUMANGATE_ENTER_OK = $val
  Write-Host ("HumanGate persistent ENTER=DO is now {0}" -f ( if($val -eq '1'){'ENABLED'}else{'DISABLED'} )) -ForegroundColor Cyan
}

Export-ModuleMember -Function Invoke-BpoeHumanGate,Set-BpoeHumanGateDefault