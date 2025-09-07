param([Parameter(Mandatory=$true)][string]$Name,[string[]]$Args)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$BIN=Join-Path $HOME "Downloads\CoCacheLocal\bin"
try{ Import-Module (Join-Path $BIN "BPOE.Demark.psm1") -Force }catch{}
try{ Import-Module (Join-Path $BIN "BPOE.Status.psm1") -Force }catch{}
$repoRoot = Split-Path -Parent $PSScriptRoot
$doRoot   = Join-Path $repoRoot "scripts\do"
$__orig   = Get-Location
Set-Location $repoRoot
# busy flag
$RUN = Join-Path $HOME "Downloads\CoCacheLocal\run"; New-Item -Type Directory -Force -Path $RUN | Out-Null
$busyFile = Join-Path $RUN "do.busy"
(Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ") | Set-Content -Path $busyFile
function Get-DL { $d=$env:COCACHE_DOWNLOADS; if(-not $d -or -not (Test-Path $d)){ $d=Join-Path $HOME "Downloads\CoTemp" }; if(-not (Test-Path $d)){ $d=Join-Path $HOME "Downloads" }; $d }
function Flush-CoPingQueue {
try {
  $dl = try { Get-DL } catch {
    $d=$env:COCACHE_DOWNLOADS; if(-not $d -or -not (Test-Path $d)){ $d=Join-Path $HOME "Downloads\CoTemp" }
    if(-not (Test-Path $d)){ $d=Join-Path $HOME "Downloads" }; $d
  }
  $stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
  $argsStr = if ($Args) { [string]::Join(' ', $Args) } elseif (Get-Variable -Name __list -Scope Script -ErrorAction SilentlyContinue) { [string]::Join(' ', $__list) } else { '' }
  $elapsedMs = try { [int]((Get-Date) - $t0).TotalMilliseconds } catch { 0 }
  if (-not $Name)   { $Name   = '(unknown)' }
  if (-not $Status) { $Status = '(unknown)' }
  $crumb = [ordered]@{
    ts=$stamp; kind='do'; name=$Name; status=$Status; args=$argsStr;
    elapsedMs=$elapsedMs; repo=$repoRoot; session=$env:COSESSION_ID
  }
  $json = $crumb | ConvertTo-Json -Depth 6
  $file = Join-Path $dl ("CoAction_{0}_{1}.json" -f $stamp,$Name)
  $json | Set-Content -Path $file
 $json | Set-Content -Path (Join-Path $dl 'CoAction.latest.json')$safe = ($Name -replace '[^\w\.-]','_')
 $json | Set-Content -Path (Join-Path $dl 'CoAction.latest.json')$file = Join-Path $dl ("CoAction_{0}_{1}.json" -f $stamp,$safe)
 $json | Set-Content -Path (Join-Path $dl 'CoAction.latest.json')$json | Set-Content -Path $file
  $json | Set-Content -Path (Join-Path $dl 'CoAction.latest.json')
} catch {}
  $dl = Get-DL
  $q = Join-Path $dl "CoPing.queue"
  if (-not (Test-Path $q)) { return }
  $items = Get-ChildItem $q -Filter "CoPing_.json" -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime
  if ($items -and $items.Count -gt 0) {
    $last = $items[-1]
    $dest = Join-Path $dl ([IO.Path]::GetFileName($last.FullName))
    Copy-Item $last.FullName $dest -Force
    $stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
    [ordered]@{ latest=$dest; ts=$stamp } | ConvertTo-Json | Set-Content -Path (Join-Path $dl "CoPing.latest.json")
    Write-Host ("CoDO: flushed {0} queued CoPings." -f $items.Count)
    # Optional: clear queue after flush
    Remove-Item $q -Recurse -Force -ErrorAction SilentlyContinue
  }
}
$cand = Join-Path $doRoot ($Name + ".ps1")
if (-not (Test-Path $cand)) { $m = Get-ChildItem $doRoot -Filter ($Name + ".ps1") -EA SilentlyContinue | Select-Object -First 1; if ($m) { $cand=$m.FullName } }
if (-not (Test-Path $cand)) {
  Write-Host ("CoDO: task not found: {0}" -f $Name)
  Get-ChildItem $doRoot -Filter ".ps1" | Select-Object -Expand Name
  if (-not $env:BPOE_SET_TOKEN -and -not $env:CoDO_FOOTER_DONE) { try{Write-BPOEStatusLine -Color}catch{}; try{Write-BPOELine -Gradient Rainbow -Char "─"}catch{} }
  Remove-Item $busyFile -ErrorAction SilentlyContinue
  Set-Location $repoRoot; exit 2
}
$__splat=@{}; $__list=@(); $__n = if ($Args) { $Args.Count } else { 0 }
$__i=0
while ($__i -lt $__n) {
  $a = $Args[$__i]
  if ($a -is [string] -and $a.StartsWith("-")) {
    $k = $a.TrimStart("-"); $v = $true
    if (($__i+1) -lt $__n) { $nx=$Args[$__i+1]; if (-not ($nx -is [string] -and $nx.StartsWith("-"))) { $v=$nx; $__i++ } }
    $__splat[$k] = $v
  } else { $__list += $a }
  $__i++
}
$Status="OK"
try { if ($__splat.Count -gt 0 -and $__list.Count -eq 0) { & $cand @__splat } else { & $cand @Args } }
catch { $Status="ERROR"; Write-Error $_ }
finally {
  Flush-CoPingQueue
  Remove-Item $busyFile -ErrorAction SilentlyContinue
  if (-not $env:BPOE_SET_TOKEN -and -not $env:CoDO_FOOTER_DONE) { try{Write-BPOEStatusLine -Color}catch{}; try{Write-BPOELine -Gradient Rainbow -Char "─"}catch{} }
  Set-Location $__orig
}
if ($Status -ne "OK") { exit 1 }