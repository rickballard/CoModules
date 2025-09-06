Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop"
if ($global:CoWrapWatcher) {
  "Running. Downloads: {0}  Started(UTC): {1}  Subs: {2}" -f `
    $global:CoWrapWatcher.Downloads, $global:CoWrapWatcher.StartedUtc, $global:CoWrapWatcher.Subs.Count | Write-Host
} else {
  "Not running." | Write-Host
}
Get-EventSubscriber | Where-Object { $_.SourceIdentifier -like 'cowrap-*' } |
  Select-Object SourceIdentifier, EventName, SubscriptionId | Format-Table -AutoSize
