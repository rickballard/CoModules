Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:StateDir = if ($env:COAGENT_STATE_DIR) { $env:COAGENT_STATE_DIR } else { Join-Path $env:LOCALAPPDATA 'CoAgent' }
function Get-CoAgentStatePath { Join-Path $script:StateDir 'install.json' }
function Write-CoAgentInstallStamp {
  [CmdletBinding()] param([string]$Version = 'unknown')
  [IO.Directory]::CreateDirectory($script:StateDir) | Out-Null
  $obj = [ordered]@{ installedUtc = [DateTime]::UtcNow.ToString('o'); version = $Version }
  ($obj | ConvertTo-Json -Depth 4) | Out-File -LiteralPath (Get-CoAgentStatePath) -Encoding utf8
}
function Get-CoAgentInstallInfo {
  $p = Get-CoAgentStatePath
  if (!(Test-Path $p)) { return $null }
  try { Get-Content -Raw -LiteralPath $p | ConvertFrom-Json } catch { $null }
}
function Test-CoAgentExpired {
  [CmdletBinding()] param([int]$MaxHours = 24)
  $info = Get-CoAgentInstallInfo
  if (-not $info -or -not $info.installedUtc) { return $true }
  $t = [DateTime]::Parse($info.installedUtc, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
  return ([DateTime]::UtcNow - $t).TotalHours -ge $MaxHours
}
function Invoke-CoAgentExpiryEnforce {
  [CmdletBinding()] param([int]$MaxHours = 24, [switch]$Quiet)
  $expired = Test-CoAgentExpired -MaxHours $MaxHours
  if (-not $expired) { if(-not $Quiet){ Write-Verbose 'CoAgent not expired' }; return $false }
  if(-not $Quiet){ Write-Warning ("CoAgent footprint is older than {0}h; please reinstall for safety." -f $MaxHours) }
  return $true
}
Export-ModuleMember -Function Write-CoAgentInstallStamp,Get-CoAgentInstallInfo,Test-CoAgentExpired,Invoke-CoAgentExpiryEnforce