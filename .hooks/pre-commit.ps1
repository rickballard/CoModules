Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
try { Import-Module Pester -ErrorAction Stop } catch {
  Write-Host "Pre-commit: Pester not available." -ForegroundColor Red; exit 1
}
try {
  Invoke-Pester -Path tests -CI -ErrorAction Stop | Out-Null
  exit 0
} catch {
  try {
    Invoke-Pester -Path tests -ErrorAction Stop | Out-Null
    exit 0
  } catch {
    Write-Host "Pre-commit: PowerShell tests FAILED — aborting commit." -ForegroundColor Red
    exit 1
  }
}