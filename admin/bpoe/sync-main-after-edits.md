# BPOE: Syncing main after side edits

- Park local edits on a WIP branch: git switch -c wip/... && git add -A && git commit.
- Make main match remote: git fetch origin && git reset --hard origin/main.
- Recreate lightweight checkpoint files on top of main, then push.
- Prefer PRs to carry parked edits back in, split as needed.
