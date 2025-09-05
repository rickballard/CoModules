# CoHeartbeat.psm1
# Minimal PS7 heartbeat/spinner helpers for long-running steps.
# Usage: Import-Module ./tools/BPOE/CoHeartbeat.psm1; Invoke-WithHeartbeat { git fetch --all --prune } -Activity "git fetch"
# Notes: Writes to console with carriage-return updates; falls back to Write-Progress if -UseProgress is set.

Set-StrictMode -Version Latest

function Write-CoNotice {
  param([string]$Message)
  $ts = (Get-Date).ToString("HH:mm:ss")
  Write-Host "[$ts] $Message"
}

function Invoke-WithHeartbeat {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [ScriptBlock]$Script,
    [string]$Activity = "Working",
    [int]$TimeoutSec = 0,
    [int]$IntervalMs = 250,
    [switch]$UseProgress
  )
  $frames = @('|','/','-','\')
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $job = Start-Job -ScriptBlock $Script
  $i = 0
  try {
    while ($job.State -eq 'Running') {
      $elapsed = '{0:mm\:ss}' -f $sw.Elapsed
      $frame = $frames[$i % $frames.Count]
      if ($UseProgress) {
        Write-Progress -Activity $Activity -Status "Elapsed $elapsed" -PercentComplete -1
      } else {
        $line = "$Activity … $frame  [$elapsed]"
        Write-Host -NoNewline "`r$line"
      }
      Start-Sleep -Milliseconds $IntervalMs
      $i++
      if ($TimeoutSec -gt 0 -and $sw.Elapsed.TotalSeconds -ge $TimeoutSec) {
        Stop-Job $job -Force | Out-Null
        throw "Timeout after $TimeoutSec seconds while: $Activity"
      }
    }
    # flush final frame
    if (-not $UseProgress) { Write-Host "`r$Activity … done [$('{0:mm\:ss}' -f $sw.Elapsed)]        " }
    $output = Receive-Job $job -ErrorAction Stop
    Remove-Job $job -Force | Out-Null
    return $output
  } catch {
    if ($job) { try { Receive-Job $job | Out-Null } catch {} ; try { Remove-Job $job -Force | Out-Null } catch {} }
    throw
  } finally {
    if ($UseProgress) { Write-Progress -Activity $Activity -Completed -Status "done" }
  }
}

function Invoke-Until {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [ScriptBlock]$Test,
    [string]$Activity = "Waiting",
    [int]$TimeoutSec = 120,
    [int]$EveryMs = 500
  )
  $start = Get-Date
  $frames = @('|','/','-','\')
  $i = 0
  while ($true) {
    $ok = $null
    try { $ok = & $Test } catch { $ok = $false }
    if ($ok) {
      $elapsed = (Get-Date) - $start
      $fmt = '{0:mm\:ss}' -f $elapsed
      Write-Host "`r$Activity … done [$fmt]        "
      return $true
    }
    $elapsed = (Get-Date) - $start
    if ($elapsed.TotalSeconds -ge $TimeoutSec) {
      throw "Timeout after $TimeoutSec seconds while: $Activity"
    }
    $frame = $frames[$i % $frames.Count]
    $fmt = '{0:mm\:ss}' -f $elapsed
    Write-Host -NoNewline "`r$Activity … $frame  [$fmt]"
    Start-Sleep -Milliseconds $EveryMs
    $i++
  }
}

Export-ModuleMember -Function Write-CoNotice, Invoke-WithHeartbeat, Invoke-Until