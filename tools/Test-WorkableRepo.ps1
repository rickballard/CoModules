Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
try{Import-Module "$HOME\Downloads\CoCacheLocal\bin\BPOE.Status.psm1" -Force}catch{}
try{Write-BPOEStatusLine -Color}catch{}
exit 0
