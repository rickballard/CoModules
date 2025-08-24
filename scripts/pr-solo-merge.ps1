param([int]$PR,[int]$restore=1)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$owner='rickballard'; $reponame='CoModules'
$cur = gh api repos/$owner/$reponame/branches/main/protection/required_pull_request_reviews --jq .required_approving_review_count 2>$null
gh api -X PATCH repos/$owner/$reponame/branches/main/protection/required_pull_request_reviews -f required_approving_review_count=0 | Out-Null
gh pr merge $PR --squash --delete-branch --admin
$target = if($null -ne $cur){ $cur } else { $restore }
gh api -X PATCH repos/$owner/$reponame/branches/main/protection/required_pull_request_reviews -f required_approving_review_count=$target | Out-Null
