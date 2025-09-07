function Invoke-Do {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][int]$Id,
    [Parameter(Mandatory=$true)][ScriptBlock]$Body,
    [string]$Name="DO"
  )
  if (-not (Get-Variable -Name PSVersionTable -Scope Global -ErrorAction SilentlyContinue)) {
    Write-Host "STOP: Paste in PowerShell (not Python)."; return
  }
  $oldEAP = $ErrorActionPreference; $oldPwd = Get-Location
  try { Set-StrictMode -Version Latest } catch {}
  $ErrorActionPreference='Stop'
  try {
    & $Body
    try {
      $mod = Join-Path $PSScriptRoot 'CoPingButton.psm1'
      if (Test-Path $mod) { Import-Module $mod -Force }
      if (Get-Command Invoke-CoPingButton -ErrorAction SilentlyContinue) {
        Invoke-CoPingButton -Message ("{0} {1} complete" -f $Name,$Id) -Id $Id
      } else {
        Write-Host ("PONG: {0} {1} complete" -f $Name,$Id)
      }
    } catch { Write-Host ("PONG: {0} {1} complete" -f $Name,$Id) }
  }
  catch {
    try {
      if (Get-Command Invoke-CoPingButton -ErrorAction SilentlyContinue) {
        Invoke-CoPingButton -Message ("{0} {1} FAILED: {2}" -f $Name,$Id,$_.Exception.Message) -Id $Id
      } else {
        Write-Host ("PONG: {0} {1} FAILED: {2}" -f $Name,$Id,$_.Exception.Message)
      }
    } catch {}
    throw
  }
  finally {
    try { Set-Location $oldPwd } catch {}
    try { Set-StrictMode -Off } catch {}
    $global:ErrorActionPreference=$oldEAP
  }
}
Export-ModuleMember -Function Invoke-Do
