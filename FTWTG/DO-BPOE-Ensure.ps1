param([string]$Repo="$HOME\Documents\GitHub\CoModules",[switch]$Commit)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$Repo=(Resolve-Path $Repo).Path
$Status=Join-Path $Repo 'docs\status'
$Snap  = Join-Path $Status 'BPOE_Snapshots'
$Bpoe  = Join-Path $Status 'BPOE.md'
$Chg   = Join-Path $Status 'BPOE_CHANGELOG.md'
foreach($d in @($Status,$Snap)){ if(!(Test-Path $d)){ New-Item -ItemType Directory -Force -Path $d | Out-Null } }
if(!(Test-Path $Bpoe)){
@"
# Best Practice Operating Environment (BPOE)

This is the **canonical** place for BPOE wisdom and operational decisions.

## Wisdom Log
"@ | Out-File -LiteralPath $Bpoe -Encoding UTF8
}
if(!(Test-Path $Chg)){
"# BPOE — Changelog`r`n" | Out-File -LiteralPath $Chg -Encoding UTF8
}
Write-Host "[OK] BPOE ensure complete -> $Status"
if($Commit){
  try{ Push-Location $Repo; git add -- "docs/status" 2>$null; git commit -m "docs(BPOE): ensure canon" 2>$null }
  catch { Write-Warning ("Git commit skipped: {0}" -f $_.Exception.Message) }
  finally { Pop-Location }
}

