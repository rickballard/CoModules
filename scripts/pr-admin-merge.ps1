Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# Import heartbeat if available; else define pass-through
try {
  $mod = Join-Path $PSScriptRoot '..\tools\BPOE\CoHeartbeat.psm1'
  if(Test-Path $mod){ Import-Module $mod -Force -ErrorAction Stop }
} catch {}
if(-not (Get-Command Invoke-WithHeartbeat -ErrorAction SilentlyContinue)){
  function Invoke-WithHeartbeat { param([string]$Message,[ScriptBlock]$Script) & $Script }
}
Invoke-WithHeartbeat -Message "pr-admin-merge.ps1" {
param([int]$PR)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$owner='rickballard'; $reponame='CoModules'
$was = gh api repos/$owner/$reponame/branches/main/protection/enforce_admins --jq .enabled
if($was -eq $true){ gh api -X DELETE repos/$owner/$reponame/branches/main/protection/enforce_admins | Out-Null }
gh pr merge $PR --squash --delete-branch --admin
if($was -eq $true){ gh api -X POST repos/$owner/$reponame/branches/main/protection/enforce_admins | Out-Null }

}
