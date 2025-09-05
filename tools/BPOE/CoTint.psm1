Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function Write-CoTeach { param([Parameter(Mandatory)][string]$Message) Write-Host ("🟢 TEACH  " + $Message) -ForegroundColor Green }
function Write-CoVibe  { param([Parameter(Mandatory)][string]$Message) Write-Host ("🟡 VIBE   " + $Message) -ForegroundColor Yellow }
function Write-CoAdv   { param([Parameter(Mandatory)][string]$Message) Write-Host ("🔵 ADVISORY " + $Message) -ForegroundColor Cyan }
Set-Alias CoTeach Write-CoTeach
Set-Alias CoVibe  Write-CoVibe
Set-Alias CoAdv   Write-CoAdv

# --- Optional TEMP takeover: adjusts some UI colors, never touches Red, and restores on exit ---
$script:CoTint_State = $null
function Enable-CoTintTakeover {
  Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
  $state = @{ Saved=@{}; HasPSReadLine=$false }
  try {
    $state.Saved.PrivateData = @{
      WarningForegroundColor = $host.PrivateData.WarningForegroundColor
      WarningBackgroundColor = $host.PrivateData.WarningBackgroundColor
      VerboseForegroundColor = $host.PrivateData.VerboseForegroundColor
      VerboseBackgroundColor = $host.PrivateData.VerboseBackgroundColor
      DebugForegroundColor   = $host.PrivateData.DebugForegroundColor
      DebugBackgroundColor   = $host.PrivateData.DebugBackgroundColor
      # NOTE: No Error colors saved/changed; red stays owner of "something is wrong".
    }
  } catch {}
  try {
    if (Get-Module -ListAvailable PSReadLine) {
      Import-Module PSReadLine -ErrorAction Stop
      $state.HasPSReadLine = $true
      $opt = Get-PSReadLineOption
      if ($opt -and $opt.Colors) { $state.Saved.PSReadLineColors = $opt.Colors.Clone() }
    }
  } catch {}
  # Gentle tint: shift warnings/verbose/debug without touching errors.
  try {
    $host.PrivateData.WarningForegroundColor = 'Yellow'
    $host.PrivateData.VerboseForegroundColor = 'Cyan'
    $host.PrivateData.DebugForegroundColor   = 'Gray'
  } catch {}
  # Minimal PSReadLine nudge (only if module available); leave token reds alone.
  try {
    if ($state.HasPSReadLine) {
      $c = @{}
      # leave $c.Error untouched; sample tweak: make Emphasis cyan for hints
      $c.Emphasis = 'Cyan'
      Set-PSReadLineOption -Colors $c
    }
  } catch {}
  $script:CoTint_State = $state
}
function Disable-CoTintTakeover {
  Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
  if (-not $script:CoTint_State) { return }
  try {
    $pd=$script:CoTint_State.Saved.PrivateData
    if ($pd) {
      $host.PrivateData.WarningForegroundColor = $pd.WarningForegroundColor
      $host.PrivateData.WarningBackgroundColor = $pd.WarningBackgroundColor
      $host.PrivateData.VerboseForegroundColor = $pd.VerboseForegroundColor
      $host.PrivateData.VerboseBackgroundColor = $pd.VerboseBackgroundColor
      $host.PrivateData.DebugForegroundColor   = $pd.DebugForegroundColor
      $host.PrivateData.DebugBackgroundColor   = $pd.DebugBackgroundColor
    }
  } catch {}
  try {
    if ($script:CoTint_State.HasPSReadLine -and $script:CoTint_State.Saved.PSReadLineColors) {
      Set-PSReadLineOption -Colors $script:CoTint_State.Saved.PSReadLineColors
    }
  } catch {}
  Remove-Variable CoTint_State -Scope Script -ErrorAction SilentlyContinue
}

# Convenience wrappers to run a scriptblock under takeover, then always restore
function Use-CoTintTakeover {
  [CmdletBinding()] param([Parameter(Mandatory)][scriptblock]$Script)
  Enable-CoTintTakeover
  try { & $Script } finally { Disable-CoTintTakeover }
}
