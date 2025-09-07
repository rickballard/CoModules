Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$f = Join-Path (Join-Path $HOME "Downloads\CoCacheLocal\run") "CoBread.stats.json"
if(Test-Path $f){ Get-Content $f -Raw } else { Write-Host "{ }" }
$env:CoDO_FOOTER_DONE="1"