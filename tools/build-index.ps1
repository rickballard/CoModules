param()
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root  = (Get-Location).Path
$rootN = $root -replace '\\','/'

$idxDirRel = 'docs/index'
$idxDir    = Join-Path $root $idxDirRel
$idxN      = $idxDir -replace '\\','/'

# Gather markdown, excluding .git and docs/index/*
$mds = Get-ChildItem -Recurse -File -Include *.md | Where-Object {
  $p = $_.FullName -replace '\\','/'
  ($p -notmatch '/\.git/') -and (-not $p.StartsWith($idxN))
}

$forward=@{}; $back=@{}
foreach($f in $mds){
  $pN  = $f.FullName -replace '\\','/'
  $rel = $pN.Substring($rootN.Length).TrimStart('/')

  $matches = Select-String -Path $f.FullName -Pattern '\[[^\]]+\]\((?!https?://)([^)#]+)' -AllMatches
  $links   = foreach($m in $matches){ foreach($g in $m.Matches){ $g.Groups[1].Value } }

  $norm = @()
  foreach($l in $links){
    $abs  = [IO.Path]::GetFullPath((Join-Path $f.DirectoryName $l))
    $absN = $abs -replace '\\','/'
    if ($absN.StartsWith($rootN)) {
      $rel2 = $absN.Substring($rootN.Length).TrimStart('/')
      $norm += $rel2
    }
  }
  $norm = @(@($norm) | Sort-Object -Unique)
  $forward[$rel] = $norm
  foreach($n in $norm){
    if (-not $back.ContainsKey($n)) { $back[$n] = @() }
    $back[$n] += $rel
  }
}

# Deterministic tag: commit date + short sha (fallback to ISO time if git missing)
$gitDate = (git log -1 --format=%cI) 2>$null
$gitSha  = (git rev-parse --short HEAD) 2>$null
if (-not $gitDate) { $gitDate = (Get-Date).ToString('s') }
$generated = if ($gitSha) { "$gitDate ($gitSha)" } else { $gitDate }

New-Item -ItemType Directory -Force -Path $idxDir | Out-Null
$index = [ordered]@{ generated=$generated; forward=$forward; backlinks=@{} }
foreach($k in $back.Keys){ $index.backlinks[$k] = @(@($back[$k]) | Sort-Object -Unique) }
($index | ConvertTo-Json -Depth 10) | Set-Content -Encoding UTF8 (Join-Path $idxDir 'index.json')

# Links in README should be relative to docs/index
Add-Type -AssemblyName System.Runtime.Extensions
function RelFromIndex([string]$targetRel){
  [IO.Path]::GetRelativePath($idxDir, (Join-Path $root $targetRel)) -replace '\\','/'
}

$md = "# Repository Index`n`nGenerated: $generated`n`n"
foreach($k in ($forward.Keys | Sort-Object)){
  $md += "* [$k]($(RelFromIndex $k))"
  $outs = @(@($forward[$k]) | Where-Object { $_ })
  if ($outs.Count -gt 0) {
    $md += " → " + (( $outs | ForEach-Object { RelFromIndex $_ } ) -join ", ")
  }
  $md += "`n"
}
Set-Content -Encoding UTF8 (Join-Path $idxDir 'README.md') -Value $md
