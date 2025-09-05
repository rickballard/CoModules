Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/CoAgent.Expiry.psm1" -Force

function Test-CoAgentNeeded {
  [CmdletBinding()] param([string]$RepoRoot = $PWD.Path)
  if ($env:COAGENT_REQUIRED -match '^(1|true|yes|on)$') { return $true }
  return (Test-Path (Join-Path $RepoRoot 'tools\CoAgent'))
}

function Invoke-CoAgentAuto {
  [CmdletBinding()] param([string]$RepoRoot = $PWD.Path, [int]$MaxHours = 24, [switch]$Quiet)
  if (-not (Test-CoAgentNeeded -RepoRoot $RepoRoot)) { return }
  $expired = Invoke-CoAgentExpiryEnforce -MaxHours $MaxHours -Quiet:$Quiet
  if ($expired) {
    # Preferred: call your bootstrap if present; otherwise emit a minimal breadcrumb for operators.
    $bootstrap = Join-Path $RepoRoot 'tools\CoAgent\Install-CoAgent.ps1'
    if (Test-Path $bootstrap) { & $bootstrap -Quiet:$Quiet 2>$null; return }
    try {
      $msg = "[CoAgent.Auto] Expired; no bootstrap found. Please reinstall CoAgent."
      $dl  = Join-Path $HOME 'Downloads'
      [IO.Directory]::CreateDirectory($dl) | Out-Null
      $f = Join-Path $dl ("CoAgent_Expired_{0}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
      [IO.File]::WriteAllText($f, $msg, [Text.UTF8Encoding]::new($true))
    } catch {}
  }
}
Export-ModuleMember -Function Test-CoAgentNeeded,Invoke-CoAgentAuto