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
It is checked *after* the preflight rather than before it, so it still refuses a dirty working tree: `--dry-run` is a rehearsal of a real launch, not an inspection you can perform mid-edit.

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

One trap in that reading order, seen live on a `no-commit` halt.
**Commits** and **Files touched** are both derived from `git log`/`git diff` and so show only what was *committed*, while the **Hand-off delta** is read from the working-tree file and shows what the session *wrote*.
On a `no-commit` halt the two disagree by design: the diff sections are empty and the delta is full, so a digest read top-to-bottom looks like a session that produced nothing when in fact its work is sitting uncommitted in the tree.
Read the delta before concluding anything from the empty diff, and then read `git status`.

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

**`needs-human` is checked after a task, not before one — and only after the liveness pair has passed.**
So a marker left in `## Hand-off` does not stop the next run at the door: it spends one whole task first, then halts on the same question, and clearing the marker is part of answering it.
The ordering has a sharper consequence than that.
`revise` § *Autonomous mode* tells a session facing a real decision to write the question, commit that, and **stop** — but a session that stops without closing its box fails liveness first and halts as `no-box`, so the reason you actually see is the wrong one.
`needs-human` is reachable only from a session that closed its box, committed, *and* left a question.
In practice that means the reason is honest when a task finished and raised a follow-on question, and misleading when a task genuinely could not proceed; on a `no-box` halt, read the `## Hand-off` delta for a `needs-human:` line before treating it as a liveness failure.

**`no-box` usually means the box was checked in place.**
The driver counts `- [x]` lines only inside the `### Done` subsection, so a session that ticked the box but left it under `## Tasks` looks identical to one that did nothing.
`no-commit` is the blunter cousin: files may well be written and uncommitted, so read `git status` before discarding anything.

**The cost and wall-clock caps are checked before a task starts, not during it.**
A run can therefore overshoot `--max-cost` and `--max-minutes` by up to one task.
`--max-tasks` is exact.

The driver never cleans up after a fault.
It leaves the branch, the working tree, and any partial work exactly as they stand, because an unattended `git reset --hard` is the one action that can destroy work no human has seen.
Recovery is always yours to perform.

### What the four failure halts actually look like

Measured on 2026-07-28 by `HardenAutoRun` T1 and T2, against the throwaway `AutoRunHaltTrial`, whose tasks each carried their own sabotage instruction.
Until then these four had only ever fired against a stub `claude`, which halts on demand and so proves nothing about a real session.
Five runs, one task each, $12.60 total.

| condition | verdict line | commits / diff | recovery performed |
|---|---|---|---|
| `needs-human` | `**ok**` for the task, *then* a second `**halt**` line — the only reason with two lines | present | clear the marker, commit |
| `no-commit` | one `**halt**`, `— no new commit` | **both empty**, while the Hand-off delta is full | `git add -A && git commit` the tree as it stands |
| `no-box` | one `**halt**`, `` — `### Done` gained no box (2 → 2) `` | present | move the ticked line into `### Done` with its session number |
| `permission-denied` | one `**halt**`, `— 1 permission denial(s): mcp__Wolfram__SymbolDefinition` | present | add the named tool to the defaults |

All four exit `1`, all four report `subtype: success` — the CLI's own verdict on the session is useless as a signal, which is the whole reason the driver verifies rather than trusts.
Turn counts were 16–21 and per-task cost $1.71–$4.09, in line with the trial's $1.5–2.6 and above it once a task does real tool work.

Two of these were harder to trip than the runbook implied, and both taught something.
`no-commit` and `no-box` cannot be provoked by a well-behaved session at all — they had to be *instructed*, which is itself the finding: these conditions catch harness faults and malformed item files, not misjudgement.
`permission-denied` took two attempts, and the first failure is the more important result — see below.

## Growing the allowlist

Headless, a tool call that is not allowed cannot raise a prompt, so it is denied, recorded in the run JSON's `permission_denials`, and turned into a `permission-denied` halt that names the tool.
The fix is one `--allow` per entry, appended to the defaults:

```bash
/auto-run MyItem --allow 'Bash(rg:*)' --allow 'mcp__Wolfram__CreateSymbolDoc'
```

The defaults cover `Read`, `Write`, `Edit`, `Glob`, `Grep`, `Skill`, `TodoWrite`, the eight `git` forms `next-session` step 8 makes, `ls`, `cat`, `mkdir`, `date`, `grep`, the seven official Wolfram MCP tools named in `CLAUDE.md` § *Wolfram Kernel Execution Policy*, and `Bash(wolframscript:*)` for the fallback path.
There is no way to *remove* a default — the list only grows.

### `--allowedTools` is a floor, not a ceiling

This is the correction `HardenAutoRun` T2 made, and it inverts what this section used to claim.

**`--allowedTools` is added to whatever the settings files already allow; it does not replace them.**
So the driver's list does not *bound* an unattended run — it only guarantees a minimum.
A tool that `~/.claude/settings.json` allows is reachable in every autonomous run whether or not the driver names it, and the only tools that can ever be denied are those absent from **every** settings file.

