param([string]$Title = "Idea")
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$root = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "docs\ideas"
New-Item -Type Directory -Force -Path $root | Out-Null
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$file = Join-Path $root ("{0}_{1}.md" -f $stamp, ($Title -replace "[^\w\-]","_"))
$lines = @("# Idea","Date: " + (Get-Date).ToString("yyyy-MM-dd HH:mm"),"","(jot notes here)")
$enc = New-Object System.Text.UTF8Encoding($false); [IO.File]::WriteAllBytes($file,$enc.GetBytes([string]::Join([Environment]::NewLine,$lines)))
Start-Process $file
Write-Host ("Saved: {0}" -f $file)
$env:CoDO_FOOTER_DONE="1"