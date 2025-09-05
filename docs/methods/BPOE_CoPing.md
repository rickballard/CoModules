# BPOE — CoPing “Paste Button” Pattern (PS7)
Place this one-liner under each DO Block:
```
pwsh -NoProfile -ExecutionPolicy Bypass -File ./tools/BPOE/CoPingLauncher.ps1 -FromFile ./docs/do/DO-123.ps1
```
Add `-HitEnter` only if the block is safe to auto-run.
> **CoPong (full-send)**
>
> ```
> pwsh -NoProfile -ExecutionPolicy Bypass -File ./docs/do/DO_Run_Tests_and_Rerun_CI.ps1
> ```

