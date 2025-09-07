[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string]$Path,
  [Parameter(Mandatory, ValueFromPipeline)] [string[]]$Lines
)
begin { $buf = @() }
process { $buf += $Lines }
end {
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
  Set-Content -Path $Path -Value $buf -Encoding utf8
}
