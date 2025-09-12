function Normalize-CoPanelName {
  param([Parameter(Mandatory=$true)][string]$Name)
  $map = @{
    'CoPingPong' = 'PanelA'
    'CoPair'     = 'PanelB'
    'CoCoach'    = 'PanelC'
    'CoOps'      = 'PanelD'
  }
  if ($map.ContainsKey($Name)) { return $map[$Name] }
  return $Name
}
# CoPingPong Panel normalizer
# Maps friendly names to the ValidateSet values expected by DO-CoPairPanel.ps1
$panelMap = @{
  'CoPingPong' = 'PanelA'
  'CoPair'     = 'PanelB'
  'CoCoach'    = 'PanelC'
  'CoOps'      = 'PanelD'
}
# If caller provides $Name (e.g., 'CoPingPong'), normalize it to a valid Panel
if (Get-Variable -Name Name -Scope 0 -ErrorAction SilentlyContinue) {
  $PanelNorm = if ($panelMap.ContainsKey($Name)) { $panelMap[$Name] } else { $Name }
}
function Start-CoSession {
  param([string]$Name='CoPingPong')
  Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
  & "C:\Users\Chris\Documents\GitHub\CoModules\FTWTG\DO-CoPairPanel.ps1" -Panel $(Normalize-CoPanelName $Name)
  $hb = Join-Path "C:\Users\Chris\Documents\GitHub\CoModules\FTWTG" 'Start-CoHeartbeat.ps1'
  if (Test-Path $hb) { & $hb -Minutes 15 | Out-Null }
}
Export-ModuleMember -Function Start-CoSession