On this machine that is close to fatal for the discovery mechanism.
The user-level allowlist carries 248 entries including **blanket `Bash`, `Edit`, `Write`, `Read`, `NotebookEdit`, `WebFetch`, and `WebSearch`**, plus the project's own 175 — so almost nothing a session reaches for can be denied, and `permission-denied` is nearly unreachable by accident.
The first Wolfram probe proved it: a task told to evaluate `2 + 2` through `mcp__Wolfram__WolframLanguageEvaluator` ran clean and returned `4`, because that tool is allowlisted by name at user level.
Tripping the condition took a deliberately chosen tool the settings do *not* name — `mcp__Wolfram__SymbolDefinition` — which was refused before evaluation with *"Claude requested permissions to use mcp__Wolfram__SymbolDefinition, but you haven't granted it yet"*.

Three consequences for an operator:

- **A clean run is not evidence that the defaults were sufficient.** The supervised trial's zero `permission_denials` on two prose tasks was read as "prose stays inside the defaults"; it actually showed only that the settings were permissive. Any conclusion of that shape has to be re-derived on a machine with a narrow settings file.
- **Do not rely on the halt to discover requirements.** In a permissive environment there is nothing to discover, so the defaults have to carry what a task legally needs up front — which is why the Wolfram set is now in them rather than waiting to be reported.
- **`acceptEdits` plus `--allowedTools` is not a sandbox here.** With blanket `Bash` allowed at user level, an autonomous session can run any shell command that is not on the settings' 17-entry `ask` list. Headless, `ask` cannot prompt and so behaves as deny — those seventeen destructive `git`/`rm` forms are the *real* bound on an unattended run, not the driver's list. Treat the branch-plus-merge gate, not the allowlist, as what makes autonomy safe.

One thing still holds unchanged: **the digest names the tool, not its input.**
A denied `Bash` call appears as bare `Bash`, so the command has to be inferred from the task and the skill it invokes.
When that is not obvious, run the task once interactively and watch what it reaches for.

## Landing `auto/<Item>` on `main`

The merge is the approval step — `revise` § *Autonomous mode* defers the human gate to exactly this point, and nothing autonomous is meant to reach `main` any other way.

```bash
git log --oneline main..auto/MyItem
git diff main...auto/MyItem
git checkout main && git merge --no-ff auto/MyItem
git branch -d auto/MyItem
```

A repo with a `commit-msg` hook adds a wrinkle, though not at the merge.
This one — `.githooks/commit-msg`, activated by `core.hooksPath` rather than sitting in `.git/hooks/`, so look for it there — enforces Conventional Commits with a 72-character subject, but it whitelists subjects beginning `Merge `, `Revert `, `fixup!`, `squash!`, and `amend!`.
So `git merge --no-ff`'s default `Merge branch 'auto/MyItem'` **passes**, verified live on 2026-07-28; an earlier draft of this runbook claimed it was rejected and prescribed a manual `git commit` to finish a half-done merge, which was wrong.
The hook remains a live hazard *inside* a run: a session whose commit it rejects has written its files but committed nothing, which the driver sees as `no-commit`.
So `no-commit` in a hooked repo means "read the hook's output", not "the session did nothing" — and the files are still in the working tree.

Review the diff, not the digest: the digest reports what the driver observed, while the diff is what the sessions actually wrote.
Nothing from `Work/Runs/` comes along — it is gitignored.

If a task's output is wrong, do not repair it on `main`.
Either drop the commit on the branch, or reopen the box in the item file and let a later session redo the task, so the branch stays the single record of what autonomy produced.

One scheduling rule follows from the driver reusing an existing `auto/<Item>` rather than branching fresh: **review before the next run, not after several.**
An unmerged branch means the next run stacks new tasks on top of work nobody has approved, which is precisely the silent drift the one-failure-halts policy exists to prevent.

## Where the script and the specification disagree

Nowhere, as of 2026-07-28.
This runbook found five divergences when it was written, all since corrected in [the specification](AutonomousPipeline.md) — selection globbing `Work/Active/` rather than reading the index, the `(human)` gate matching as a substring, `unparseable-output` quoting 1 kB of stdout plus 1 kB of stderr, `item-vanished` and `interrupted` as stop reasons, and the four-valued exit status.

Running the four failure conditions live then found four more, this time in **this** article rather than in the specification, and all four are fixed above: the claim that no MCP tool is allowlisted, the claim that the merge message is rejected by the hook, the implication that `needs-human` fires on a session that stopped mid-task, and the omission that `--dry-run` still requires a clean tree.
That the runbook was wrong where the specification was right is the expected direction — the specification was reconciled against the script, while this article was written against the script's *documented intent* and never against a real failure.

The precedence rule stands for the next divergence: the script is the fact, and the article is what gets corrected.
When you find one, fix the article rather than recording it here — a standing list of known-wrong documentation is a second thing to keep current.

## See also

- [The autonomous next-session pipeline](AutonomousPipeline.md) — the design record: why the loop is shaped this way, and where each stop condition is implemented
- [The work item file format](ItemFileFormat.md) — `## Hand-off` and `### Done`, the two sections the driver reads as state
- [Session Information Budget](SessionInformationBudget.md) — the per-task preamble cost the digest re-measures on every run
- [Status](../Status.md)
