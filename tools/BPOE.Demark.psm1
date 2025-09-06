# BPOE demark + state capsule (local-only) with color/gradient support

function Test-BPOEVT {
  try {
    if ($PSStyle -and $PSStyle.OutputRendering -ne 'PlainText') { return $true }
  } catch {}
  # Windows Terminal sets WT_SESSION; VSCode passes ANSI too
  if ($env:WT_SESSION) { return $true }
  return $false
}

function New-BPOEAnsiFg([int]$R,[int]$G,[int]$B) {
  [char]27 + "[38;2;$R;$G;${B}m"
}
$script:_BPOEAnsiReset = [char]27 + "[0m"

function Convert-BPOEHslToRgb([double]$H,[double]$S,[double]$L) {
  # H:[0..1], S:[0..1], L:[0..1]; returns PSCustomObject{R,G,B} ints 0..255
  if ($S -eq 0) { $v=[int]([math]::Round($L*255)); return [pscustomobject]@{R=$v;G=$v;B=$v} }
  $q = if ($L -lt 0.5) { $L * (1 + $S) } else { $L + $S - ($L * $S) }
  $p = 2*$L - $q
  function _h2rgb([double]$p,[double]$q,[double]$t){
    if ($t -lt 0) { $t += 1 }
    if ($t -gt 1) { $t -= 1 }
    if (6*$t -lt 1) { return $p + ($q - $p) * 6 * $t }
    if (2*$t -lt 1) { return $q }
    if (3*$t -lt 2) { return $p + ($q - $p) * (2/3 - $t) * 6 }
    return $p
  }
  $r = _h2rgb $p $q ($H + 1/3)
  $g = _h2rgb $p $q ($H)
  $b = _h2rgb $p $q ($H - 1/3)
  [pscustomobject]@{
    R = [int]([math]::Round($r*255))
    G = [int]([math]::Round($g*255))
    B = [int]([math]::Round($b*255))
  }
}

function Write-BPOELine {
  [CmdletBinding()]
  param(
    [char]$Char = '═',
    [ValidateSet('None','Rainbow','Sunset','Ocean','Forest','Candy')]
    [string]$Gradient = 'None',
    [ConsoleColor]$Color = [ConsoleColor]::Gray
  )
  try { $w = $Host.UI.RawUI.WindowSize.Width } catch { $w = 80 }
  if (-not $w -or $w -lt 20) { $w = 80 }

  if (-not (Test-BPOEVT)) {
    # VT not supported → single color via Host
    Write-Host ([string]::new($Char,[int]$w)) -ForegroundColor $Color
    return
  }

  $sb = [System.Text.StringBuilder]::new($w*10)
  switch ($Gradient) {
    'Rainbow' {
      for($i=0;$i -lt $w;$i++){
        $h = $i / [double]$w
        $rgb = Convert-BPOEHslToRgb -H $h -S 1 -L 0.5
        [void]$sb.Append( (New-BPOEAnsiFg $rgb.R $rgb.G $rgb.B) )
        [void]$sb.Append($Char)
      }
    }
    'Sunset' {
      $start = [pscustomobject]@{R=255;G=95 ;B=109}
      $end   = [pscustomobject]@{R=255;G=195;B=113}
      for($i=0;$i -lt $w;$i++){
        $t=$i/[double]$w
        $r=[int]([math]::Round($start.R+(($end.R-$start.R)*$t)))
        $g=[int]([math]::Round($start.G+(($end.G-$start.G)*$t)))
        $b=[int]([math]::Round($start.B+(($end.B-$start.B)*$t)))
        [void]$sb.Append((New-BPOEAnsiFg $r $g $b))
        [void]$sb.Append($Char)
      }
    }
    'Ocean' {
      $start = [pscustomobject]@{R=0;G=198;B=255}
      $end   = [pscustomobject]@{R=0;G=114;B=255}
      for($i=0;$i -lt $w;$i++){
        $t=$i/[double]$w
        $r=[int]([math]::Round($start.R+(($end.R-$start.R)*$t)))
        $g=[int]([math]::Round($start.G+(($end.G-$start.G)*$t)))
        $b=[int]([math]::Round($start.B+(($end.B-$start.B)*$t)))
        [void]$sb.Append((New-BPOEAnsiFg $r $g $b))
        [void]$sb.Append($Char)
      }
    }
    'Forest' {
      $start = [pscustomobject]@{R=16;G=122;B=72}
      $end   = [pscustomobject]@{R=154;G=205;B=50}
      for($i=0;$i -lt $w;$i++){
        $t=$i/[double]$w
        $r=[int]([math]::Round($start.R+(($end.R-$start.R)*$t)))
        $g=[int]([math]::Round($start.G+(($end.G-$start.G)*$t)))
        $b=[int]([math]::Round($start.B+(($end.B-$start.B)*$t)))
        [void]$sb.Append((New-BPOEAnsiFg $r $g $b))
        [void]$sb.Append($Char)
      }
    }
    'Candy' {
      $start = [pscustomobject]@{R=255;G=105;B=180}
      $end   = [pscustomobject]@{R=135;G=206;B=250}
      for($i=0;$i -lt $w;$i++){
        $t=$i/[double]$w
        $r=[int]([math]::Round($start.R+(($end.R-$start.R)*$t)))
        $g=[int]([math]::Round($start.G+(($end.G-$start.G)*$t)))
        $b=[int]([math]::Round($start.B+(($end.B-$start.B)*$t)))
        [void]$sb.Append((New-BPOEAnsiFg $r $g $b))
        [void]$sb.Append($Char)
      }
    }
    default {
      # Solid color via ANSI (maps ConsoleColor to RGB roughly)
      $map = @{
        Black=0,0,0; DarkBlue=0,0,139; DarkGreen=0,100,0; DarkCyan=0,139,139
        DarkRed=139,0,0; DarkMagenta=139,0,139; DarkYellow=184,134,11; Gray=190,190,190
        DarkGray=105,105,105; Blue=30,144,255; Green=0,255,127; Cyan=0,255,255
        Red=255,99,71; Magenta=255,0,255; Yellow=255,215,0; White=255,255,255
      }
      $rgb = $map[$Color.ToString()]
      if (-not $rgb) { $rgb = @(190,190,190) }
      [void]$sb.Append( (New-BPOEAnsiFg $rgb[0] $rgb[1] $rgb[2]) )
      [void]$sb.Append( [string]::new($Char,[int]$w) )
    }
  }
  [void]$sb.Append($script:_BPOEAnsiReset)
  Write-Host $sb.ToString()
}

