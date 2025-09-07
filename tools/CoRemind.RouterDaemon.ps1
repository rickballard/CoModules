param([Parameter(Mandatory)][string]$Watch,[Parameter(Mandatory)][string]$ConfigPath)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$run = Join-Path $HOME "Downloads\\CoCacheLocal\\run"
New-Item -Type Directory -Force -Path $run | Out-Null
$statePath = Join-Path $run "CoRemind.state.json"
function Load-State { if (Test-Path $statePath) { Get-Content $statePath -Raw | ConvertFrom-Json } else { @{} } }
function Save-State($obj) { ($obj | ConvertTo-Json -Depth 6) | Set-Content -Path $statePath }
function Next-Due($min,$max){ $d = Get-Random -Minimum $min -Maximum ($max+1); (Get-Date).AddDays($d) }
function Get-DL { $d=$env:COCACHE_DOWNLOADS; if(-not $d -or -not (Test-Path $d)){ $d=Join-Path $HOME "Downloads\\CoTemp" }; if(-not (Test-Path $d)){ $d=Join-Path $HOME "Downloads" }; $d }
function Check-CoTemp($maxAgeDays){
  $dl = Get-DL
  $cut=(Get-Date).AddDays(-$maxAgeDays)
  $files = Get-ChildItem $dl -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cut }
  $count = ($files | Measure-Object).Count
  $bytes = ($files | Measure-Object -Property Length -Sum).Sum
  $mb = [math]::Round(($bytes/1MB),2)
  [pscustomobject]@{ Count=$count; TotalMB=$mb; DL=$dl }
}
$state = Load-State
while($true){
  try {
    $cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop
    foreach($k in $cfg.PSObject.Properties.Name){
      $r = $cfg.$k; if(-not $r.enabled){ continue }
      $now = Get-Date
      $entry = $state.$k
      if(-not $entry){ $entry = [ordered]@{ nextDue = $now.AddSeconds(-1); lastResult = $null }; $state.$k = $entry }
      $due = Get-Date $entry.nextDue
      if($now -ge $due){
        if($r.type -eq "cotemp"){
          $res = Check-CoTemp -maxAgeDays $r.maxAgeDays
          $entry.lastResult = $res
          if(($res.Count -gt 0) -and ($res.TotalMB -ge $r.minTotalMBForNotify)){
            # Exception-only notify via CoPing -> CoAgent CoWord
            $coPing = Join-Path (Split-Path $PSScriptRoot -Parent) "CoPing.ps1"
            $data = @{ kind="cotemp"; count=$res.Count; totalMB=$res.TotalMB; dl=$res.DL }
            & $coPing -To "COAGENT" -Msg "reminder cotemp" -Data $data
          }
        }
        $entry.nextDue = Next-Due $r.intervalDaysMin $r.intervalDaysMax
        Save-State $state
      }
    }
  } catch {}
  Start-Sleep -Seconds 120
}