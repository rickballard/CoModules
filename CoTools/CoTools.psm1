function Get-CoRepos { [CmdletBinding()]
  param([string]$Root = (Join-Path $HOME "Documents\GitHub"), [string]$Pattern='^(Co.*|GIBindex)$')
  Get-ChildItem -Directory -LiteralPath $Root |
    Where-Object Name -match $Pattern |
    ForEach-Object {
      $slug = $null
      try {
        $u = git -C $_.FullName config --get remote.origin.url 2>$null
        if ($u -match 'github\.com[:/](.+?)(?:\.git)?$'){ $slug = $matches[1] }
      } catch {}
      [pscustomobject]@{ Name=$_.Name; Path=$_.FullName; HasGit=Test-Path (Join-Path $_.FullName '.git'); Slug=$slug }
    }
}

function Ensure-RepoDocsScaffold { [CmdletBinding()] param([Parameter(Mandatory)][string]$RepoPath)
  foreach($rel in 'docs','docs/status','docs/plan','docs/vision','docs/mission','docs/index','docs/ideas','docs/todo'){
    [IO.Directory]::CreateDirectory((Join-Path $RepoPath $rel)) | Out-Null
  }
}

function Find-AdviceAndTodos { [CmdletBinding()] param([Parameter(Mandatory)][string]$RepoPath)
  $include = '*.md','*.txt','*.ps1','*.psm1','*.psd1','*.json','*.yml','*.yaml','*.ts','*.js'
  $files = Get-ChildItem -Recurse -File -Include $include -Path $RepoPath -ErrorAction SilentlyContinue |
           Where-Object { $_.FullName -notmatch '\\\.git\\' }
  $rx = '(?i)\b(TODO|FIXME|IDEA|NOTE|ADVICE|ADVICE[-_ ]BOMB|CARD|MASTER PLAN)\b'
  foreach($f in $files){
    Select-String -Path $f.FullName -Pattern $rx -AllMatches -Encoding UTF8 -ErrorAction SilentlyContinue |
      ForEach-Object { [pscustomobject]@{ File=$f.FullName; Line=$_.LineNumber; Text=$_.Line.Trim() } }
  }
}

