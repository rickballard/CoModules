Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

function Get-CoClaimPaths {
  $dir = Join-Path $HOME 'Downloads\CoTemp'; [IO.Directory]::CreateDirectory($dir)|Out-Null
  $sid = if($env:COSESSION_ID){$env:COSESSION_ID}else{ "unknown" }
  [pscustomobject]@{ Dir=$dir; This=(Join-Path $dir ("CoClaim_{0}.json" -f $sid)); Pointer=(Join-Path $dir "CoClaim.latest.json") }
}

function Set-CoClaim {
  [CmdletBinding()] param([string]$RepoRoot=(Get-Location).Path,[string]$Branch,[string[]]$Paths=@(),[string]$Message="",[int]$TtlMinutes=30)
  $p = Get-CoClaimPaths
  $obj = [ordered]@{
    session   = $env:COSESSION_ID
    repo      = $RepoRoot
    branch    = if($Branch){$Branch}else{ (& git branch --show-current 2>$null) }
    paths     = $Paths
    message   = $Message
    createdUtc= [DateTime]::UtcNow.ToString("o")
    expiresUtc= ([DateTime]::UtcNow.AddMinutes($TtlMinutes)).ToString("o")
  }
  $tmp = ($p.This + ".tmp")
  ($obj | ConvertTo-Json -Depth 6) | Out-File -LiteralPath $tmp -Encoding utf8
  Move-Item -LiteralPath $tmp -Destination $p.This -Force
  Copy-Item -LiteralPath $p.This -Destination $p.Pointer -Force
  return $p.This
}

function Get-CoClaims {
  [CmdletBinding()] param([string]$Dir)
  if(-not $Dir){ $Dir = (Get-CoClaimPaths).Dir }
  Get-ChildItem -LiteralPath $Dir -Filter "CoClaim_*.json" |
    Get-Content -Raw -EA SilentlyContinue |
    ForEach-Object { try { $_ | ConvertFrom-Json } catch {} }
}

function Clear-CoClaim {
  [CmdletBinding()] param()
  $p = Get-CoClaimPaths
  if(Test-Path $p.This){ Remove-Item -LiteralPath $p.This -Force }
}

Export-ModuleMember -Function Get-CoClaimPaths,Set-CoClaim,Get-CoClaims,Clear-CoClaim