$script:BPOE_Stopwatches = @{}

function Start-BPOESet {
  param(
    [Parameter(Mandatory,Position=0)][string]$Name,
    [string]$Id = $env:COSESSION_ID,
    [char]$Style='═',
    [ValidateSet('None','Rainbow','Sunset','Ocean','Forest','Candy')] [string]$Gradient='None',
    [ConsoleColor]$Color = [ConsoleColor]::Gray
  )
  Write-BPOELine -Char $Style -Gradient $Gradient -Color $Color
  $utc = (Get-Date).ToUniversalTime().ToString('o')
  $boldStart = try { if ($PSStyle) { "$($PSStyle.Bold)" } } catch {}
  $boldEnd   = try { if ($PSStyle) { "$($PSStyle.Reset)" } } catch {}
  Write-Host ("{0}BPOE ▶ START: {1}{2}   @ {3}   SID={4}" -f $boldStart,$Name,$boldEnd,$utc,($Id ?? '(none)'))
  Write-BPOELine -Char $Style -Gradient $Gradient -Color $Color
  $script:BPOE_Stopwatches[$Name] = [System.Diagnostics.Stopwatch]::StartNew()
  try{
    $ccl  = $env:COCACHE_LOCAL ?? (Join-Path $HOME 'Downloads/CoCacheLocal')
    $base = Join-Path $ccl 'sessions'
    if ($Id) { $base = Join-Path $base $Id }
    New-Item -Type Directory -Force -Path $base | Out-Null
    [ordered]@{ ts=$utc; session_id=$Id; demark="$Style"; name=$Name } |
      ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8NoBOM (Join-Path $base 'bpoe-state.json')
  } catch {}
}

function End-BPOESet {
  param(
    [Parameter(Mandatory,Position=0)][string]$Name,
    [string]$Status='OK',
    [char]$Style='═',
    [ValidateSet('None','Rainbow','Sunset','Ocean','Forest','Candy')] [string]$Gradient='None',
    [ConsoleColor]$Color = [ConsoleColor]::Gray
  )
  $sw = $script:BPOE_Stopwatches[$Name]
  $elapsed = if($sw){ $sw.Stop(); $sw.Elapsed.ToString() } else { '(n/a)' }
  Write-BPOELine -Char $Style -Gradient $Gradient -Color $Color
  $utc = (Get-Date).ToUniversalTime().ToString('o')
  Write-Host ("BPOE ◀ END  : {0}   status={1}   elapsed={2}   @ {3}" -f $Name,$Status,$elapsed,$utc)
  Write-BPOELine -Char $Style -Gradient $Gradient -Color $Color
  $emit = Join-Path (Join-Path ($env:COCACHE_LOCAL ?? (Join-Path $HOME 'Downloads/CoCacheLocal')) 'bin') 'Emit.ps1'
  if (Test-Path $emit) { & $emit -Agent 'B' -Type 'bpoe-set' -Msg "$Name completed: $Status" -Data @{ elapsed=$elapsed } | Out-Null }
}

function Invoke-BPOESet {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory,Position=0)][string]$Name,
    [Parameter(Mandatory,Position=1)][scriptblock]$ScriptBlock,
    [char]$Style='═',
    [ValidateSet('None','Rainbow','Sunset','Ocean','Forest','Candy')] [string]$Gradient='None',
    [ConsoleColor]$Color = [ConsoleColor]::Gray,
    [ValidateSet('Continue','Stop')][string]$OnError='Continue'
  )
  Start-BPOESet -Name $Name -Style $Style -Gradient $Gradient -Color $Color
  $status = 'OK'
  try   { & $ScriptBlock }
  catch { $status = 'ERROR'; Write-Error $_; if ($OnError -eq 'Stop') { throw } }
  finally { End-BPOESet -Name $Name -Status $status -Style $Style -Gradient $Gradient -Color $Color }
}

Export-ModuleMember -Function *-BPOE*,Write-BPOELine

