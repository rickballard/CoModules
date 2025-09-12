param([string]$Repo="$HOME\Documents\GitHub\CoModules",[switch]$Commit)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$Repo=(Resolve-Path $Repo).Path
$SnapD = Join-Path $Repo 'docs\status\BPOE_Snapshots'
if(!(Test-Path $SnapD)){ New-Item -ItemType Directory -Force -Path $SnapD | Out-Null }
function Try-Cmd([string]$exe,[string[]]$args){ try{ (& $exe @args 2>$null) -join "`n" } catch { $null } }
$meta = [ordered]@{
  captured_at_utc = (Get-Date).ToUniversalTime().ToString('o')
  windows         = [System.Environment]::OSVersion.VersionString
  ps_version      = $PSVersionTable.PSVersion.ToString()
  pester_version  = (Get-Module -ListAvailable Pester | Sort-Object Version -Descending | Select-Object -First 1).Version.ToString()
  git_version     = Try-Cmd 'git' @('--version')
  gh_version      = Try-Cmd 'gh'  @('--version')
}
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
($meta | ConvertTo-Json -Depth 5) | Out-File -LiteralPath (Join-Path $SnapD ("snapshot_{0}.json" -f $stamp)) -Encoding UTF8
Write-Host "[OK] snapshot written"
if($Commit){
  try{ Push-Location $Repo; git add -- "docs/status/BPOE_Snapshots" 2>$null; git commit -m "docs(BPOE): snapshot $stamp" 2>$null }
  catch { Write-Warning ("Git commit skipped: {0}" -f $_.Exception.Message) }
  finally { Pop-Location }
}

