param([switch]$Quiet)
Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
try {
  # (put real checks here later)
  if (-not $Quiet) {
    try { Import-Module "$HOME\Downloads\CoCacheLocal\bin\BPOE.Status.psm1" -Force } catch {}
    try { Write-BPOEStatusLine -Color } catch {}
  }
  exit 0
} catch {
  if (-not $Quiet) { Write-Error $_ }
  exit 1
}
