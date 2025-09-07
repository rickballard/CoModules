$lint = 'scripts/do/Lint-Blocks.ps1'
@'
param([string]$Path = ".")
$bad = Select-String -Path $Path -Pattern `
  '^\s*PS .+?>\s*$',
  '^\s*>>>\s*$',
  '^\s*>>\s*$',
  '^\s*\^(C|Z)\s*$',
  '^\s*--- .+ ---\s*$' -AllMatches -ErrorAction SilentlyContinue
if ($bad) { $bad | Format-Table Path,LineNumber,Line; exit 1 } else { "OK" }
'@ | Set-Content $lint -Encoding utf8
