param([Parameter(Mandatory)][string]$RelativePath,[Parameter(Mandatory)][string[]]$Lines)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
. (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "tools\CoDrop.ps1")
$res = Save-CoText -RelativePath $RelativePath -Lines $Lines
Write-Host ("Saved: {0} ({1} bytes)" -f $res.Path,$res.Bytes)
$env:CoDO_FOOTER_DONE="1"