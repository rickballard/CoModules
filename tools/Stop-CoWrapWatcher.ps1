Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop"
if ($global:CoWrapWatcher) {
  foreach($s in $global:CoWrapWatcher.Subs){ Unregister-Event -SubscriptionId $s.Id -ErrorAction SilentlyContinue }
  foreach($w in $global:CoWrapWatcher.Watchers){ $w.EnableRaisingEvents = $false; $w.Dispose() }
  Remove-Variable -Name CoWrapWatcher -Scope Global -ErrorAction SilentlyContinue
}
# Sweep any stragglers
Get-EventSubscriber | Where-Object { $_.SourceIdentifier -like 'cowrap-*' } |
  Unregister-Event -Force -ErrorAction SilentlyContinue
Write-Host "CoWrap watcher stopped."
