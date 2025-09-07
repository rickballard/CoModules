param([int]$MaxAgeDays=30,[switch]$Purge)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"

# Locate CoTemp or fallback
$dl = $env:COCACHE_DOWNLOADS
if(-not $dl -or -not (Test-Path $dl)){ $dl = Join-Path $HOME "Downloads\CoTemp" }
if(-not (Test-Path $dl)){ $dl = Join-Path $HOME "Downloads" }

# Demo/Live mode
$run  = Join-Path $HOME "Downloads\CoCacheLocal\run"
$mode = try { (Get-Content (Join-Path $run 'CoSession.mode.json') -Raw | ConvertFrom-Json).mode } catch { 'demo' }
$isDemo = ($mode -ne 'live')

$cut   = (Get-Date).AddDays(-$MaxAgeDays)
$cands = Get-ChildItem $dl -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cut }
$arr   = @($cands)

if(-not $arr){ Write-Host ("Sweep: nothing older than {0} days in {1}" -f $MaxAgeDays,$dl) }
else { $arr | Select-Object LastWriteTime,Length,FullName | Format-Table -AutoSize }

if($Purge -and $arr){
  $bytes = ($arr | Measure-Object Length -Sum).Sum
  $mb    = [math]::Round(($bytes/1MB),2)
  if($isDemo){
    Write-Host ("[DEMO] Would purge {0} files (~{1} MB). Say 'live mode' then rerun 'purge cotemp'." -f $arr.Count,$mb)
  } else {
    $arr | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Host ("Sweep: purged {0} files." -f $arr.Count)
  }
}

$env:CoDO_FOOTER_DONE="1"