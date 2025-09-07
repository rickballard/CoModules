Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$script:__COWatch=$null; $script:__COWatch2=$null
function Enable-CoWatchDownloads {
  [CmdletBinding()] param([string]$Dir)
  if(-not $Dir){ $Dir = Join-Path $HOME 'Downloads' }
  if(Get-Variable -Name __COWatch -Scope Script -EA SilentlyContinue){ return }
  [IO.Directory]::CreateDirectory((Join-Path $HOME 'Downloads\CoTemp')) | Out-Null
  $script:__COWatch  = New-Object System.IO.FileSystemWatcher $Dir, '.json';  $script:__COWatch.IncludeSubdirectories=$false;  $script:__COWatch.EnableRaisingEvents=$true
  $script:__COWatch2 = New-Object System.IO.FileSystemWatcher $Dir, 'CoWrap-.zip'; $script:__COWatch2.IncludeSubdirectories=$false; $script:__COWatch2.EnableRaisingEvents=$true
  $act = {
    param($s,$e)
    try{
      $dl = Join-Path $HOME 'Downloads\CoTemp'; $ts=Get-Date -Format 'yyyyMMdd_HHmmss'
      $name = [IO.Path]::GetFileName($e.FullPath)
      if($name -notmatch '^(CoWrap|CoStatus|CoClaim|CoPing)' -and $name -notmatch '^CoWrap-.\.zip$'){ return }
      $rec = Join-Path $dl ("CoWatch_{0}_{1}.txt" -f $ts,$name)
      $line = ("{0} {1} {2}" -f $e.ChangeType,$name,$e.FullPath)
      [IO.File]::WriteAllText($rec,$line,[Text.UTF8Encoding]::new($true))
      $ptr = Join-Path $dl 'CoWatch.latest.json'
      $obj=[ordered]@{ when=(Get-Date).ToString('o'); change="$($e.ChangeType)"; name=$name; path=$e.FullPath }
      ($obj|ConvertTo-Json) | Out-File -LiteralPath ($rec -replace '\.txt$','.json') -Encoding utf8
      Copy-Item -LiteralPath ($rec -replace '\.txt$','.json') -Destination $ptr -Force
      if($name -eq 'CoWrap.latest.json'){
        try { $j = Get-Content -Raw -EA SilentlyContinue -LiteralPath $e.FullPath | ConvertFrom-Json } catch { $j=$null }
        if($j){
          $to = (""+ $j.to)
          if($env:COAGENT_AUTOUNWRAP -match '^(1|true|yes|on)$' -and ($to -eq $env:COSESSION_ID -or $to -eq 'ANY')){
            $unwrap = Join-Path $HOME 'Documents\GitHub\CoModules\tools\CoWrap\CoUnWrap.ps1'
            if(Test-Path $unwrap){ Start-Job -Name "cowatch-counwrap" -ScriptBlock { & $using:unwrap -Quiet } | Out-Null }
          }
        }
      }
    }catch{}
  }
  Register-ObjectEvent -InputObject $script:__COWatch  -EventName Created -SourceIdentifier COWatch.JSONCreated  -Action $act | Out-Null
  Register-ObjectEvent -InputObject $script:__COWatch  -EventName Changed -SourceIdentifier COWatch.JSONChanged  -Action $act | Out-Null
  Register-ObjectEvent -InputObject $script:__COWatch2 -EventName Created -SourceIdentifier COWatch.ZIPCreated   -Action $act | Out-Null
  Register-ObjectEvent -InputObject $script:__COWatch2 -EventName Changed -SourceIdentifier COWatch.ZIPChanged   -Action $act | Out-Null
}
function Disable-CoWatchDownloads {
  foreach($id in 'COWatch.JSONCreated','COWatch.JSONChanged','COWatch.ZIPCreated','COWatch.ZIPChanged'){ Unregister-Event -SourceIdentifier $id -EA SilentlyContinue }
  foreach($v in '__COWatch','__COWatch2'){ if(Get-Variable -Name $v -Scope Script -EA SilentlyContinue){ (Get-Variable -Name $v -Scope Script).Value.EnableRaisingEvents=$false; (Get-Variable -Name $v -Scope Script).Value.Dispose(); Remove-Variable -Name $v -Scope Script -EA SilentlyContinue } }
}
Export-ModuleMember -Function Enable-CoWatchDownloads,Disable-CoWatchDownloads