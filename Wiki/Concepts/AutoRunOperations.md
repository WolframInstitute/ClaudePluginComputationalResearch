# The `/auto-run` operator runbook

*[ LLM Generated ]*

What an operator does when an unattended run halts: how to read the digest, what each stop reason asks of you, how to grow the allowlist, and how `auto/<Item>` reaches `main`.

This is the runbook.
The design record — why the harness schedulers cannot drive the loop, why the `revise` gate survives as a branch plus a digest, what each stop condition is *for* — is [The autonomous next-session pipeline](AutonomousPipeline.md), and is not restated here.
Written against `scripts/auto-run.sh` as it stands on 2026-07-28.
Where the script and the specification disagree the script is the fact — see [the end](#where-the-script-and-the-specification-disagree) for how that is handled and why nothing is outstanding.

## Before a run

`/auto-run <Item> --dry-run` prints the selection, the branch it would use, the next task, the caps, the digest path, and the full allowlist — and exits without creating a branch, a digest, or a process.
Use it first on any item that has not run before.

The defaults are three tasks, ninety minutes, and five dollars (`--max-tasks`, `--max-minutes`, `--max-cost`).

Preflight failures exit **2**, and they are the one class of failure that writes **no digest** and creates no branch: `claude` or `jq` missing from `PATH`, not inside a git repository, no `Work/` directory, a dirty working tree at the start, a named item that is not in `Work/Active/`, an item without `> Autonomous: allowed`, or zero / more than one eligible item when none was named.
All of these are reported on stderr as `auto-run: <reason>` and are fixed before re-running.

Once the loop starts, the only progress signal is one stderr line per task — `auto-run: <Item> T3 — 14:22:07Z` — and the run is slow, because each task is a cold `claude -p` process.
The digest is written once, at the halt.

## Reading the digest

`Work/Runs/<UTC-stamp>-<Item>.md`, gitignored, one per run.
The driver never prunes them; they accumulate until you delete them.

Read it in this order:

1. **Stop reason** in the header table — everything else is context for it.
2. **Per-task verdict** — one line per task, `**ok**` or `**halt**`, each carrying the task id, turn count, cost, and the `subtype` the CLI reported. The final line names the fault.
3. **Hand-off delta** — the `## Hand-off` text before and after the run. For `needs-human` this is the question the run refused to guess at.
4. **Commits** and **Files touched** — `git log`/`git diff --stat` over `BASE_SHA..HEAD`.

That last range is worth understanding before you trust it.
`BASE_SHA` is `HEAD` *at launch*, captured before the checkout — so launching from `main` against an `auto/<Item>` branch that already carries unmerged commits gives a digest listing **every** commit on that branch, not just this run's.
Launching from the `auto/<Item>` branch itself scopes the range to the current run.

The token and cost figures are summed from each run's `.usage` and are the pipeline's own measurement of its per-task price — the only mechanism that keeps [the session budget](SessionInformationBudget.md) from going stale.

## Stop reasons — what each one asks of you

The driver exits `0` for the first two rows, `130` for an interrupt, and `1` for everything else.

| reason | exit | what to do |
|---|---|---|
| `item-complete` | 0 | Success. The last box closed and the item file moved to `Work/Done/YYYY-MM-DD-<Item>.md`. Review and merge the branch. |
| `cap-tasks` / `cap-wallclock` / `cap-cost` | 0 | A backstop, not a fault. Work is intact; merge it, then re-run with a raised cap. |
| `task-gated` | 1 | The next task line contains `(human)`. Do that task yourself in an interactive `/next-session`, commit, then re-run. Nothing is broken despite the non-zero exit. |
| `needs-human` | 1 | A session wrote a `needs-human:` question into `## Hand-off` rather than guessing. Answer it — the answer usually belongs in the Spec or a `## Decisions` row — then **overwrite `## Hand-off` to remove the marker** and commit before re-running. |
| `dirty-tree` | 1 | Uncommitted changes appeared between tasks (`Work/Runs/` is excluded from the check). `git status`, commit or stash, re-run. |
| `no-commit` / `no-box` | 1 | The run reported success and closed nothing — the liveness condition. See below. |
| `permission-denied` | 1 | The run needed a tool that is not allowlisted. See [Growing the allowlist](#growing-the-allowlist). |
| `nonzero-exit` / `is-error` / `stop-reason` / `terminal-reason` | 1 | The CLI run itself failed. The verdict line carries the `subtype`; to see the actual error, run that one task interactively. |
| `unparseable-output` | 1 | Stdout was not JSON. The digest quotes the first 1 kB of stdout and 1 kB of stderr — usually a CLI-level failure such as a rejected flag or an expired login, not a session fault. |
| `item-vanished` | 1 | The item file is neither `Work/Active/<Item>.md` nor `Work/Done/*-<Item>.md`. A session moved it into `Dropped/`, or into `Done/` without the date prefix. Put it back where the driver looks. |
| `interrupted` | 130 | `Ctrl-C` or `SIGTERM`. The digest is still written and the tree is left exactly as it stood. |

Three of these have sharp edges.

**`needs-human` is checked after a task, not before one.**
So a marker left in `## Hand-off` does not stop the next run at the door — it spends one whole task first, then halts on the same question.
Clearing the marker is part of answering it.

**`no-box` usually means the box was checked in place.**
The driver counts `- [x]` lines only inside the `### Done` subsection, so a session that ticked the box but left it under `## Tasks` looks identical to one that did nothing.
`no-commit` is the blunter cousin: files may well be written and uncommitted, so read `git status` before discarding anything.

**The cost and wall-clock caps are checked before a task starts, not during it.**
A run can therefore overshoot `--max-cost` and `--max-minutes` by up to one task.
`--max-tasks` is exact.

The driver never cleans up after a fault.
It leaves the branch, the working tree, and any partial work exactly as they stand, because an unattended `git reset --hard` is the one action that can destroy work no human has seen.
Recovery is always yours to perform.

## Growing the allowlist

Headless, a tool call that is not allowlisted cannot raise a prompt, so it is denied, recorded in the run JSON's `permission_denials`, and turned into a `permission-denied` halt that names the tool.
This is the designed way to discover what a class of task needs: the loop reports the requirement rather than being handed everything up front.

The fix is one `--allow` per entry, appended to the defaults:

```bash
/auto-run MyItem --allow 'Bash(wolframscript:*)' --allow 'Bash(rg:*)'
```

The defaults cover `Read`, `Write`, `Edit`, `Glob`, `Grep`, `Skill`, `TodoWrite`, the eight `git` forms `next-session` step 8 makes, and `ls`, `cat`, `mkdir`, `date`, `grep`.
There is no way to *remove* a default — the list only grows.

Two things to expect:

- **The digest names the tool, not its input.** A denied `Bash` call appears as bare `Bash`, so the command has to be inferred from the task and the skill it invokes. When that is not obvious, run the task once interactively and watch what it reaches for.
- **No MCP tool is allowlisted.** Any task that touches the Wolfram MCP halts on its first call unless you add the tool by name. Wiki-prose tasks are the ones that run clean today, which is why they were chosen for the trial.

## Landing `auto/<Item>` on `main`

The merge is the approval step — `revise` § *Autonomous mode* defers the human gate to exactly this point, and nothing autonomous is meant to reach `main` any other way.

```bash
git log --oneline main..auto/MyItem
git diff main...auto/MyItem
git checkout main && git merge --no-ff auto/MyItem
git branch -d auto/MyItem
```

A repo with a `commit-msg` hook adds a wrinkle at both ends.
This one enforces Conventional Commits with a 72-character subject, so `git merge --no-ff`'s default `Merge branch 'auto/MyItem'` is **rejected** and the merge stops half-done — finish it with `git commit -m 'chore(work): merge …'`.
The same hook is a live hazard inside a run: a session whose commit the hook rejects has written its files but committed nothing, which the driver sees as `no-commit`.
So `no-commit` in a hooked repo means "read the hook's output", not "the session did nothing" — and the files are still in the working tree.

Review the diff, not the digest: the digest reports what the driver observed, while the diff is what the sessions actually wrote.
Nothing from `Work/Runs/` comes along — it is gitignored.

If a task's output is wrong, do not repair it on `main`.
Either drop the commit on the branch, or reopen the box in the item file and let a later session redo the task, so the branch stays the single record of what autonomy produced.

One scheduling rule follows from the driver reusing an existing `auto/<Item>` rather than branching fresh: **review before the next run, not after several.**
An unmerged branch means the next run stacks new tasks on top of work nobody has approved, which is precisely the silent drift the one-failure-halts policy exists to prevent.

## Where the script and the specification disagree

Nowhere, as of 2026-07-28.
This runbook found five divergences when it was written; [the specification](AutonomousPipeline.md) has since been corrected to match the script on all five — selection globbing `Work/Active/` rather than reading the index, the `(human)` gate matching as a substring, `unparseable-output` quoting 1 kB of stdout plus 1 kB of stderr, `item-vanished` and `interrupted` as stop reasons, and the four-valued exit status.

The precedence rule stands for the next divergence: the script is the fact, and the article is what gets corrected.
When you find one, fix the article rather than recording it here — a standing list of known-wrong documentation is a second thing to keep current.

## See also

- [The autonomous next-session pipeline](AutonomousPipeline.md) — the design record: why the loop is shaped this way, and where each stop condition is implemented
- [The work item file format](ItemFileFormat.md) — `## Hand-off` and `### Done`, the two sections the driver reads as state
- [Session Information Budget](SessionInformationBudget.md) — the per-task preamble cost the digest re-measures on every run
- [Status](../Status.md)
