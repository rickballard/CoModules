Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
function DL { $d=$env:COCACHE_DOWNLOADS; if(-not $d -or -not (Test-Path $d)){ $d=Join-Path $HOME "Downloads\CoTemp" }; if(-not (Test-Path $d)){ $d=Join-Path $HOME "Downloads" }; $d }
$dl = DL
$wrap = Join-Path $dl 'CoWrap.latest.json'
$ping = Join-Path $dl 'CoPing.latest.json'
$act  = Join-Path $dl 'CoAction.latest.json'
$w = if(Test-Path $wrap){ (Get-Content $wrap -Raw | ConvertFrom-Json).latest ?? (Split-Path $wrap -Leaf) } else { '-' }
$p = if(Test-Path $ping){ (Get-Content $ping -Raw | ConvertFrom-Json).latest ?? (Split-Path $ping -Leaf) } else { '-' }
$a = if(Test-Path $act ){ (Get-Content $act  -Raw | ConvertFrom-Json).name   ?? '-' } else { '-' }
"{0} | ping:{1} | action:{2}" -f $w,$p,$a | Write-Host
$env:CoDO_FOOTER_DONE="1"