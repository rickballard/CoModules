param(
  [Parameter(Mandatory)][string]$Name,
  [string[]]$Args
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$BIN = Join-Path $HOME 'Downloads\CoCacheLocal\bin'
try { Import-Module (Join-Path $BIN 'BPOE.Demark.psm1') -Force } catch {}
try { Import-Module (Join-Path $BIN 'BPOE.Status.psm1') -Force } catch {}

$repoRoot = Split-Path -Parent $PSScriptRoot
$doRoot   = Join-Path $repoRoot 'scripts\do'

# task lookup
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

# footer sentinel: tasks can set this to '1' to suppress CoDO footer
$env:CoDO_FOOTER_DONE = $null

$Status = 'OK'
try { & $cand @Args }
catch { $Status = 'ERROR'; Write-Error $_ }
finally {
  if (-not $env:CoDO_FOOTER_DONE) {
    try { Write-BPOEStatusLine -Color } catch {}
    try { Write-BPOELine -Gradient Rainbow -Char '─' } catch {}
  }
  $env:CoDO_FOOTER_DONE = $null
}

if ($Status -ne 'OK') { exit 1 }

