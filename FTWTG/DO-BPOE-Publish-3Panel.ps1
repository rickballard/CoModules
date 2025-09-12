param(
  [Parameter(Mandatory=$true)][string]$Image,   # path to screenshot
  [string]$Repo = "$HOME\Documents\GitHub\CoModules",
  [switch]$Commit
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$Repo   = (Resolve-Path $Repo).Path
$assets = Join-Path $Repo 'docs\assets'
$work   = Join-Path $Repo 'docs\workflows'
$imgDst = Join-Path $assets 'three-panel-layout.png'
$doc    = Join-Path $work 'three-panel-layout.md'
$BpoeMd = Join-Path $Repo 'docs\status\BPOE.md'

foreach($d in @($assets,$work)){ if(!(Test-Path $d)){ New-Item -ItemType Directory -Force -Path $d | Out-Null } }
Copy-Item -Force $Image $imgDst

$md = @"
# FTW multi-panel workspace (pre-CoAgent)

This guide documents a 3-panel browser layout with **4 concurrent PS7 sessions** in the center column.
Content moves between panels via **CoPingPong** shortcuts and temporary **CoTemps** files to accelerate multi-agent workflows.
*(Pre-CoAgent note: great for folks not using CoAgent yet—or who prefer bare-metal automation.)*

![Three-panel layout](../assets/three-panel-layout.png)

## Key ideas
- Left & right columns host chat/notes and status panes.
- Middle column: dedicated PS7 tabs per stream; long-running tasks stay isolated.
- CoPingPong: hotkeys push/pull text via **CoTemps** for lossless handoff across windows.
- Plays nicely with DO-GUARD and the BPOE capture scripts.
"@
$md | Out-File -LiteralPath $doc -Encoding UTF8

# Append a Wisdom Log entry that links to the guide
$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
$entry = "### $stamp [docs, practice]`r`nCapture: three-panel layout guide → docs/workflows/three-panel-layout.md`r`n`r`n"
$text  = Get-Content -LiteralPath $BpoeMd -Raw
if($text -notmatch '(?m)^##\s+Wisdom Log'){ $text = $text + "`r`n## Wisdom Log`r`n" }
$updated = [regex]::Replace($text, '(^##\s+Wisdom Log\s*\r?\n)', "`$1$entry", 'Multiline')
$updated | Out-File -LiteralPath $BpoeMd -Encoding UTF8

Write-Host "[OK] wrote:"
Write-Host " - $doc"
Write-Host " - $imgDst"
Write-Host " - updated $BpoeMd"

if($Commit){
  Push-Location $Repo
  try{
    git add -- "docs/assets/three-panel-layout.png" "docs/workflows/three-panel-layout.md" "docs/status/BPOE.md" 2>$null
    git add --renormalize -- "docs/status/BPOE.md" 2>$null
    git diff --cached --quiet; $has = ($LASTEXITCODE -ne 0)
    if($has){
      git commit -m "docs: add 3-panel workflow guide + BPOE link" 2>$null
      Write-Host "[OK] committed"
    } else {
      Write-Host "[SKIP] no changes staged"
    }
  } finally { Pop-Location }
}

