Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop"
$dl  = $env:COCACHE_DOWNLOADS ?? (Join-Path $HOME "Downloads")
$bin = Join-Path $HOME "Downloads\CoCacheLocal\bin"

# Action: try Unwrap; ignore if nothing to consume
$action = {
  try {
    $bin = Join-Path $HOME "Downloads\CoCacheLocal\bin"
    $unw = Join-Path $bin  "Unwrap.ps1"
    if (Test-Path $unw) { & $unw -Agent "W" | Out-Null }
  } catch { }
}

# Watch zips
$zipWatcher = [IO.FileSystemWatcher]::new($dl, "CoWrap*.zip")
$zipWatcher.IncludeSubdirectories = $false
$zipWatcher.EnableRaisingEvents = $true
$sub1 = Register-ObjectEvent -InputObject $zipWatcher -EventName Created -SourceIdentifier "cowrap-zip-created"  -Action $action
$sub2 = Register-ObjectEvent -InputObject $zipWatcher -EventName Changed -SourceIdentifier "cowrap-zip-changed"  -Action $action

# Watch pointer
$ptrWatcher = [IO.FileSystemWatcher]::new($dl, "CoWrap.latest.json")
$ptrWatcher.IncludeSubdirectories = $false
$ptrWatcher.EnableRaisingEvents = $true
$sub3 = Register-ObjectEvent -InputObject $ptrWatcher -EventName Created -SourceIdentifier "cowrap-pointer-created" -Action $action
$sub4 = Register-ObjectEvent -InputObject $ptrWatcher -EventName Changed -SourceIdentifier "cowrap-pointer-changed" -Action $action

$global:CoWrapWatcher = [pscustomobject]@{
  Downloads = $dl
  StartedUtc = (Get-Date).ToUniversalTime().ToString('o')
  Watchers = @($zipWatcher, $ptrWatcher)
  Subs     = @($sub1, $sub2, $sub3, $sub4)
}
Write-Host "CoWrap watcher started. Folder: $dl  (subs: $($global:CoWrapWatcher.Subs.Count))"
