Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
if (-not $env:BPOE_SET_TOKEN) {
  try { Write-BPOEStatusLine -Color } catch {}
  try { Write-BPOELine -Gradient Rainbow -Char "─" } catch {}
}
$env:CoDO_FOOTER_DONE = "1"
