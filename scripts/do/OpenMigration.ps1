Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$doc  = Join-Path (Join-Path $root "docs\migration") "PLAN.md"
if(-not (Test-Path $doc)){
  $body = @"
# Grand Migration — PLAN

## Scope (today)
- ☐ Cutlist of repos/assets to migrate
- ☐ Directory + naming conventions
- ☐ Minimal shims / adapters
- ☐ Retire legacy bits (list)

## Steps
1) Inventory + cutlist
2) Create target tree
3) Move modules (atomic, repeatable)
4) Smoke tests (auto)
5) Commit + tag

## Notes
- Keep demo/live switch on until commit step.
- Use breadcrumbs to keep panes in sync.

"@
  $enc = New-Object System.Text.UTF8Encoding($false)
  [IO.File]::WriteAllText($doc,$body,$enc)
}
Start-Process $doc
$env:CoDO_FOOTER_DONE="1"