# The autonomous next-session pipeline

*[ LLM Generated ]*

The specification for running `Work/` items unattended: what drives the loop, how an item is selected with no human present, when the loop stops, and what happens to the `revise` gate.
Decided 2026-07-27 for `EvaluateWorkItemsEfficiency` T4, against [T3's item format](ItemFileFormat.md) and [T1's budget](SessionInformationBudget.md).
Specification only — nothing here is implemented; T7 builds it and T8 trials it.

## The harness cannot schedule this, and the reason is structural

The Spec required checking what already exists before building.
Three mechanisms were candidates, and **all three fail for the same reason**: they enqueue the prompt back into the *current* session, so context accumulates across tasks.

| mechanism | why it does not work |
|---|---|
| `CronCreate` | fires into the running session; in-memory only, dies with the session, fires solely while the REPL is idle, auto-expires after 7 days |
| `/loop` + `ScheduleWakeup` | same session, same accumulation; it is a self-pacing device, not an isolator |
| background tasks | same session |

The Spec's own risk note named this: *compaction is not the same as clearing*.
A loop built on any of the three gets the context rot back, which is the one thing one-task-per-session exists to prevent.

What does work is **headless `claude -p`**, one OS process per task.
That is genuinely cold — a new session id, no inherited history, nothing summarised.
Cron may still *trigger* a run; it cannot *be* the loop.

## Measured properties of `claude -p` (this machine, `claude` 2.1.220)

Three findings from running it rather than assuming.

**`--output-format json` is sufficient instrumentation.**
It returns `is_error`, `stop_reason`, `terminal_reason`, `num_turns`, `permission_denials`, and per-model token and cost usage.
The driver needs no separate telemetry, and the loop can therefore price itself.

**Plugin slash commands require the `plugin:` prefix headless.**
`claude -p "/load-project"` returns `Unknown command`, costs `0`, and reports **`is_error: false`**.
The unprefixed form is a silent, zero-cost, success-reporting no-op — a driver written the obvious way would spin forever doing nothing and report success every time.
`/computational-research:load-project` expands correctly.
This is why stop condition 5 below checks for work actually done rather than trusting the exit status.

**Cold start costs 31,479 input tokens in this repo** — 14,519 cache-creation plus 16,960 cache-read, measured against a 10-token prompt.
That is T1's headline re-measured in tokens instead of bytes, and it is the price of clearing context, paid once per task.
A three-task run spends ~94k tokens of preamble before it opens an item file.

### The consequence for sequencing

The pipeline's dominant cost line is the fixed preamble, not the item file.
So T6 — auditing this repo's 16.6 kB `CLAUDE.md` against `README.md` for duplicated tables — is not a cleanup item that can follow the pipeline.
It is the term that decides whether the pipeline is affordable, and it belongs **before** T7.

## The `revise` gate is deferred, not deleted

`revise` exempts only wiki prose from human sign-off.
Restricting the loop to sign-off-free tasks was the obvious escape and is a non-answer: almost no substantive task qualifies, so the pipeline would be worthless.
The Spec forbade working around this.

The resolution is that the protocol's purpose is *nothing lands unreviewed* — not *a human is present at generation time*.
Those come apart cleanly:

- autonomous runs commit to `auto/<Item>`, never to `main`;
- the per-run digest is the **present** step;
- the human's merge is the **approve** step.

The blocking wait is removed.
The gate is not.
This is the same shape as the existing paclet-worktree rule, where work lands on `work/<item>` and reaches `main` only through review.

When a task genuinely needs a decision the run does **not** guess.
It writes the question into `## Hand-off` and halts the whole loop with reason `needs-human`.
`## Hand-off` is already the fixed place an unattended loop looks for an item's state, which is what T3 built it for.

## The loop

### Selection — fail closed

Read `Work/README.md` for active items.
An item is eligible only if it carries `> Autonomous: allowed` as a header line beside `> Type:`; absent means no.
A task line ending in `(human)` is a hard stop, so an author can gate individual tasks — T4 itself, which had to be presented for approval, is exactly that case.
If zero or more than one eligible active item exists, the driver stops and reports.
It never picks a favourite, because an unattended wrong choice is not observable until the digest.

