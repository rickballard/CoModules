param([string]$Repo="$HOME\Documents\GitHub\CoModules")
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
if (Test-Path $Repo) { Set-Location $Repo }
try { Import-Module PSReadLine -ErrorAction SilentlyContinue } catch {}
try { $o=Get-PSReadLineOption; if ($o.PSObject.Properties.Name -contains "ConfirmOnPaste") { Set-PSReadLineOption -ConfirmOnPaste:$true | Out-Null } } catch {}
Write-Host ("Prompt reset to repo: {0}" -f (Get-Location).Path)
Write-Host "If you see a bare PS>/>>, press Esc to clear the partial line or Ctrl+C to cancel."
$env:CoDO_FOOTER_DONE="1"