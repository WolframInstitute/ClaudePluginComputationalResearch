---
allowed-tools:
  - Bash
  - Read
---
Drive a `Work/` item unattended: `${CLAUDE_PLUGIN_ROOT}/scripts/auto-run.sh $ARGUMENTS`.

Run it with the Bash tool from the repo root and let it finish — it spawns one cold `claude -p` process per task, so it is slow and its output is the only progress signal.
Do **not** do the tasks yourself, and do not re-run it after a halt.

Arguments are passed straight through: `[<Item>] [--max-tasks N] [--max-minutes M] [--max-cost USD] [--allow 'Tool(pattern)'] [--dry-run]`.
Name the item when more than one is eligible.
Use `--dry-run` first if the user has not run this before — it prints the selection, the branch, the next task, and the caps without spawning anything, though it still refuses a dirty tree.

The item must carry `> Autonomous: allowed` beside its `> Type:` line, or selection fails closed.
The driver refuses to start on a dirty tree, commits to `auto/<Item>` rather than the current branch, and halts on the first failure without cleaning up.

Afterwards, Read the digest it names (`Work/Runs/<timestamp>-<Item>.md`, gitignored) and report:

1. the stop reason, and whether it is the success exit (`item-complete`, or a `cap-*` backstop) or a fault;
2. per-task verdicts, the commits on `main..auto/<Item>`, and the accumulated tokens and cost;
3. the `## Hand-off` delta — for `needs-human` this is the question the run would not guess at, so quote it, and check it on a `no-box` halt too, since a session that stops mid-task fails liveness before the marker is read;
4. for `permission-denied`, the tools it wanted, and that re-running with `--allow '<Tool>(<pattern>)'` is the fix — the halt names only tools absent from *every* settings file, because `--allowedTools` adds to `permissions.allow` rather than replacing it;
5. for `no-commit`, that the digest's commit and diff sections are empty **by construction** while the work may be sitting uncommitted — read `git status` before concluding the session did nothing.

Then say what the human owes: review `auto/<Item>` and merge it (the merge is the `revise` approval), or answer the hand-off question.
Leave the branch and the working tree exactly as the driver left them — recovery after a mid-task failure is the user's call, never an automatic `git reset`.

Specification, including why cron and `/loop` cannot drive this: `Wiki/Concepts/AutonomousPipeline.md` in the plugin repo.
