param()
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Get-Location).Path
$mds = Get-ChildItem -Recurse -File -Include *.md | Where-Object { $_.FullName -notmatch '\\.git\\' }
$forward=@{}; $back=@{}
foreach($f in $mds){
  $rel = $f.FullName.Substring($root.Length).TrimStart('\','/') -replace '\\','/'
  $mres = Select-String -Path $f.FullName -Pattern '\[[^\]]+\]\((?!https?://)([^)#]+)' -AllMatches
  $links = foreach($mm in $mres){ foreach($g in $mm.Matches){ $g.Groups[1].Value } }
  $norm = @()
  foreach($l in $links){
    $abs  = [IO.Path]::GetFullPath((Join-Path $f.DirectoryName $l))
    $rel2 = $abs.Substring($root.Length).TrimStart('\','/') -replace '\\','/'
    $norm += $rel2
  }
  $norm = @(@($norm) | Sort-Object -Unique)
  $forward[$rel]=$norm
  foreach($n in $norm){
    if (-not $back.ContainsKey($n)) { $back[$n]=@() }
    $back[$n]+=$rel
  }
}
$idxDir='docs/index'
New-Item -ItemType Directory -Force -Path $idxDir | Out-Null
$index = [ordered]@{ generated=(Get-Date).ToString('s'); forward=$forward; backlinks=@{} }
foreach($k in $back.Keys){ $index.backlinks[$k] = @(@($back[$k]) | Sort-Object -Unique) }
($index | ConvertTo-Json -Depth 10) | Set-Content -Encoding UTF8 (Join-Path $idxDir 'index.json')

$md = "# Repository Index`n`nGenerated: $($index.generated)`n`n"
foreach($k in ($forward.Keys | Sort-Object)){
  $md += "* [$k]($k)"
  $outsList = @(@($forward[$k]) | Where-Object { $_ })
  if ($outsList.Count -gt 0) { $md += " → " + ($outsList -join ", ") }
  $md += "`n"
}
Set-Content -Encoding UTF8 (Join-Path $idxDir 'README.md') -Value $md
