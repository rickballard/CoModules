param([string]$Temps="$HOME\CoTemps")
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'

# Determine script root reliably (works when run from file)
$root = $PSScriptRoot
if (-not $root) {
  if ($PSCommandPath) { $root = Split-Path -Parent $PSCommandPath }
  elseif ($MyInvocation.MyCommand.Path) { $root = Split-Path -Parent $MyInvocation.MyCommand.Path }
  else { $root = (Get-Location).Path }
}

$mtx = New-Object System.Threading.Mutex($false, "Global\CoQueueWatcher")
if (-not $mtx.WaitOne(0,$false)) { Write-Host "[Watcher] already running"; return }

try {
  Write-Host "[Watcher] online → $Temps"
  while ($true) {
    & (Join-Path $root 'DO-Process-CoQueue.ps1') -Temps $Temps
    Start-Sleep -Milliseconds 400
  }
} finally {
  $mtx.ReleaseMutex() | Out-Null
}

