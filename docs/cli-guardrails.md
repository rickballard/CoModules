# CLI Guardrails (PowerShell)

**Always re-orient PS7 before any new instruction set.** Use:

```powershell
$repo = Join-Path $HOME 'Documents\GitHub\CoModules'
if(!(Test-Path -LiteralPath $repo)){ throw "Repo not found: $repo" }
Set-Location -LiteralPath $repo; git status -sb;
```

## Double-paste safety
- Prefer multi-line blocks; end one-liners with `;`.
- Scripts SHOULD implement `-Force` and a repo-scoped OS mutex to block accidental double-runs.

## Paste/Run guard template
```powershell
param([switch]$Force)
if(-not $Force){ $ans = Read-Host "About to run. Enter=continue, N=cancel"; if($ans -match '^(n|no)$'){ Write-Host "Cancelled."; return } }
$lockName = "Global\EnterRepo-"+([IO.Path]::GetFullPath($PWD.Path).ToLowerInvariant().GetHashCode())
$mutex = [Threading.Mutex]::new($false,$lockName)
if(-not $mutex.WaitOne(0)){ Write-Host "Already running."; return }
try {
  # ... body ...
} finally { $mutex.ReleaseMutex() | Out-Null; $mutex.Dispose() }
```

## Link checks in docs
- Resolve link targets and **ignore** anything that resolves outside the repository root.
