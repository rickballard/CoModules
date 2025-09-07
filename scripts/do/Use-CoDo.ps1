function Import-CoDo {
  $runner = Resolve-Path ".\scripts\do\CoDO.Runner.psm1"
  $pong   = Resolve-Path ".\scripts\do\CoPingButton.psm1"
  Import-Module $pong   -Force
  Import-Module $runner -Force
  Write-Host "CoDO modules loaded."
}
# NOTE: This is a script, not a module — do NOT call Export-ModuleMember here.