function Write-AdviceIndexes { [CmdletBinding()] param([Parameter(Mandatory)][string]$RepoPath)
  $utf8 = [Text.UTF8Encoding]::new($false)
  $hits = Find-AdviceAndTodos -RepoPath $RepoPath
  $outDir = Join-Path $RepoPath 'docs\index'; [IO.Directory]::CreateDirectory($outDir)|Out-Null

  $grouped = $hits | Group-Object { Split-Path $_.File -Leaf }
  $adv = @('# Advice / TODO Index','','_Auto-generated; edit source files to change items._','')
  foreach($g in ($grouped | Sort-Object Name)){
    $adv += "## $($g.Name)"
    foreach($h in ($g.Group | Sort-Object File,Line)){
      $rel = $h.File.Replace($RepoPath,'').TrimStart('\')
      $adv += ("- {0} (L{1}) — {2}" -f $rel, $h.Line, $h.Text)
    }
    $adv += ''
  }
  [IO.File]::WriteAllText((Join-Path $outDir 'ADVICE-INDEX.md'), ($adv -join "`n") + "`n", $utf8)

  $todo = $hits | Where-Object { $_.Text -match '(?i)\b(TODO|FIXME)\b' }
  $todoLines = @('# TODO Summary','','_Filtered to TODO/FIXME only._','')
  foreach($t in ($todo | Sort-Object File,Line)){
    $rel = $t.File.Replace($RepoPath,'').TrimStart('\')
    $todoLines += ("- {0} (L{1}) — {2}" -f $rel, $t.Line, $t.Text)
  }
  [IO.File]::WriteAllText((Join-Path $outDir 'TODO-INDEX.md'), ($todoLines -join "`n") + "`n", $utf8)

  [pscustomobject]@{ Count = @($hits).Count; Todo = @($todo).Count }
}

function Write-RepoHealth { [CmdletBinding()]
  param([Parameter(Mandatory)][string]$RepoPath,[string]$Slug)
  $utf8 = [Text.UTF8Encoding]::new($false); Ensure-RepoDocsScaffold -RepoPath $RepoPath

  $gm=0;$gmList=@()
  if($Slug){ try {
    $prJson = gh -R $Slug pr list --state open --json headRefName,number,createdAt,url 2>$null
    if($prJson){ $prs=$prJson|ConvertFrom-Json; $gmList = $prs | Where-Object { $_.headRefName -like 'gm/*' }; $gm=@($gmList).Count }
  } catch {} }

  $issues=@()
  if($Slug){ try {
    $isJson = gh -R $Slug issue list --state open --json number,title,labels,createdAt,url 2>$null
    if($isJson){ $issues=$isJson|ConvertFrom-Json }
  } catch {} }

  $branches=@()
  try {
    $fmt='%(refname:short)|%(committerdate:iso8601)'
    $branches = git -C $RepoPath for-each-ref --format=$fmt refs/heads 2>$null |
      ForEach-Object { $p=$_ -split '\|',2; [pscustomobject]@{Name=$p[0];Date=[datetime]$p[1]} } |
      Sort-Object Date -Descending
  } catch {}

  $harv = Write-AdviceIndexes -RepoPath $RepoPath
  $emd = [char]0x2014
  $lines = @('# Repo Health','',
    ("- Updated {0} {1} _via Write-RepoHealth_" -f ((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss\Z')),$emd),
    ("- GM PR bloat: {0} open gm/* PR(s)" -f $gm),
    ("- Open issues: {0}" -f (@($issues).Count)),
    ("- Advice/TODO hits: {0} (TODO: {1})" -f $harv.Count, $harv.Todo),'')
  if($gm -gt 0){
    $lines += '## gm/* PRs'
    $lines += ($gmList | Sort-Object createdAt | ForEach-Object {
      $opened = [datetime]::Parse($_.createdAt,$null,[Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()
      "- [$($_.number)]($($_.url)) $($_.headRefName) ($opened)"
    })
    $lines += ''
  }
  if(@($issues).Count -gt 0){
    $lines += '## Open Issues'
    $lines += ($issues | Sort-Object createdAt | ForEach-Object {
      $lbls = ($_.labels | ForEach-Object name) -join ', '
      "- [$($_.number)]($($_.url)) $($_.title) [$lbls]"
    })
    $lines += ''
  }
  if(@($branches).Count -gt 0){
    $lines += '## Branches (local, newest first)'
    $lines += ($branches | ForEach-Object { "- $($_.Name) ($($_.Date.ToUniversalTime().ToString('u')))" })
    $lines += ''
  }
  $out = Join-Path $RepoPath 'docs\status\HEALTH.md'
  [IO.File]::WriteAllText($out, ($lines -join "`n") + "`n", $utf8)
}

function Update-RepoHealthAll { [CmdletBinding()]
  param([string]$Root=(Join-Path $HOME "Documents\GitHub"), [string]$Pattern='^(Co.*|GIBindex)$')
  $repos = Get-CoRepos -Root $Root -Pattern $Pattern
  foreach($r in $repos){
    if(-not $r.HasGit){ continue }
    Write-RepoHealth -RepoPath $r.Path -Slug $r.Slug
    Push-Location $r.Path
    try{
      $paths = @('docs/status/HEALTH.md','docs/index/ADVICE-INDEX.md','docs/index/TODO-INDEX.md')
if (git status --porcelain -- @paths) {
        git add -- @paths
        git commit -m "docs(health): refresh Health + Advice/TODO indices" 2>$null | Out-Null
        git push -q 2>$null | Out-Null
      }
    } finally { Pop-Location }
  }
}

function New-CCScroll { [CmdletBinding()]
  param([string]$Root=(Join-Path $HOME "Documents\GitHub"), [string]$TargetRepo='CoCache')
  $target = Get-CoRepos -Root $Root | Where-Object Name -eq $TargetRepo
  if(-not $target){ throw "Target repo '$TargetRepo' not found under $Root" }
  $emd=[char]0x2014; $utf8=[Text.UTF8Encoding]::new($false)
  $lines = @('# CC Scroll','','_Single scroll of the constellation; follow links for deep dives._','')
  $repos = Get-CoRepos -Root $Root
  foreach($r in ($repos | Sort-Object Name)){
    $base=$r.Path
    $path=@{
      BPOE=Join-Path $base 'docs\status\BPOE.md'
      HLTH=Join-Path $base 'docs\status\HEALTH.md'
      PLAN=Join-Path $base 'docs\plan\MasterPlan.md'
      IDX =Join-Path $base 'docs\index\README.md'
      TODO=Join-Path $base 'docs\index\TODO-INDEX.md'
      ADV =Join-Path $base 'docs\index\ADVICE-INDEX.md'
    }
    $links = foreach($k in $path.Keys){ if(Test-Path $path[$k]){ $rel=$path[$k].Replace($target.Path,'').TrimStart('\'); "[{0}]({1})" -f $k,$rel.Replace('\','/') } }
    $label = if($r.Name -eq 'CoCivium'){'CoCivium'} else {$r.Name}
    $lines += ("- **{0}** {1} {2}" -f $label,$emd, ($links -join ' | '))
  }
  $outDir = Join-Path $target.Path 'docs\scrolls'; [IO.Directory]::CreateDirectory($outDir)|Out-Null
  [IO.File]::WriteAllText((Join-Path $outDir 'CC-SCROLL.md'), ($lines -join "`n") + "`n", $utf8)
  Push-Location $target.Path; try{ git add 'docs/scrolls/CC-SCROLL.md'; git commit -m "docs(scroll): update CC Scroll links" 2>$null | Out-Null; git push -q 2>$null | Out-Null } finally { Pop-Location }
}

function Fix-CoCiviumNames { [CmdletBinding(SupportsShouldProcess)]
  param([string]$Root=(Join-Path $HOME "Documents\GitHub"), [switch]$Commit)
  $repos = Get-CoRepos -Root $Root
  $targets = $repos | Where-Object { $_.Name -notmatch '^CoCivium' }
  $include = '*.md','*.txt','*.ps1','*.psm1','*.psd1','*.json','*.yml','*.yaml','*.ts','*.js','*.cs'
  foreach($r in $targets){
    $files = Get-ChildItem -Recurse -File -Include $include -Path $r.Path -ErrorAction SilentlyContinue |
             Where-Object { $_.FullName -notmatch '\\\.git\\' }
    $changed=@()
    foreach($f in $files){
      $text = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
      if($text -match '\bCivium\b' -and $PSCmdlet.ShouldProcess($f.FullName, "Replace 'CoCivium' -> 'CoCivium'")){
        $fixed = [regex]::Replace($text, '\bCivium\b', 'CoCivium')
        if($fixed -ne $text){ [IO.File]::WriteAllText($f.FullName,$fixed,[Text.UTF8Encoding]::new($false)); $changed += $f.FullName }
      }
    }
    if($Commit -and $changed.Count -gt 0 -and $r.HasGit){
      Push-Location $r.Path; try{ git add -- $changed; git commit -m "docs: normalize 'CoCivium' references to 'CoCivium'" *> $null; git push -q 2>$null | Out-Null } finally { Pop-Location }
    }
  }
}

Export-ModuleMember -Function Get-CoRepos,Ensure-RepoDocsScaffold,Find-AdviceAndTodos,Write-AdviceIndexes,Write-RepoHealth,Update-RepoHealthAll,New-CCScroll,Fix-CoCiviumNames




