function Reset-CoShell {
  try { Set-StrictMode -Off } catch {}
  try { $global:ErrorActionPreference = "Continue" } catch {}
  try { [Console]::TreatControlCAsInput = $false } catch {}
  Write-Host "Shell reset: StrictMode=Off, EAP=Continue."
}
Export-ModuleMember -Function Reset-CoShell
