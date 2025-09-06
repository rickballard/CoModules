param(
  [Parameter(Mandatory)][string]$Name,
  [string[]]$Args
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$BIN = Join-Path $HOME 'Downloads\CoCacheLocal\bin'
try { Import-Module (Join-Path $BIN 'BPOE.Demark.psm1') -Force } catch {}
try { Import-Module (Join-Path $BIN 'BPOE.Status.psm1') -Force } catch {}

$repoRoot = Split-Path -Parent $PSScriptRoot    # tools -> repo
$doRoot   = Join-Path $repoRoot 'scripts\do'

$cand = Join-Path $doRoot ($Name + '.ps1')
if (-not (Test-Path $cand)) {
  $match = Get-ChildItem $doRoot -Filter ($Name + '*.ps1') -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($match) { $cand = $match.FullName }
}

if (-not (Test-Path $cand)) {
  Write-Host "CoDO: task not found: $Name"
  Get-ChildItem $doRoot -Filter '*.ps1' | Select-Object -Expand Name
  try { Write-BPOEStatusLine -Color } catch {}
  try { Write-BPOELine -Gradient Rainbow -Char '─' } catch {}
  exit 2
}

$Status = 'OK'
try {
  & $cand @Args
}
catch {
  $Status = 'ERROR'
  Write-Error $_
}
finally {
  try { Write-BPOEStatusLine -Color } catch {}
  try { Write-BPOELine -Gradient Rainbow -Char '─' } catch {}
}

if ($Status -ne 'OK') { exit 1 }
