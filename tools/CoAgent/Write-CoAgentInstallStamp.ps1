Import-Module "$PSScriptRoot/CoAgent.Expiry.psm1" -Force
param([string]$Version = "unknown")
Write-CoAgentInstallStamp -Version $Version
Write-Host ("[CoAgent] install stamp written ({0})" -f $Version) -ForegroundColor Green