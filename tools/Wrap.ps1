param([string]$Agent = "U",[string]$ToSession = "ANY")
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$CCL = $env:COCACHE_LOCAL ?? (Join-Path $HOME "Downloads/CoCacheLocal")
$dl  = $env:COCACHE_DOWNLOADS ?? (Join-Path $HOME "Downloads")
$root= Join-Path $CCL "sessions"; $wraps= Join-Path $CCL "wraps"; $archive = Join-Path $CCL "archive"
$base= Join-Path $root $env:COSESSION_ID; $log = Join-Path $base "log.ndjson"
New-Item -Type Directory -Force -Path $base,$wraps,$archive | Out-Null

$ts    = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$stage = Join-Path $wraps ("wrap-$ts-$($env:COSESSION_ID)"); New-Item -Type Directory -Force -Path $stage | Out-Null
$handover = @{
  session_id=$env:COSESSION_ID; ts=(Get-Date).ToUniversalTime().ToString('o')
  repo=(Get-Location).Path; branch=(git rev-parse --abbrev-ref HEAD 2>$null)
  status=(git status --porcelain=v1 -b 2>$null) -split "`n"
  last500=(Test-Path $log)?(Get-Content $log -Tail 500):@()
  note="CoWrap package"; agent=$Agent; to_session=$ToSession
}
$hand = Join-Path $stage 'handover.json'; $handover | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8NoBOM $hand
if (Test-Path $log) { Copy-Item $log (Join-Path $stage 'log.ndjson') -Force }
(Get-Content $log -Tail 200 -ErrorAction SilentlyContinue) | Set-Content -Encoding UTF8NoBOM (Join-Path $stage 'last200.ndjson')
(git rev-parse --show-toplevel 2>$null)                      | Set-Content -Encoding UTF8NoBOM (Join-Path $stage 'repo-root.txt')
(git status -sb 2>$null)                                     | Set-Content -Encoding UTF8NoBOM (Join-Path $stage 'git-status.txt')
(git diff --no-color 2>$null)                                | Set-Content -Encoding UTF8NoBOM (Join-Path $stage 'repo.diff')
(git diff --cached --no-color 2>$null)                       | Set-Content -Encoding UTF8NoBOM (Join-Path $stage 'repo.diff.staged')
(git ls-files -m -o --exclude-standard 2>$null)              | Set-Content -Encoding UTF8NoBOM (Join-Path $stage 'changed-files.txt')
[ordered]@{created_utc=(Get-Date).ToUniversalTime().ToString('o');from_session=$env:COSESSION_ID;to_session=$ToSession;agent=$Agent;repo=(Get-Location).Path;branch=(git rev-parse --abbrev-ref HEAD 2>$null)} |
  ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8NoBOM (Join-Path $stage 'manifest.json')

$zipName = "CoWrap-$ts-$($env:COSESSION_ID)-to-$ToSession.zip"
$zipPath = Join-Path $dl $zipName
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zipPath -Force

# Breadcrumbs (atomic latest)
$crumb = [ordered]@{ kind='CoWrap'; created_utc=(Get-Date).ToUniversalTime().ToString('o'); from_session=$env:COSESSION_ID; to_session=$ToSession; zip_path=$zipPath }
$crumbPath = Join-Path $dl ("CoWrap.Breadcrumb-$($env:COSESSION_ID).json"); $crumb | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8NoBOM $crumbPath
$latest    = Join-Path $dl "CoWrap.latest.json"
$latestTmp = $latest + ".tmp"
$crumb | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8NoBOM $latestTmp
Move-Item -Force $latestTmp $latest

$emit = Join-Path $CCL 'bin\Emit.ps1'; if (Test-Path $emit) { & $emit -Agent $Agent -Type 'wrap' -Msg "zip ready" -Data @{ zip=$zipPath; to=$ToSession } | Out-Null }
Write-Host "CoWrap ready: $zipPath"


