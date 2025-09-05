Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$files = @("scripts/pr-admin-merge.ps1","scripts/pr-solo-merge.ps1")
foreach($f in $files){
  if(-not (Test-Path $f)){ continue }
  $raw = Get-Content -Raw -LiteralPath $f
  if($raw -match 'Invoke-WithHeartbeat'){ Write-Host "Already wrapped: $f"; continue }
  $name = [IO.Path]::GetFileName($f)
  $hb = @"
Set-StrictMode -Version Latest
`$ErrorActionPreference = 'Stop'
# Import heartbeat if available; else define pass-through
try {
  `$mod = Join-Path `$PSScriptRoot '..\tools\BPOE\CoHeartbeat.psm1'
  if(Test-Path `$mod){ Import-Module `$mod -Force -ErrorAction Stop }
} catch {}
if(-not (Get-Command Invoke-WithHeartbeat -ErrorAction SilentlyContinue)){
  function Invoke-WithHeartbeat { param([string]`$Message,[ScriptBlock]`$Script) & `$Script }
}
Invoke-WithHeartbeat -Message "$name" {
$raw
}
"@
  $hb | Set-Content -LiteralPath $f -Encoding utf8
  Write-Host "Wrapped: $f"
}
