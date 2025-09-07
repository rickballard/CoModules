param([ValidateSet("demo","live")][string]$Mode)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$run = Join-Path $HOME "Downloads\CoCacheLocal\run"
$file = Join-Path $run "CoSession.mode.json"
$obj = [ordered]@{ mode=$Mode; ts=(Get-Date).ToUniversalTime().ToString("o") }
($obj | ConvertTo-Json) | Set-Content -Path $file
Write-Host ("Session mode set → {0}" -f $Mode)