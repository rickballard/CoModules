Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-BpoeStatusObject {
  [CmdletBinding()] param([string]$Message="")
  $hg   = [bool]($env:BPOE_HUMANGATE_ENTER_OK -match '^(1|true|yes|on)$')
  $exit = [bool](Get-EventSubscriber -SourceIdentifier PowerShell.Exiting -ErrorAction SilentlyContinue)
  $evt  = @(Get-EventSubscriber -ErrorAction SilentlyContinue | Where-Object { $_.SourceIdentifier -eq 'OEStatusTimer' })
  $job  = @(Get-Job -Name OEStatusTimer -ErrorAction SilentlyContinue)
  $oe   = if ($evt.Count -or $job.Count) { 'Present' } else { 'None' }
  [pscustomobject]@{
    Message=$Message; HumanGateEnabled=$hg; ExitHookPresent=$exit; OETimers=$oe;
    Mods=(Get-Module | Measure-Object).Count;
    Jobs=(Get-Job -ErrorAction SilentlyContinue | Measure-Object).Count;
    Events=(Get-EventSubscriber -ErrorAction SilentlyContinue | Measure-Object).Count;
    Repo=(Get-Location).Path; TimeUtc=[DateTime]::UtcNow.ToString('o')
  }
}

function Write-BpoePulse {
  [CmdletBinding()] param([string]$Message="", [string]$OutDir)
  if(-not $OutDir){ $OutDir = Join-Path $HOME 'Downloads\CoTemp' }
  [IO.Directory]::CreateDirectory($OutDir) | Out-Null
  $obj = Get-BpoeStatusObject -Message $Message
  $line = ("BPOE → {0} | HG={1}; ExitHook={2}; OE={3}; Mods={4}; Jobs={5}; Events={6}" -f
    ($obj.Message), ($(if($obj.HumanGateEnabled){'On'}else{'Off'}),
    ($(if($obj.ExitHookPresent){'OK'}else{'MISS'})), $obj.OETimers, $obj.Mods, $obj.Jobs, $obj.Events))
  $ts  = Get-Date -Format 'yyyyMMdd_HHmmss'
  $txt = Join-Path $OutDir ("BPOE_Status_{0}.txt" -f $ts)
  $json= $txt -replace '\.txt$','.json'
  $ptr = Join-Path $OutDir 'CoStatus.latest.json'
  [IO.File]::WriteAllText($txt, $line + [Environment]::NewLine, [Text.UTF8Encoding]::new($true))
  ($obj | ConvertTo-Json -Depth 6) | Out-File -LiteralPath $json -Encoding utf8
  Move-Item -LiteralPath $json -Destination $ptr -Force
  Write-Host $line -ForegroundColor Cyan
  return $txt
}

function Invoke-WithPulse {
  [CmdletBinding()] param([Parameter(Mandatory)][string]$Message,[Parameter(Mandatory)][ScriptBlock]$Script,[string]$OutDir)
  try { & $Script } finally { Write-BpoePulse -Message $Message -OutDir $OutDir | Out-Null }
}

Export-ModuleMember -Function Get-BpoeStatusObject,Write-BpoePulse,Invoke-WithPulse