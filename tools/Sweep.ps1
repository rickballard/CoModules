param([int]$MaxAgeDays = 21, [switch]$Purge)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$dl  = $env:COCACHE_DOWNLOADS ?? (Join-Path $HOME "Downloads")
$CCL = $env:COCACHE_LOCAL ?? (Join-Path $HOME "Downloads/CoCacheLocal")
$targets = @()
$targets += Get-ChildItem $dl -Filter 'CoWrap*.zip' -ErrorAction SilentlyContinue
$targets += Get-ChildItem $dl -Filter 'CoWrap.*.json' -ErrorAction SilentlyContinue
$targets += Get-ChildItem $CCL -Recurse -ErrorAction SilentlyContinue
$cutoff = (Get-Date).AddDays(-$MaxAgeDays)
$old = $targets | Where-Object { $_.LastWriteTime -lt $cutoff } | Sort-Object LastWriteTime
if (-not $old) { Write-Host "Nothing older than $MaxAgeDays day(s)."; return }
if ($Purge) {
  $old | ForEach-Object { try { if ($_.PSIsContainer) { Remove-Item -Recurse -Force $_.FullName } else { Remove-Item -Force $_.FullName } } catch { Write-Warning "Failed to delete $($_.FullName): $_" } }
  Write-Host "Purged $($old.Count) item(s) older than $MaxAgeDays day(s)."
} else {
  $old | Select-Object LastWriteTime, FullName | Format-Table -AutoSize
}
