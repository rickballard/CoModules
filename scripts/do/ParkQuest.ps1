param([string]$Title="Untitled",[string]$Note="")
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent   # → CoModules
$doc  = Join-Path (Join-Path $root "docs\backlog") "CoBacklog.md"
if(-not (Test-Path $doc)){ throw "Backlog not found: $doc" }
$stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$line  = " $stamp — $Title" + ($(if($Note){": $Note"}else{""}))  # bullet line
$t = Get-Content $doc -Raw
if($t -match '## Inbox'){
  $t = $t -replace '(## Inbox\s\r?\n)', "`$1$line`r`n"
}else{
  $t = $t + "`r`n## Inbox`r`n$line`r`n"
}
[IO.File]::WriteAllText($doc,$t,(New-Object System.Text.UTF8Encoding($false)))
Write-Host "Parked: $Title"
$env:CoDO_FOOTER_DONE="1"