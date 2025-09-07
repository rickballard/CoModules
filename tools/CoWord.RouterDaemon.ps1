param([Parameter(Mandatory)][string]$Watch,[Parameter(Mandatory)][string]$MapPath)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$ptr = Join-Path $Watch "CoPing.latest.json"
$last = ""
$repo = (Split-Path -Parent $PSScriptRoot)
$coDo = Join-Path $repo "tools\\CoDO.ps1"
while($true){
  try {
    if(Test-Path $ptr){
      $meta = Get-Content $ptr -Raw | ConvertFrom-Json -ErrorAction Stop
      $latest = $meta.latest
      if($latest -and (Test-Path $latest) -and $latest -ne $last){
        $p = Get-Content $latest -Raw | ConvertFrom-Json -ErrorAction Stop
        if(($p.to -eq "COAGENT") -and $p.msg){
          $msg = ($p.msg).ToLower().Trim()
          $map = Get-Content $MapPath -Raw | ConvertFrom-Json -ErrorAction Stop
          $hit = $map.$msg
          if($hit -ne $null){
            $name = $hit.task
            $args = @()
            if($hit.args){ $args += $hit.args }
            # Allow data.args to append/override
            if($p.data -and $p.data.args){ $args += $p.data.args }
            # Run DO task via CoDO (named-arg passthrough)
            & $coDo -Name $name -Args $args
          }
        }
        $last = $latest
      }
    }
  } catch {}
  Start-Sleep -Milliseconds 800
}