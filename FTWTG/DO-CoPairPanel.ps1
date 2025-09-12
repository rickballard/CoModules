param([Parameter(Mandatory=$true)][ValidateSet("PanelA","PanelB","PanelC","PanelD")][string]$Panel,[string]$Temps="$HOME\CoTemps")
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$mapPath = Join-Path $Temps "link.json"
if (!(Test-Path $Temps)) { New-Item -ItemType Directory -Force -Path $Temps | Out-Null }
if (Test-Path $mapPath){ $map=Get-Content $mapPath -Raw|ConvertFrom-Json } 
else { $map=[pscustomobject]@{ bindings=@(); panels=@("PanelA","PanelB","PanelC","PanelD"); ps=@{} } }
if (-not $map.PSObject.Properties.Name -contains "ps"){ $map | Add-Member -NotePropertyName ps -NotePropertyValue (@{}) }
$pid=$PID; $hwnd=0; try{$hwnd=(Get-Process -Id $pid).MainWindowHandle}catch{}
$map.ps | Add-Member -Force -NotePropertyName $Panel -NotePropertyValue ([pscustomobject]@{ pid=$pid; hwnd=$hwnd; when=(Get-Date).ToString("o") })
($map|ConvertTo-Json -Depth 6)|Out-File -LiteralPath $mapPath -Encoding UTF8
$host.UI.RawUI.WindowTitle = "$Panel — PS7"
Write-Host "[PAIR] Registered this PS window as $Panel"

