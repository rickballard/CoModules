Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
function Get-CoDownloadsRoot {
  $dl=$env:COCACHE_DOWNLOADS; if(-not $dl -or -not (Test-Path $dl)){ $dl=Join-Path $HOME "Downloads\CoTemp" }
  if(-not (Test-Path $dl)){ $dl=Join-Path $HOME "Downloads" }
  return $dl
}
function Save-CoText {
  param([Parameter(Mandatory)][string]$RelativePath,[Parameter(Mandatory)][string[]]$Lines)
  $root=Get-CoDownloadsRoot; $path=Join-Path $root $RelativePath; $dir=Split-Path -Parent $path
  New-Item -Type Directory -Force -Path $dir | Out-Null
  $enc=New-Object System.Text.UTF8Encoding($false)
  $txt=[string]::Join([Environment]::NewLine,$Lines)
  $bytes=$enc.GetBytes($txt)
  [IO.File]::WriteAllBytes($path,$bytes)
  $actual=(Get-Item $path).Length; $expected=$bytes.Length
  if($actual -ne $expected){ throw ("Size mismatch writing {0} (expected {1}, got {2})" -f $path,$expected,$actual) }
  [pscustomobject]@{ Path=$path; Bytes=$actual; OK=($actual -eq $expected) }
}
function Save-CoBytes {
  param([Parameter(Mandatory)][string]$RelativePath,[Parameter(Mandatory)][byte[]]$Bytes)
  $root=Get-CoDownloadsRoot; $path=Join-Path $root $RelativePath; $dir=Split-Path -Parent $path
  New-Item -Type Directory -Force -Path $dir | Out-Null
  [IO.File]::WriteAllBytes($path,$Bytes)
  $actual=(Get-Item $path).Length; $expected=$Bytes.Length
  if($actual -ne $expected){ throw ("Size mismatch writing {0} (expected {1}, got {2})" -f $path,$expected,$actual) }
  [pscustomobject]@{ Path=$path; Bytes=$actual; OK=($actual -eq $expected) }
}
function Invoke-CoDownloadsSweep {
  param([int]$MaxAgeDays=30,[switch]$Purge)
  $root=Get-CoDownloadsRoot; $cut=(Get-Date).AddDays(-$MaxAgeDays)
  $cands=Get-ChildItem $root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cut }
  if(-not $cands){ Write-Host ("Sweep: nothing older than {0} days in {1}" -f $MaxAgeDays,$root); return }
  $cands | Select-Object LastWriteTime,Length,FullName | Format-Table -AutoSize
  if($Purge){ $cands | Remove-Item -Force -ErrorAction SilentlyContinue; Write-Host ("Sweep: purged {0} files." -f $cands.Count) }
  else { Write-Host ("Sweep: pass -Purge to delete ({0} files)." -f $cands.Count) }
}