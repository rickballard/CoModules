[CmdletBinding()]
param(
  [string]$OutFile,
  [switch]$FromClipboard
)
if ($FromClipboard) { $text = Get-Clipboard } else { $text = [Console]::In.ReadToEnd() }
$lines = $text -split "`r?`n"
$clean = foreach ($line in $lines) {
  # Strip common prompt markers
  if ($line -match '^\sPS [^>]+>\s') { $line = $line -replace '^\sPS [^>]+>\s','' }
  if ($line -match '^\s>>>\s') { continue }              # python repl
  if ($line -match '^\s>>\s')  { $line = $line -replace '^\s>>\s','' }
  if ($line -match '^\s\^(C|Z)\s$') { continue }         # ^C / ^Z
  if ($line -match '^\s--- . ---\s$') { continue }      # “--- STDOUT (tail) ---”
  if ($line -match '^\s(ParserError:|Get-Process:|KeyboardInterrupt)') { continue }
  if ($line -match '^\s\{"."\}\s$') { continue }        # JSON log lines
  $line
}
$body = ($clean -join "`r`n").Trim()
if ($OutFile) { Set-Content -Path $OutFile -Value $body -Encoding utf8 } else { $body }
