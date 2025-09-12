param(
  [Parameter(Mandatory=$true)][string]$Message,
  [string[]]$Tags = @(),
  [string]$Repo = "$HOME\Documents\GitHub\CoModules",
  [switch]$Commit
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$Repo   = (Resolve-Path $Repo).Path
$BpoeMd = Join-Path $Repo 'docs\status\BPOE.md'
$Status = Join-Path $Repo 'docs\status'

# ensure minimal structure (no external dependency)
if(-not (Test-Path $Status)){ New-Item -ItemType Directory -Force -Path $Status | Out-Null }
if(-not (Test-Path $BpoeMd)){
@"
# Best Practice Operating Environment (BPOE)

This is the **canonical** place for BPOE wisdom and operational decisions.

## Wisdom Log
"@ | Out-File -LiteralPath $BpoeMd -Encoding UTF8
}

$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
$tagStr = ''
if($Tags -and $Tags.Count -gt 0){ $tagStr = ' [' + ($Tags -join ', ') + ']' }

$entry = @"
### $stamp$tagStr
$Message

"@

$text = Get-Content -LiteralPath $BpoeMd -Raw
if($text -notmatch '(?m)^##\s+Wisdom Log'){
  $text = $text + "`r`n## Wisdom Log`r`n"
}
$updated = [regex]::Replace($text, '(^##\s+Wisdom Log\s*\r?\n)', "`$1$entry", 'Multiline')
$updated | Out-File -LiteralPath $BpoeMd -Encoding UTF8

Write-Host "[OK] BPOE entry appended -> $BpoeMd"

if($Commit){
  try{
    Push-Location $Repo
    git add -- "docs/status/BPOE.md" 2>$null
    $msgShort = $Message; if($msgShort.Length -gt 60){ $msgShort = $msgShort.Substring(0,60) + '…' }
    git commit -m ("docs(BPOE): {0}" -f $msgShort) 2>$null
    Write-Host "[OK] committed BPOE entry"
  } catch { Write-Warning ("Git commit skipped: {0}" -f $_.Exception.Message) }
  finally { Pop-Location }
}

