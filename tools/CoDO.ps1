param([Parameter(Mandatory)][string]$Name,[string[]]$Args)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$BIN="$HOME\Downloads\CoCacheLocal\bin"
try{Import-Module (Join-Path $BIN "BPOE.Demark.psm1") -Force}catch{}
try{Import-Module (Join-Path $BIN "BPOE.Status.psm1") -Force}catch{}
$root = Split-Path -Parent $PSScriptRoot
$dop  = Join-Path $root "scripts\do"
$cand = Join-Path $dop ($Name + ".ps1")
if(-not(Test-Path $cand)){
  $match = Get-ChildItem $dop -Filter ($Name+"*.ps1") | Select-Object -First 1
  if($match){ $cand=$match.FullName }
}
if(-not(Test-Path $cand)){
  Write-Host "CoDO: task not found: $Name"
  Get-ChildItem $dop -Filter "*.ps1" | Select-Object -Expand Name
  exit 2
}
$Status="OK"
try   { & $cand @Args }
catch { $Status="ERROR"; Write-Error $_ }
try{ Write-BPOEStatusLine -Color }catch{}
try{ Write-BPOELine -Gradient Rainbow -Char "─" }catch{}
if($Status -ne "OK"){ exit 1 }
