param([Parameter(Mandatory)][ValidateSet("cotemp")][string]$Kind)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
if($Kind -eq "cotemp"){
  Write-Host "📎 CoTemp cleanup recommended (older-than-30d + size threshold tripped). Try: \"clean cotemp\" (dry-run) or \"purge cotemp\"."
}
$env:CoDO_FOOTER_DONE="1"