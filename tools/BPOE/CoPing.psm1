# CoPing.psm1 (no Win32 P/Invoke)
Set-StrictMode -Version Latest

function Set-CoClipboard {
  [CmdletBinding()]
  param([Parameter(ValueFromPipeline=$true,Mandatory=$true)][string]$Text)
  process {
    try { Set-Clipboard -Value $Text -ErrorAction Stop; return $true } catch {
      $p = [System.Diagnostics.Process]::Start((New-Object System.Diagnostics.ProcessStartInfo -Property @{
        FileName = "cmd.exe"; Arguments = "/c clip"; RedirectStandardInput = $true; UseShellExecute = $false }))
      $p.StandardInput.Write($Text); $p.StandardInput.Close(); $p.WaitForExit(); return $p.ExitCode -eq 0
    }
  }
}

function Focus-CoPsWindow {
  # Running inside the originating terminal session—no focus change required.
  Write-Host "[CoPing] Using current PS7/Terminal focus."
  return $true
}

function Send-CoPaste { [CmdletBinding()] param([switch]$HitEnter)
  try { Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop } catch {}
  $sent = $false
  try { [System.Windows.Forms.SendKeys]::SendWait("^+v"); Start-Sleep -Milliseconds 100; $sent = $true } catch {}
  if (-not $sent) { try { [System.Windows.Forms.SendKeys]::SendWait("^v"); Start-Sleep -Milliseconds 100; $sent = $true } catch {} }
  if ($HitEnter) { try { [System.Windows.Forms.SendKeys]::SendWait("{ENTER}") } catch {} }
  if ($sent) { Write-Host "[CoPing] Pasted." } else { Write-Host "[CoPing] Paste keys failed." }
  return $sent
}

function Invoke-CoPing {
  [CmdletBinding(DefaultParameterSetName="Text")]
  param(
    [Parameter(ParameterSetName="Text",Mandatory=$true)][string]$Text,
    [Parameter(ParameterSetName="File",Mandatory=$true)][string]$FromFile,
    [Parameter(ParameterSetName="Url", Mandatory=$true)][string]$FromUrl,
    [switch]$HitEnter
  )
  if ($PSCmdlet.ParameterSetName -eq "File") { $Text = Get-Content -Raw -LiteralPath $FromFile }
  if ($PSCmdlet.ParameterSetName -eq "Url")  { $Text = Invoke-RestMethod -UseBasicParsing -Uri $FromUrl }
  if (-not $Text) { throw "No text to paste." }
  [void](Set-CoClipboard -Text $Text); [void](Focus-CoPsWindow); [void](Send-CoPaste -HitEnter:$HitEnter)
}

Export-ModuleMember -Function Invoke-CoPing, Set-CoClipboard, Focus-CoPsWindow, Send-CoPaste
