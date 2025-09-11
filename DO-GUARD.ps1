param([string]$Repo = $(Split-Path -Parent $PSCommandPath))
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
$Repo = (Resolve-Path $Repo).Path

$violations = New-Object System.Collections.ArrayList
function Add-Violation { param($file,$rule,$detail)
  $null = $violations.Add([pscustomobject]@{file=$file; rule=$rule; detail=$detail})
}

# 1) CI ban during DO-only phase
$wfDir = Join-Path $Repo '.github\workflows'
if (Test-Path $wfDir) {
  Get-ChildItem $wfDir -Recurse -File -Include *.yml,*.yaml | ForEach-Object {
    Add-Violation $_.FullName 'CI not allowed' 'Quarantine as .github/workflows.disabled/ while in DO-only phase'
  }
}

# 2) Script scan (read-only)
$risky = @(
  'Register-ScheduledTask','schtasks','New-Service','Set-Service','Start-Service','sc\.exe',
  'Start-Process\s+-Verb\s+runAs','Enable-PSRemoting','Set-ItemProperty\s+HKLM','reg\.exe',
  'Invoke-WebRequest\s+-Method\s+POST','curl\s+-X\s+POST',
  '\b(New-Item|Copy-Item|Remove-Item|Set-Content)\b'
) -join '|'

$ps = Get-ChildItem $Repo -Recurse -File -Include *.ps1 -ErrorAction SilentlyContinue
foreach ($f in $ps) {
  $text = Get-Content -LiteralPath $f.FullName -Raw
  # Treat DO-* and files explicitly marked as read-only as compliant
  $isDO = ($f.BaseName -match '^(DO($|-)|DO-VERIFY|DO-TEST|DO-SIM)') -or ($text -match '(?i)policy:\s*read-only')
  if ($text -match $risky -and -not $isDO) {
    Add-Violation $f.FullName 'Risky op in non-DO script' 'Move into a DO-* script or mark with: policy: read-only'
  }
  if ($text -notmatch 'Set-StrictMode\s*-Version\s+Latest') {
    Add-Violation $f.FullName 'No StrictMode' 'Add: Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"'
  }
}

# 3) Report + exit code
if ($violations.Count -eq 0) { Write-Host "[OK] DO-GUARD: no violations."; exit 0 }
Write-Host "[VIOLATIONS] DO-GUARD found $($violations.Count) issue(s):"
$violations | ForEach-Object { Write-Host (" - {0}: {1} — {2}" -f $_.rule,$_.file,$_.detail) }
exit 1
