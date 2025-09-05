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
Invoke-WithHeartbeat -Message "pr-solo-merge.ps1" {
param([int]$PR,[int]$restore=1)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$owner='rickballard'; $reponame='CoModules'
$cur = gh api repos/$owner/$reponame/branches/main/protection/required_pull_request_reviews --jq .required_approving_review_count 2>$null
gh api -X PATCH repos/$owner/$reponame/branches/main/protection/required_pull_request_reviews -f required_approving_review_count=0 | Out-Null
gh pr merge $PR --squash --delete-branch --admin
$target = if($null -ne $cur){ $cur } else { $restore }
gh api -X PATCH repos/$owner/$reponame/branches/main/protection/required_pull_request_reviews -f required_approving_review_count=$target | Out-Null

}
