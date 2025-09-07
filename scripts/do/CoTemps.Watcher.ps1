# CoTemps watcher: when .json lands in Inbox, run ingest.
function Start-CoTempsWatcher {
  param([string]$Inbox = "$HOME\Downloads\CoTemps\Inbox")
  $Inbox = [IO.Path]::GetFullPath((Resolve-Path $Inbox))
  if (Get-Variable -Name CoTempsWatcher -Scope Script -ErrorAction SilentlyContinue) {
    Write-Host "CoTemps watcher already running on $Inbox"; return
  }
  $fsw = New-Object System.IO.FileSystemWatcher
  $fsw.Path = $Inbox
  $fsw.Filter = ".json"
  $fsw.IncludeSubdirectories = $false
  $fsw.EnableRaisingEvents = $true

  $action = {
    Start-Sleep -Milliseconds 250
    try {
      & (Join-Path $using:repo 'scripts\do\Ingest-CoTemps.ps1') | Out-Null
    } catch {}
  }
  $created = Register-ObjectEvent -InputObject $fsw -EventName Created -Action $action
  $changed = Register-ObjectEvent -InputObject $fsw -EventName Changed -Action $action

  Set-Variable -Name CoTempsWatcher -Scope Script -Value @{fsw=$fsw; created=$created; changed=$changed}
  Write-Host "CoTemps watcher running on $Inbox"
}

function Stop-CoTempsWatcher {
  if (Get-Variable -Name CoTempsWatcher -Scope Script -ErrorAction SilentlyContinue) {
    $w = $Script:CoTempsWatcher
    if ($w.created) { Unregister-Event -SubscriptionId $w.created.Id }
    if ($w.changed) { Unregister-Event -SubscriptionId $w.changed.Id }
    $w.fsw.EnableRaisingEvents = $false
    $w.fsw.Dispose()
    Remove-Variable -Name CoTempsWatcher -Scope Script -ErrorAction SilentlyContinue
    Write-Host "CoTemps watcher stopped."
  } else {
    Write-Host "No CoTemps watcher running."
  }
}


