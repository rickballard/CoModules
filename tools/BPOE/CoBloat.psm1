Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Set-BpoeChatQuietDefaults {
  $global:ProgressPreference    = "SilentlyContinue"
  $global:VerbosePreference     = "SilentlyContinue"
  $global:DebugPreference       = "SilentlyContinue"
  $global:InformationPreference = "Continue"
}

function Invoke-WithBloatGuard {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$Message,
    [Parameter(Mandatory)][ScriptBlock]$Script,
    [int]$MaxLines = 120,
    [string]$OutDir
  )
  if(-not $OutDir){ $OutDir = Join-Path $HOME "Downloads\CoTemp" }
  [IO.Directory]::CreateDirectory($OutDir) | Out-Null

  # Capture all output as one string (no streaming to console)
  $all = (& $Script *>&1 | Out-String -Width 400)

  # Real split on CRLF/LF; drop trailing empty
  $lines = if([string]::IsNullOrEmpty($all)){ @() } else {
    [regex]::Split($all, "\r?\n") | Where-Object { $_ -ne "" }
  }

  $printed = [Math]::Min($lines.Count, $MaxLines)

  # Best-effort: clear idle dots before we print
  try { if(Get-Command Clear-CoIdleDotsLine -EA SilentlyContinue){ Clear-CoIdleDotsLine } } catch {}

  if($printed -gt 0){
    ($lines | Select-Object -First $printed) -join [Environment]::NewLine | ForEach-Object { if($_){ Write-Host $_ } }
  }

  $overflowPath = $null
  if($lines.Count -gt $MaxLines){
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    $overflowPath = Join-Path $OutDir ("CoBloat_{0}.log" -f $ts)
    [IO.File]::WriteAllText($overflowPath, $all, [Text.UTF8Encoding]::new($true))
    Write-Host ("[bloat] {0} lines total; wrote overflow → {1}" -f $lines.Count, $overflowPath) -ForegroundColor DarkGray
  }

  [pscustomobject]@{ Lines=$lines.Count; Printed=$printed; Overflow=$overflowPath }
}

Export-ModuleMember -Function Set-BpoeChatQuietDefaults,Invoke-WithBloatGuard