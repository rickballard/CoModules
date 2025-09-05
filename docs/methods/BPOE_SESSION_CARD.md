# BPOE Session Card — Temporary Guardrails (print/keep on Desktop)
**Updated:** 2025-09-05 19:14 

## Purpose (temporary)
Until the assistant reliably logs workflow wisdom and mitigates repo constraints, use this card to steer every session.

## Session Guardrails (say this at the top of a session)
**BPOE SESSION GUARDRAILS:** 
- Use **BDBP** lens; be concise; *no chatter*.
- **DO Blocks only.** If content >10 lines, ship as **downloadable file** + give a **CoPing one‑liner**. No long inline code.
- **CoPing required** under every DO Block that targets PS7: use `./tools/BPOE/CoPingLauncher.ps1`.
- **Cumulative logging:** append to `docs/methods/BPOE_WISDOM.md` with today's date. Never overwrite.
- **Workflow updates:** put scripts in `tools/BPOE/`, methods in `docs/methods/`, CI in `.github/workflows/`, tests in `tests/`.
- **Commits:** use `docs(bpoe): …` and `ci(bpoe): …` prefixes.
- **No branch protection on `main`** until explicitly told otherwise.
- **No YAML into shell.** YAML goes to files only.
- **End of session:** write/refresh `docs/SESSION_SUMMARY_YYYYMMDD.md` and link it.

## Prompts to reuse (paste exact)

**BPOE LOG (repo=CoModules, branch=<current>):**
- <bullet 1>
- <bullet 2>
- <etc>

**BPOE WORKFLOW (repo=CoModules, branch=<current>):** "<workflow name>" — <one‑line goal>. Acceptance: <checks>.

**DO BLOCKS (repo=CoModules, branch=<current>) — tasks:**
- <task 1>
- <task 2>

## CoPing pattern (under each DO Block)
```
pwsh -NoProfile -ExecutionPolicy Bypass -File ./tools/BPOE/CoPingLauncher.ps1 -FromFile <relative-path-to-script.ps1>
```
Add `-HitEnter` only if safe to auto-execute.

## “Bloat” rule
If any response >25 lines, **stop** and provide downloadable files + CoPing one‑liners. Do not dump long code in chat.

## End-of-session checklist
- Append dated entry to `docs/methods/BPOE_WISDOM.md` (bullets of what changed).
- Ensure CI files/tests updated if workflows changed.
- Write/refresh `docs/SESSION_SUMMARY_YYYYMMDD.md` and include branch + PR link.
- Keep `main` unprotected until migration completes.

## Handy links
- **Current session summary (this branch):** [https://github.com/rickballard/CoModules/blob/docs/bdbp-coagent-250905-1400/docs/SESSION_SUMMARY_20250905.md](https://github.com/rickballard/CoModules/blob/docs/bdbp-coagent-250905-1400/docs/SESSION_SUMMARY_20250905.md)
- **Wisdom log (cumulative):** [./BPOE_WISDOM.md](./BPOE_WISDOM.md)
- **Working branch root:** [docs/bdbp-coagent-250905-1400](https://github.com/rickballard/CoModules/blob/docs/bdbp-coagent-250905-1400/)
- **PR #16:** https://github.com/rickballard/CoModules/pull/16


## CoPong (full-send) pattern
Use when safe to auto-execute:
pwsh -NoProfile -ExecutionPolicy Bypass -File ./docs/do/DO-123.ps1


## CoPong (full-send) pattern
Use when safe to auto-execute:
pwsh -NoProfile -ExecutionPolicy Bypass -File ./docs/do/DO-123.ps1

## CoPong rule (enforced)
If a DO Block is **safe to auto-execute**, append this line under it:
`pwsh -NoProfile -ExecutionPolicy Bypass -File ./docs/do/DO-XYZ.ps1`
Otherwise use **CoPing** (paste-for-review).
