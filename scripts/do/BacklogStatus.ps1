Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$doc  = Join-Path (Join-Path $root "docs\backlog") "CoBacklog.md"
if(-not (Test-Path $doc)){ Write-Host "0 inbox · 0 next · 0 done"; $env:CoDO_FOOTER_DONE="1"; exit }
$t = Get-Content $doc -Raw
function CountUnder([string]$hdr){
  $m=[regex]::Match($t,[regex]::Escape($hdr)+'(.?)(?:\r?\n## |\z)',[Text.RegularExpressions.RegexOptions]::Singleline)
  if(-not $m.Success){ return 0 }
  @($m.Groups[1].Value -split "`r?`n" | Where-Object { $_ -match '^\s' }).Count
}
("{0} inbox · {1} next · {2} done" -f (CountUnder '## Inbox'),(CountUnder '## Next'),(CountUnder '## Done (recent)')) | Write-Host
$env:CoDO_FOOTER_DONE="1"