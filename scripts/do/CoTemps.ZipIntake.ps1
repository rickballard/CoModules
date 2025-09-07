param(
  [string]$Inbox = "$HOME/Downloads/CoTemps/Inbox",
  [string]$Processed = "$HOME/Downloads/CoTemps/Processed"
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$Inbox = [IO.Path]::GetFullPath((Resolve-Path $Inbox))
$Processed = [IO.Path]::GetFullPath((Resolve-Path $Processed))
New-Item -ItemType Directory -Force -Path $Inbox,$Processed | Out-Null
Get-ChildItem $Inbox -File -Filter .zip | ForEach-Object {
  $zip = $_.FullName
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $out = Join-Path $Processed ("zip-{0}-{1}" -f [IO.Path]::GetFileNameWithoutExtension($zip), $stamp)
  New-Item -ItemType Directory -Force -Path $out | Out-Null
  Expand-Archive -LiteralPath $zip -DestinationPath $out -Force
  Get-ChildItem $out -Recurse -File -Filter .json | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $Inbox (Split-Path $_.FullName -Leaf)) -Force
  }
  Move-Item -Force $zip (Join-Path $Processed (Split-Path $zip -Leaf))
  Write-Host "Unpacked: $zip -> $out"
}
