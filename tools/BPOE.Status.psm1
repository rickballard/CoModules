Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
function Get-BPOEBloatIndex {
  [CmdletBinding()]
  param(
    [int]$BudgetWsMB   = [int]($env:BPOE_BUDGET_WS_MB   ?? 800),
    [int]$BudgetMods   = [int]($env:BPOE_BUDGET_MODS    ?? 120),
    [int]$BudgetHist   = [int]($env:BPOE_BUDGET_HIST    ?? 300),
    [int]$BudgetBus    = [int]($env:BPOE_BUDGET_BUS     ?? 500),
    [int]$BudgetWraps  = [int]($env:BPOE_BUDGET_WRAPS   ?? 10)
  )
  function _clamp01([double]$x){ if($x -lt 0){0}elseif($x -gt 1){1}else{$x} }
  $ccl  = $env:COCACHE_LOCAL ?? (Join-Path $HOME 'Downloads/CoCacheLocal')
  $dl   = $env:COCACHE_DOWNLOADS ?? (Join-Path $HOME 'Downloads')
  $sid  = $env:COSESSION_ID
  $base = if ($sid) { Join-Path (Join-Path $ccl 'sessions') $sid } else { $ccl }
  $log  = Join-Path $base 'log.ndjson'
  $proc    = Get-Process -Id $PID
  $wsMB    = [math]::Round($proc.WorkingSet64/1MB,1)
  $pmMB    = [math]::Round($proc.PrivateMemorySize64/1MB,1)
  $mods    = (Get-Module | Measure-Object).Count
  $hist    = (Get-History | Measure-Object).Count
  $logLines= if (Test-Path $log) { (Get-Content $log -ErrorAction SilentlyContinue | Measure-Object -Line).Lines } else { 0 }
  $outWrap = (Get-ChildItem $dl -Filter 'CoWrap*.zip' -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike 'CoWrap_DELETABLE-*' } | Measure-Object).Count
  $doneWrap= (Get-ChildItem $dl -Filter 'CoWrap_DELETABLE-*.zip' -ErrorAction SilentlyContinue | Measure-Object).Count
  $f_ws   = _clamp01($wsMB   / $BudgetWsMB)
  $f_mods = _clamp01($mods   / $BudgetMods)
  $f_hist = _clamp01($hist   / $BudgetHist)
  $f_bus  = _clamp01($logLines / $BudgetBus)
  $f_wrap = _clamp01($outWrap / $BudgetWraps)
  $w = @{ws=0.5; mods=0.15; hist=0.10; bus=0.15; wraps=0.10}
  try { if ($env:BPOE_BLOAT_WEIGHTS) { $ow = $env:BPOE_BLOAT_WEIGHTS | ConvertFrom-Json; foreach($k in $ow.PSObject.Properties.Name){ $w[$k]=$ow.$k } } } catch {}
  $score = [math]::Round(100 * ($w.ws*$f_ws + $w.mods*$f_mods + $w.hist*$f_hist + $w.bus*$f_bus + $w.wraps*$f_wrap))
  $band  = if ($score -le 33) { 'LOW' } elseif ($score -le 66) { 'MEDIUM' } else { 'HIGH' }
  [pscustomobject]@{
    BBI=$score; Band=$band; WS_MB=$wsMB; Private_MB=$pmMB; Mods=$mods; Hist=$hist;
    BusLines=$logLines; WrapsOutstanding=$outWrap; WrapsHandled=$doneWrap;
    Budgets=[pscustomobject]@{WS=$BudgetWsMB; Mods=$BudgetMods; Hist=$BudgetHist; Bus=$BudgetBus; Wraps=$BudgetWraps}
  }
}
function Write-BPOEStatusLine { [CmdletBinding()] param([switch]$Color)
  $s = Get-BPOEBloatIndex
  $prefix = if ($Color) {
    $green  = "$([char]27)[38;2;0;200;120m"; $yellow = "$([char]27)[38;2;255;200;0m"; $red = "$([char]27)[38;2;255;90;90m"; $reset="$([char]27)[0m"
    $col = switch ($s.Band) { 'LOW' {$green} 'MEDIUM' {$yellow} default {$red} }
    "{0}[BBI {1}% {2}]{3}" -f $col,$s.BBI,$s.Band,$reset
  } else { "[BBI {0}% {1}]" -f $s.BBI,$s.Band }
  $line = "{0} WS {1}/{2}MB · Mods {3}/{4} · Hist {5}/{6} · Bus {7}/{8} · Wraps {9}/{10}" -f `
          $prefix,$s.WS_MB,$s.Budgets.WS,$s.Mods,$s.Budgets.Mods,$s.Hist,$s.Budgets.Hist,$s.BusLines,$s.Budgets.Bus,$s.WrapsOutstanding,$s.Budgets.Wraps
  Write-Host $line
}
Export-ModuleMember -Function Get-BPOEBloatIndex,Write-BPOEStatusLine
