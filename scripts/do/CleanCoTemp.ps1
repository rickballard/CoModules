param([int]$MaxAgeDays=30,[switch]$Purge)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
# --- Demo/Live session mode gate (inserted) ---
$run  = Join-Path $HOME 'Downloads\CoCacheLocal\run'
$mode = try { (Get-Content (Join-Path $run 'CoSession.mode.json') -Raw | ConvertFrom-Json).mode } catch { 'demo' }
$isDemo = ($mode -ne 'live')
# ----------------------------------------------$dl = $env:COCACHE_DOWNLOADS; if (-not $dl -or -not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads\CoTemp" }
if (-not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads" }
$cut=(Get-Date).AddDays(-$MaxAgeDays)
$cands=Get-ChildItem $dl -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cut }
if(-not $cands){ Write-Host ("Sweep: nothing older than {0} days in {1}" -f $MaxAgeDays,$dl) }
else { $cands | Select-Object LastWriteTime,Length,FullName | Format-Table -AutoSize }
if($Purge -and $cands){
  if($isDemo){
    $bytes = ($cands | Measure-Object -Property Length -Sum).Sum
    $mb = [math]::Round(($bytes/1MB),2)
    Write-Host ("[DEMO] Would purge {0} files (~{1} MB). Say 'live mode' then 'purge cotemp' to actually delete." -f $cands.Count,$mb)
  } else { $cands | Remove-Item -Force -ErrorAction SilentlyContinue; Write-Host ("Sweep: purged {0} files." -f $cands.Count); }
$env:CoDO_FOOTER_DONE="1"