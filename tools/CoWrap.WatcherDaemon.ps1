param([Parameter(Mandatory)][string]$Watch)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$ptrPath = Join-Path $Watch "CoWrap.latest.json"
$last = ""
while ($true) {
  try {
    $z = Get-ChildItem $Watch -Filter "CoWrap.zip" -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Desc | Select-Object -First 1
    if ($z -and $z.FullName -ne $last) {
      $stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
      $obj = [ordered]@{ latest=$z.FullName; ts=$stamp } | ConvertTo-Json
      $obj | Set-Content -Path $ptrPath
      $last = $z.FullName
    }
  } catch {}
  Start-Sleep -Seconds 2
}