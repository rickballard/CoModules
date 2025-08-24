param([int]$PR)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$owner='rickballard'; $reponame='CoModules'
$was = gh api repos/$owner/$reponame/branches/main/protection/enforce_admins --jq .enabled
if($was -eq $true){ gh api -X DELETE repos/$owner/$reponame/branches/main/protection/enforce_admins | Out-Null }
gh pr merge $PR --squash --delete-branch --admin
if($was -eq $true){ gh api -X POST repos/$owner/$reponame/branches/main/protection/enforce_admins | Out-Null }
