param([string]$To="ANY",[string]$Msg="(no message)",[hashtable]$Data)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$dl = $env:COCACHE_DOWNLOADS; if (-not $dl -or -not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads\CoTemp" }
if (-not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads" }
$run = Join-Path $HOME "Downloads\CoCacheLocal\run"; New-Item -Type Directory -Force -Path $run | Out-Null
$busy = Test-Path (Join-Path $run "do.busy")
$sid   = $env:COSESSION_ID
$stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
$payload = [ordered]@{ ts=$stamp; from=$sid; to=$To; msg=$Msg; data=$Data }
$json    = $payload | ConvertTo-Json -Depth 8
if ($busy) {
  $qDir = Join-Path $dl "CoPing.queue"; New-Item -Type Directory -Force -Path $qDir | Out-Null
  $file = Join-Path $qDir ("CoPing_{0}_to-{1}.json" -f $stamp,$To)
  $json | Set-Content -Path $file
  [ordered]@{ latest=$file; ts=$stamp } | ConvertTo-Json | Set-Content -Path (Join-Path $dl "CoPing.queue.latest.json")
  Write-Host ("CoPing queued (busy): {0}" -f $file)
} else {
  $file = Join-Path $dl ("CoPing_{0}_to-{1}.json" -f $stamp,$To)
  $json | Set-Content -Path $file
  [ordered]@{ latest=$file; ts=$stamp } | ConvertTo-Json | Set-Content -Path (Join-Path $dl "CoPing.latest.json")
  Write-Host ("CoPing wrote: {0}" -f $file)
}