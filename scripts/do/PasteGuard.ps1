param([ValidateSet("on","off")][string]$Mode="on")
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
try { Import-Module PSReadLine -ErrorAction SilentlyContinue } catch {}
try { $o=Get-PSReadLineOption; if ($o.PSObject.Properties.Name -contains "ConfirmOnPaste") { Set-PSReadLineOption -ConfirmOnPaste:($Mode -eq "on") | Out-Null } } catch {}
Write-Host ("PasteGuard: ConfirmOnPaste -> {0}" -f $Mode.ToUpper())
Write-Host "Tip: In Windows Terminal Settings, set: Paste on right-click = Off; Right-click opens menu = On."
$env:CoDO_FOOTER_DONE="1"