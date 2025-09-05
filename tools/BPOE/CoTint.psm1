Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function Write-CoTeach { param([Parameter(Mandatory)][string]$Message) Write-Host ("🟢 TEACH  " + $Message) -ForegroundColor Green }
function Write-CoVibe  { param([Parameter(Mandatory)][string]$Message) Write-Host ("🟡 VIBE   " + $Message) -ForegroundColor Yellow }
function Write-CoAdv   { param([Parameter(Mandatory)][string]$Message) Write-Host ("🔵 ADVISORY " + $Message) -ForegroundColor Cyan }
Set-Alias CoTeach Write-CoTeach
Set-Alias CoVibe  Write-CoVibe
Set-Alias CoAdv   Write-CoAdv
