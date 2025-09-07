param([string]$Path = ".")
$bad = Select-String -Path $Path -Pattern `
  '^\sPS .+?>\s$',
  '^\s>>>\s$',
  '^\s>>\s$',
  '^\s\^(C|Z)\s$',
  '^\s--- .+ ---\s$' -AllMatches -ErrorAction SilentlyContinue
if ($bad) { $bad | Format-Table Path,LineNumber,Line; exit 1 } else { "OK" }
