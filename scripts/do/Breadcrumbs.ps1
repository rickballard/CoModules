Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$dl = $env:COCACHE_DOWNLOADS; if (-not $dl -or -not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads\CoTemp" }
if (-not (Test-Path $dl)) { $dl = Join-Path $HOME "Downloads" }
Write-Host "`n-- CoWrap.latest.json --"
Get-Item -EA SilentlyContinue (Join-Path $dl "CoWrap.latest.json") | Format-List Name,LastWriteTime,Length,FullName
Write-Host "`n-- CoPing.latest.json --"
Get-Item -EA SilentlyContinue (Join-Path $dl "CoPing.latest.json") | Format-List Name,LastWriteTime,Length,FullName
$env:CoDO_FOOTER_DONE="1"