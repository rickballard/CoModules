Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
function Get-DL {
  $d=$env:COCACHE_DOWNLOADS
  if(-not $d -or -not (Test-Path $d)){ $d=Join-Path $HOME "Downloads\CoTemp" }
  if(-not (Test-Path $d)){ $d=Join-Path $HOME "Downloads" }
  return $d
}
function Mark([string]$ok,[string]$msg){
  $fg = if($ok -eq 'OK'){ 'Green' } elseif($ok -eq 'WARN'){ 'Yellow' } else { 'Red' }
  Write-Host ("[{0}] {1}" -f $ok,$msg) -ForegroundColor $fg
}
$dl = Get-DL
$modeFile = Join-Path (Join-Path $HOME "Downloads\CoCacheLocal\run") "CoSession.mode.json"
$mode = try { (Get-Content $modeFile -Raw | ConvertFrom-Json).mode } catch { "demo" }

Write-Host "== Verify CoStack ==" -ForegroundColor Cyan

# 1) CoTemp present
if(Test-Path $dl){ Mark 'OK' ("CoTemp: {0}" -f $dl) } else { Mark 'FAIL' "CoTemp path missing"; exit 1 }

# 2) Session mode
Mark 'OK' ("Session mode: {0}" -f $mode)

# 3) Breadcrumb pointers exist (not required, but helpful)
$wrapPtr = Join-Path $dl "CoWrap.latest.json"
$pingPtr = Join-Path $dl "CoPing.latest.json"
if(Test-Path $wrapPtr -or Test-Path $pingPtr){ Mark 'OK' "Breadcrumbs present (wrap and/or ping)" } else { Mark 'WARN' "No breadcrumbs yet (expected on first run)" }

# 4) DEMO purge gate sanity
$clean = Join-Path (Split-Path $PSScriptRoot -Parent) "do\CleanCoTemp.ps1"
if(Test-Path $clean){
  $out = & $clean -Purge | Out-String
  if($mode -ne 'live' -and $out -match '\[DEMO\]'){ Mark 'OK' "CleanCoTemp purge is gated in DEMO" } 
  elseif($mode -eq 'live'){ Mark 'WARN' "LIVE mode: purge not gated (as intended)" } 
  else { Mark 'FAIL' "Expected DEMO gate message not detected" }
} else { Mark 'WARN' "CleanCoTemp.ps1 not found" }

# 5) CoPing queue + flush path works
$run = Join-Path $HOME "Downloads\CoCacheLocal\run"
New-Item -Type Directory -Force -Path $run | Out-Null
$busy = Join-Path $run "do.busy"
"hold" | Set-Content $busy
$stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
$toolPing = Join-Path (Split-Path $PSScriptRoot -Parent) "tools\CoPing.ps1"
$latestBefore = if(Test-Path $pingPtr){ (Get-Content $pingPtr -Raw | ConvertFrom-Json).latest } else { "" }
if(Test-Path $toolPing){ & $toolPing -To "COAGENT" -Msg ("verify-"+$stamp) | Out-Null } else { Mark 'FAIL' "CoPing.ps1 missing"; Remove-Item $busy -EA SilentlyContinue; exit 1 }
# Flush via a DO exit (Breadcrumbs prints and CoDO finally{} flushes queues)
$coDo = Join-Path (Split-Path $PSScriptRoot -Parent) "tools\CoDO.ps1"
& $coDo -Name Breadcrumbs | Out-Null
Remove-Item $busy -EA SilentlyContinue
Start-Sleep -Milliseconds 200
if(Test-Path $pingPtr){
  $after = (Get-Content $pingPtr -Raw | ConvertFrom-Json).latest
  if($after -and $after -ne $latestBefore){ Mark 'OK' "CoPing queue flushed → $after" } else { Mark 'FAIL' "CoPing.latest.json did not advance" }
} else { Mark 'FAIL' "CoPing.latest.json missing after flush" }

# 6) Crumbs stats (optional)
$stats = Join-Path $run "CoBread.stats.json"
if(Test-Path $stats){ Mark 'OK' ("Crumbs stats: " + (Get-Content $stats -Raw)) } else { Mark 'WARN' "No crumbs stats yet" }

$env:CoDO_FOOTER_DONE="1"