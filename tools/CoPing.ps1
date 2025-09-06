Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$dl = $env:COCACHE_DOWNLOADS; if (-not $dl -or -not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads\CoTemp" }
if (-not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads" }
param([string]$To="ANY",[string]$Msg="(no message)",[hashtable]$Data)
$sid = $env:COSESSION_ID
$stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
$payload = [ordered]@{ ts=$stamp; from=$sid; to=$To; msg=$Msg; data=$Data }
$json    = $payload | ConvertTo-Json -Depth 8
$file    = Join-Path $dl ("CoPing_{0}_to-{1}.json" -f $stamp,$To)
$json | Set-Content -Encoding UTF8NoBOM $file
( [ordered]@{ latest=$file; ts=$stamp } | ConvertTo-Json ) | Set-Content -Encoding UTF8NoBOM (Join-Path $dl "CoPing.latest.json")
Write-Host ("CoPing wrote: {0}" -f $file)