The header line is one more `>` line above `## Spec`, so it neither adds a section nor breaks the closed section list.

### Per task

One `claude -p --output-format json "/computational-research:next-session <Item>"`, then the driver **verifies the run instead of trusting it**.

### Stop conditions — any one halts the run

1. no unchecked task remains — the item is complete, and this is the success exit;
2. `needs-human` was written to `## Hand-off`;
3. `is_error`, `stop_reason != end_turn`, a non-zero exit, or **any** `permission_denials` entry;
4. the working tree is dirty *before* a task starts — someone else is mid-edit;
5. **liveness** — no new commit, or `### Done` gained no box: the task did not close, so halt rather than re-run it forever;
6. one failure, not two, plus backstop caps on task count, wall clock, and cost.

Condition 5 is the load-bearing one.
The `Unknown command` finding shows the failure mode it catches is real and reports success while producing nothing.
Condition 6 is deliberately intolerant: the Spec's stated failure mode is silent drift, where a wrong call at task 2 acquires four tasks built on top of it before anyone looks.

### Failure mid-task — the driver never cleans up

It records `HEAD` before each task and, on failure, leaves the tree exactly as it stands and stops.
An unattended `git reset --hard` is the one action that can destroy work no human has ever seen, so recovery is a human's call.

### Permissions — `acceptEdits`, not `bypassPermissions`

`--permission-mode acceptEdits` plus an explicit `permissions.allow` list.
Headless, an unallowlisted tool call cannot raise a prompt, so it is denied and recorded in `permission_denials`, which condition 3 turns into a clean halt naming what the run needed.
The loop therefore tells you what to allowlist instead of being handed everything up front.
`acceptEdits` covers file edits only, so the allowlist has to carry the `git` invocations `next-session` step 8 makes.

### The digest — the review surface

One gitignored `Work/Runs/<timestamp>-<Item>.md` per run: per-task verdict, the `main..auto/<Item>` log, files touched, the `## Hand-off` delta, and accumulated tokens and cost.

Gitignored deliberately.
It is a human review surface read once, so under the one-destination rule it must not sit on any session's read path — the same reasoning that moved rationale out of `next-session/SKILL.md` and into articles like this one.
Because it accumulates the per-task usage figures, the pipeline re-measures T1's budget on itself on every run, which is the only proposed mechanism that keeps that measurement from going stale.

## What this does not settle

- **Nothing is implemented, and none of it has run.** The loop is specified against measured harness behaviour, but the stop conditions have never fired in anger. T8's supervised trial is where the specification meets an actual item.
- **The `(human)` marker and `> Autonomous: allowed` are untested format additions.** Both are hand-writable and diff-friendly, as the Spec required, but no item carries either yet.
- **Item selection is deliberately weak.** Requiring exactly one eligible item means the pipeline cannot work a queue. Priority ordering was rejected rather than solved, because a wrong autonomous ordering is invisible until the digest and the cost of the restriction is a human typing one item name.
- **The 31,479-token figure is environment-specific.** It includes the MCP tool schemas for every server configured on this machine. A scaffolded research project with a 3.3 kB `CLAUDE.md` and fewer servers pays materially less, so the number bounds this repo, not the plugin.
- **Whether cold start is worth its price is still open.** The pipeline pays ~31.5k tokens per task to avoid context rot. That trade has been costed on one side only; what a warm session loses to rot remains unmeasured, and T1's open question about un-instrumented reading time applies here too.

## See also

- [The work item file format](ItemFileFormat.md) — T3: the five sections, and why `## Hand-off` is where this loop reads an item's state
- [Session Information Budget](SessionInformationBudget.md) — T1: the fixed preamble term this loop pays per task
- [Progress vs Wiki](ProgressWikiSplit.md) — T2: the one-destination rule the digest obeys
- `Work/Active/EvaluateWorkItemsEfficiency.md` — the item this serves
- [Status](../Status.md)
