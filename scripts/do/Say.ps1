param([Parameter(Mandatory)][string]$Word,[string[]]$Args)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$tool = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "tools\CoPing.ps1"
if(-not(Test-Path $tool)){ throw "Missing tools\\CoPing.ps1 (required to Say a CoWord)" }
& $tool -To "COAGENT" -Msg $Word -Data @{ args = $Args }
$env:CoDO_FOOTER_DONE="1"