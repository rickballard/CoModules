param([Parameter(Mandatory=$true)][string]$Title,[string]$Browser="",[string]$Temps="$HOME\CoTemps")
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$mapPath = Join-Path $Temps "link.json"
if (!(Test-Path $Temps)) { New-Item -ItemType Directory -Force -Path $Temps | Out-Null }
if (Test-Path $mapPath){ $map=Get-Content $mapPath -Raw|ConvertFrom-Json } 
else { $map=[pscustomobject]@{ bindings=@(); panels=@("PanelA","PanelB","PanelC","PanelD"); ps=@{} } }
$used  = @($map.bindings | ForEach-Object { $_.panel })
$panel = ($map.panels | Where-Object { $_ -notin $used } | Select-Object -First 1)
if (-not $panel) { $panel = ($map.panels | Select-Object -First 1) }
$existing = $map.bindings | Where-Object { $_.title -eq $Title }
if ($existing){ $existing.panel=$panel; if($Browser){ $existing.browser=$Browser } }
else { $map.bindings = @($map.bindings + [pscustomobject]@{ title=$Title; browser=$Browser; panel=$panel }) }
($map|ConvertTo-Json -Depth 6)|Out-File -LiteralPath $mapPath -Encoding UTF8
Write-Host "[PAIR] Chat '$Title' -> $panel"

