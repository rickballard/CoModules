function Invoke-CoPingButton {
  param([Parameter(Mandatory=$true)][string]$Message,[string]$Id="unknown")
  try {
    if (Get-Command CoPing -ErrorAction SilentlyContinue) { CoPing $Message }
    else {
      $logDir = Join-Path $PSScriptRoot '..\..\tools\logs'
      New-Item -ItemType Directory -Force -Path $logDir | Out-Null
      $flag = Join-Path $logDir ("COPING.{0}.ok" -f $Id)
      Set-Content -Path $flag -Value $Message -Encoding utf8
      Write-Host "PONG: $Message"
    }
  } catch { Write-Host "PONG: $Message" }
}
Export-ModuleMember -Function Invoke-CoPingButton
