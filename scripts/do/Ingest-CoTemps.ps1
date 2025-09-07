param(
  [string]$Inbox = "$HOME/Downloads/CoTemps/Inbox",
  [string]$Processed = "$HOME/Downloads/CoTemps/Processed",
  [string]$Rejected = "$HOME/Downloads/CoTemps/Rejected",
  [string]$Errors = "$HOME/Downloads/CoTemps/Errors"
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$repo = Join-Path $HOME "Documents/GitHub/CoModules"
$backlogDir = Join-Path $repo "docs/backlog"
New-Item -ItemType Directory -Force -Path $backlogDir | Out-Null

Get-ChildItem -Path $Inbox -File -Filter .json | ForEach-Object {
  $src = $_.FullName
  try {
    $obj = Get-Content $src -Raw | ConvertFrom-Json -ErrorAction Stop
    if (-not $obj.title -or -not $obj.summary -or -not $obj.tags) { throw "missing required fields" }
    $date = Get-Date -Format "yyyyMMdd"
    $slug = ($obj.title -replace '[^\w\- ]','' -replace '\s+','-').ToLower()
    if (-not $slug) { $slug = "idea" }
    $dest = Join-Path $backlogDir ("{0}-{1}.md" -f $date,$slug)
    $md = @"
# {0}

Summary: {1}

Tags: {2}
Sensitivity: {3}
Source: {4}

## Rationale
{5}

## Impact
{6}

## Capability Handles
{7}
"@ -f $obj.title,$obj.summary,($(($obj.tags|Sort-Object -Unique) -join ', ')),$obj.sensitivity,$obj.source_session,($obj.rationale ?? ''),($obj.impact ?? ''),($(($obj.capability_handles ?? @()) -join ', '))
    $md | Set-Content $dest -Encoding utf8
    Move-Item -Force $src (Join-Path $Processed (Split-Path $src -Leaf))
    Write-Host "INGESTED: $($obj.title)"
  }
  catch {
    Write-Warning "REJECTED: $(Split-Path $src -Leaf) — $($_.Exception.Message)"
    try { Move-Item -Force $src (Join-Path $Rejected (Split-Path $src -Leaf)) } catch { Copy-Item $src $Errors -Force }
  }
}






