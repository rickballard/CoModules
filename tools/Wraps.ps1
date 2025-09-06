param([switch]$Status)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$dl = $env:COCACHE_DOWNLOADS ?? (Join-Path $HOME "Downloads")
$all = Get-ChildItem $dl -Filter 'CoWrap*.zip' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
if (-not $all) { Write-Host "No CoWrap zips in Downloads."; return }
$handled = $all | Where-Object { $_.Name -like 'CoWrap_DELETABLE-*' }
$todo    = $all | Where-Object { $_.Name -notlike 'CoWrap_DELETABLE-*' }
if ($Status) { try { Import-Module (Join-Path $HOME "Downloads\CoCacheLocal\bin\BPOE.Status.psm1") -Force } catch {}; try { Write-BPOEStatusLine -Color } catch {} }
Write-Host "=== CoWraps — Outstanding ==="; $todo    | Select-Object LastWriteTime, Name | Format-Table -AutoSize
Write-Host "`n=== CoWraps — Handled (DELETABLE) ==="; $handled | Select-Object LastWriteTime, Name | Format-Table -AutoSize

