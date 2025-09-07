Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"

# CoBacklog path
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$doc  = Join-Path (Join-Path $root "docs\backlog") "CoBacklog.md"
if(-not (Test-Path $doc)){ Write-Host "0 inbox · 0 next · 0 done"; $env:CoDO_FOOTER_DONE="1"; exit }

# Ensure the four sections exist once (idempotent)
$t = Get-Content $doc -Raw
foreach($h in '## Inbox','## Next','## Someday','## Done (recent)'){
  if($t -notmatch "(?m)^\s$([regex]::Escape($h))\s$"){ $t = $t.TrimEnd() + "`r`n`r`n$h`r`n" }
}
$lines = ($t -replace "`r`n","`n") -split "`n"

function Count-Under([string]$name){
  $hdr = "## $name"
  # find all header line indexes
  $hdrIdx = 0..($lines.Count-1) | Where-Object { $lines[$_].TrimStart().StartsWith('## ') }
  if(-not $hdrIdx){ return 0 }
  # exact match for the section header
  $start = $hdrIdx | Where-Object { $lines[$_].Trim() -eq $hdr } | Select-Object -First 1
  if($null -eq $start){ return 0 }
  # next header or EOF
  $next  = ($hdrIdx | Where-Object { $_ -gt $start } | Select-Object -First 1)
  $end   = if($null -ne $next){ $next } else { $lines.Count }
  # count indented non-empty lines (your bullets start with a leading space)
  @($lines[($start+1)..($end-1)] | Where-Object { $_ -match '^\s+\S' }).Count
}

("{0} inbox · {1} next · {2} done" -f (Count-Under 'Inbox'), (Count-Under 'Next'), (Count-Under 'Done (recent)')) | Write-Host
$env:CoDO_FOOTER_DONE="1"
