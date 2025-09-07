Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$docDir = Join-Path $root 'docs\backlog'
$doDir  = Join-Path $root 'scripts\do'
New-Item -Type Directory -Force -Path $docDir,$doDir | Out-Null

# --- BacklogStatus.ps1 (fix regex + force-array for .Count) ---
$backlogStatus = @"
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$doc  = Join-Path (Join-Path $root 'docs\backlog') 'CoBacklog.md'
if(-not (Test-Path $doc)){ Write-Host '0 inbox · 0 next · 0 done'; \$env:CoDO_FOOTER_DONE='1'; exit }
\$t = Get-Content \$doc -Raw
function CountUnder([string]\$hdr){
  \$m = [regex]::Match(\$t, [regex]::Escape(\$hdr) + '(.?)(?:\r?\n## |\z)', [Text.RegularExpressions.RegexOptions]::Singleline)
  if(-not \$m.Success){ return 0 }
  @(\$m.Groups[1].Value -split "`r?`n" | Where-Object { \$_ -match '^\s' }).Count
}
("{0} inbox · {1} next · {2} done" -f (CountUnder '## Inbox'), (CountUnder '## Next'), (CountUnder '## Done (recent)')) | Write-Host
\$env:CoDO_FOOTER_DONE='1'
"@
[IO.File]::WriteAllText((Join-Path $doDir 'BacklogStatus.ps1'), $backlogStatus, (New-Object System.Text.UTF8Encoding($false)))

# --- ParkQuest.ps1 (unchanged logic; keeps your simple bullet) ---
$parkQuest = @"
param([string]\$Title='Untitled',[string]\$Note='')
Set-StrictMode -Version Latest; \$ErrorActionPreference='Stop'
\$root = Split-Path (Split-Path \$PSScriptRoot -Parent) -Parent
\$doc  = Join-Path (Join-Path \$root 'docs\backlog') 'CoBacklog.md'
if(-not (Test-Path \$doc)){ throw "Backlog not found: \$doc" }
\$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
\$line  = " \$stamp — \$Title" + (\$(if(\$Note){": \$Note"}else{""}))
\$t = Get-Content \$doc -Raw
if(\$t -match '## Inbox'){
  \$t = \$t -replace '(## Inbox\s\r?\n)', "`\$1\$line`r`n"
}else{
  \$t = \$t + "`r`n## Inbox`r`n\$line`r`n"
}
[IO.File]::WriteAllText(\$doc,\$t,(New-Object System.Text.UTF8Encoding(\$false)))
Write-Host "Parked: \$Title"
\$env:CoDO_FOOTER_DONE='1'
"@
[IO.File]::WriteAllText((Join-Path $doDir 'ParkQuest.ps1'), $parkQuest, (New-Object System.Text.UTF8Encoding($false)))

Write-Host 'Backlog fix applied.'
$env:CoDO_FOOTER_DONE='1'