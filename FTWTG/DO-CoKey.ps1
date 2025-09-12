param(
  [ValidateSet("context","omni")][string]$Mode="context",
  [string]$Title="", [string]$Proc="", [string]$Temps="$HOME\CoTemps"
)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$queue = Join-Path $Temps "queue"
if (!(Test-Path $queue)) { New-Item -ItemType Directory -Force -Path $queue | Out-Null }
if ($Mode -eq "omni") {
  $flag = Join-Path $queue ("omni_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".go")
  New-Item -ItemType File -Path $flag | Out-Null
  Write-Host "[OK] Omni trigger -> $flag"; exit 0
}
# context
$meta = [ordered]@{ at=(Get-Date).ToString("o"); title=$Title; proc=$Proc; mode=$Mode }
$file = Join-Path $queue ("context_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".json")
($meta | ConvertTo-Json -Depth 6) | Out-File -LiteralPath $file -Encoding UTF8
Write-Host "[OK] Context trigger -> $file"

