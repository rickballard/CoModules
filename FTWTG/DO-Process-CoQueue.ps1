param([string]$Temps="$HOME\CoTemps")
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'

$queue = Join-Path $Temps 'queue'
if (!(Test-Path $queue)) { return }

# local fence (no ternary)
$fence    = Join-Path $Temps 'fence.id'
$localSid = $null
if (Test-Path $fence) { $localSid = Get-Content -Raw -LiteralPath $fence }

function Try-Claim([string]$path){
  $claim = "$path.$([guid]::NewGuid().Guid).lock"
  try { Move-Item -LiteralPath $path -Destination $claim -ErrorAction Stop; return $claim }
  catch { return $null }
}

# gather both patterns in PS5
$files = @()
$files += Get-ChildItem $queue -File -Filter 'context_*.json' -ErrorAction SilentlyContinue
$files += Get-ChildItem $queue -File -Filter 'omni_*.go'      -ErrorAction SilentlyContinue

$files | Sort-Object LastWriteTime | ForEach-Object {
  $claimed = Try-Claim $_.FullName
  if (-not $claimed) { return }

  try {
    if ($claimed -like '*.json.lock') {
      $payload = $null
      try { $payload = Get-Content -Raw -LiteralPath $claimed | ConvertFrom-Json } catch {}
      if ($payload -and $payload.sid -and $localSid -and $payload.sid -ne $localSid) {
        # not for this session → hand back
        Move-Item -LiteralPath $claimed -Destination ($claimed -replace '\.lock$','') -Force
        return
      }
      Write-Host ("[CTX] {0} / {1}" -f ($payload.title ?? ''), ($payload.proc ?? ''))
      # TODO: do context-specific work here
    } else {
      Write-Host "[OMNI] broadcast claimed"
      # TODO: do omni work here
    }
  }
  finally {
    if (Test-Path $claimed) { Remove-Item -LiteralPath $claimed -Force }
  }
}

