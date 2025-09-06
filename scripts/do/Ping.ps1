Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
param([string]$To="ANY",[string]$Msg="hello from CoDO",[hashtable]$Data)
& (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "tools\CoPing.ps1") -To $To -Msg $Msg -Data $Data
$env:CoDO_FOOTER_DONE = "1"; try{ Write-BPOEStatusLine -Color }catch{}; try{ Write-BPOELine -Gradient Rainbow -Char "─" }catch{}
