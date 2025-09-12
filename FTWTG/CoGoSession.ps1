Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
param([string]$Temps="$HOME\CoTemps",[string]$Title="",[string]$Proc=""); & "$ft\DO-CoKey.ps1" -Mode context -Title $Title -Proc $Proc -ErrorAction Stop


