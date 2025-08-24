param([string]$Repo = 'CoModules')
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$path = Join-Path $HOME "Documents\GitHub\$Repo"
if(!(Test-Path -LiteralPath $path)){ throw "Repo not found: $path" }
Set-Location -LiteralPath $path; git status -sb;
