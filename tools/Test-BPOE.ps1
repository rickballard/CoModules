[CmdletBinding()]
param([switch]$Quiet)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'
function Add-BpoeLogLine {
  param([string[]]$Lines)
  try {
    $root = Split-Path -Parent $PSScriptRoot
    $log  = Join-Path $root 'docs\methods\BPOE_LOG.md'
    [IO.Directory]::CreateDirectory((Split-Path $log)) | Out-Null
    $text = [string]::Join([Environment]::NewLine, $Lines)
    Add-Content -Path $log -Encoding UTF8 -Value $text
  } catch {}
}
function Test-AstParse {
  param([Parameter(Mandatory)][string]$Path)
  [System.Management.Automation.Language.Token[]]$t = $null
  [System.Management.Automation.Language.ParseError[]]$e = $null
  [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$t, [ref]$e) | Out-Null
  if ($e) { return @($e) } else { return @() }
}
$issues  = New-Object System.Collections.Generic.List[string]
$checks  = New-Object System.Collections.Generic.List[string]
$now     = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
# 1) Profile parses clean
if (Test-Path $PROFILE) {
  $errs = Test-AstParse -Path $PROFILE
  if ($errs.Count) {
    $issues.Add(("Profile parse errors: " + ($errs | ForEach-Object { "" + $_.Message + " @ " + $_.Extent.StartLineNumber + ":" + $_.Extent.StartColumnNumber } -join '; ')))
  } else { $checks.Add('Profile AST: OK') }
} else { $checks.Add('Profile missing (OK if intentional)') }
# 2) Prompt invoke is safe
try {
  $havePrompt = Get-Item function:prompt -ErrorAction SilentlyContinue
  if ($havePrompt) {
    $had=$false; $prev=$null
    try { $prev = Get-Variable -Name __OEStatusNext -Scope Global -ValueOnly -ErrorAction Stop; $had=$true } catch {}
    try { $global:__OEStatusNext = [DateTime]::MaxValue } catch {}
    try { $null = & $havePrompt.ScriptBlock } catch { $issues.Add("prompt invocation error: " + $_.Exception.Message) }
    finally { if ($had) { $global:__OEStatusNext = $prev } else { Remove-Variable -Name __OEStatusNext -Scope Global -ErrorAction SilentlyContinue } }
    if (-not $issues.Count -or $issues[-1] -notlike "prompt invocation error:*") { $checks.Add('Prompt invoke: OK') }
  } else { $checks.Add('Prompt not defined (OK)') }
} catch { $issues.Add("prompt probe failed: " + $_.Exception.Message) }
# 3) No background OE timers
try {
  $evt = Get-EventSubscriber -SourceIdentifier OEStatusTimer -ErrorAction SilentlyContinue
  $job = Get-Job -Name OEStatusTimer -ErrorAction SilentlyContinue
  if ($evt -or $job) { $issues.Add('Background OEStatusTimer present (should be prompt-driven only)') } else { $checks.Add('No OE timers: OK') }
} catch { $issues.Add("timer probe failed: " + $_.Exception.Message) }
# 4) Exit hook uses engine event
try {
  $ex = Get-EventSubscriber -SourceIdentifier PowerShell.Exiting -ErrorAction SilentlyContinue
  if ($ex) { $checks.Add('Exit hook: PowerShell.Exiting OK') } else { $issues.Add('Exit hook missing (PowerShell.Exiting not registered)') }
} catch { $issues.Add("exit-hook probe failed: " + $_.Exception.Message) }
# 5) Workbench bits (if repo exists)
try {
  $repoCiv = Join-Path $HOME 'Documents\GitHub\CoCivium'
  if (Test-Path $repoCiv) {
    $okL = Test-Path (Join-Path $repoCiv 'scripts\workbench\Start-CoCiviumWorkbench.ps1')
    $okI = Test-Path (Join-Path $repoCiv 'scripts\workbench\Workbench-Inner.ps1')
    if ($okL -and $okI) { $checks.Add('Workbench launcher/inner: OK') }
    else { $issues.Add('Workbench scripts missing (launcher/inner)') }
  }
} catch { $issues.Add("workbench probe failed: " + $_.Exception.Message) }
# Emit
if ($issues.Count) {
  $lines = @('' , "## BPOE Preflight — $now", '- Result: FAIL', '- Issues:') + ($issues | ForEach-Object { '  - ' + $_ }) + @('- Checks:') + ($checks | ForEach-Object { '  - ' + $_ })
  Add-BpoeLogLine -Lines $lines
  if (-not $Quiet) { Write-Warning ($issues -join '; ') }
} else {
  if (-not $Quiet) { Write-Verbose 'BPOE Preflight OK' }
}