# The autonomous next-session pipeline

*[ LLM Generated ]*

The specification for running `Work/` items unattended: what drives the loop, how an item is selected with no human present, when the loop stops, and what happens to the `revise` gate.
Decided 2026-07-27 for `EvaluateWorkItemsEfficiency` T4, against [T3's item format](ItemFileFormat.md) and [T1's budget](SessionInformationBudget.md).
Built 2026-07-28 by T7 — see [Implementation](#implementation) for where each part lives.
First run against a real item on 2026-07-28 under T8's [supervised trial](#the-supervised-trial--what-two-real-runs-cost-and-changed), which exercised only the happy path; the four failure conditions were tripped live later the same day by `HardenAutoRun`'s [failure trial](#the-failure-trial--what-four-live-halts-cost-and-changed), and [what this does not settle](#what-this-does-not-settle) records what is left.
Where this article and `scripts/auto-run.sh` disagree the script is the fact, and this article is corrected to match it — last reconciled 2026-07-28 against the script as of `HardenAutoRun` T2's allowlist change.

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

**Two argument-shape traps that break the driver silently or fatally** (found in T7, by running it):

- `--allowedTools` is **variadic**, so it consumes every positional after it — including the prompt, even when the tool list is passed as one comma-separated argument. The run then dies with `Input must be provided either through stdin or as a prompt argument`. The prompt must come **before** the flags: `claude -p "<prompt>" --output-format json …`.
- A clean run reports `terminal_reason: "completed"`, not `"end_turn"` (`stop_reason` *is* `end_turn`). A driver that checks both fields against the same value halts on every success.

### T6's cut barely moved this number

Re-measured after the preamble split, on the same shape of trivial prompt: **31,187 input tokens** — 13,882 cache-creation plus 17,305 cache-read, against 31,479 before.
Removing 11.6 kB of `CLAUDE.md` moved the cold-start cost by about 1 %.
That confirms the caveat this article already carried: the figure is dominated by the MCP tool schemas for every server configured on this machine, not by the plugin's own preamble.
It does not retract [T6](PreambleAudit.md), which measured bytes on a real read path and was right on its own terms — but it does settle where the pipeline's per-task floor actually comes from, and the lever is the MCP server set, not `CLAUDE.md`.

### The consequence for sequencing

The pipeline's dominant cost line is the fixed preamble, not the item file.
So T6 — auditing this repo's 16.6 kB `CLAUDE.md` against `README.md` for duplicated tables — is not a cleanup item that can follow the pipeline.
It is the term that decides whether the pipeline is affordable, and it belongs **before** T7.
That audit has since run — [Preamble audit](PreambleAudit.md) — and cut the bookkeeping half of the preamble from 27.9 kB to 16.3 kB, with the inventory moved to a read-on-demand `ARCHITECTURE.md`.
The 31,479-token figure above predates it and is not re-measured; the caveat below still applies, since most of that number is MCP tool schemas rather than `CLAUDE.md`.

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

Glob `Work/Active/*.md` — the folder, not `Work/README.md`.
The folder is the item's status, so it is also the only thing selection may trust: the index is a human's reading surface and is allowed to lag, and an item absent from it is still eligible.
An item is eligible only if it carries `> Autonomous: allowed` as a header line beside `> Type:`; absent means no.
A task line containing `(human)` anywhere is a hard stop, so an author can gate individual tasks — T4 itself, which had to be presented for approval, is exactly that case.
The marker is matched as a substring rather than at end of line, so it still gates a task whose line ends in a trailing note.
If zero or more than one eligible active item exists, the driver stops and reports.
It never picks a favourite, because an unattended wrong choice is not observable until the digest.

The header line is one more `>` line above `## Spec`, so it neither adds a section nor breaks the closed section list.

### Per task

One `claude -p --output-format json "/computational-research:next-session <Item>"`, then the driver **verifies the run instead of trusting it**.

The tier that process runs on comes from the task's own [routing annotation](ItemFileFormat.md#the-per-task-routing-annotation), read off the task line the loop already selected and passed through as `--model` and `--effort`; an unannotated task inherits the machine default, which is [whatever the operator last typed at `/model`](HeadlessModelSurface.md#--model-takes-aliases-and-all-four-tiers-resolve).
The driver holds no routing policy of its own and has no model flag — the item file is the contract, so the price of a task is decided where the work was divided rather than at launch.

**The parse validates the effort and not the model, and the asymmetry is measured rather than stylistic.**
An unrecognised model exits 1 with `is_error` at zero cost and trips condition 3 for free; an unrecognised effort *succeeds* at the default effort and warns only on a stderr stream the driver captures but never reads for warnings.
So a bad effort would otherwise produce a clean, committed, successful task that silently ran at the wrong tier of thinking — the parser checks the five levels itself, before spawning, and halts as `bad-annotation` having spent nothing.
The same halt catches an unrecognised *field*: a group that carries a `key:` at all must parse completely, so `(modle: sonnet)` stops the run rather than inheriting the default, while a group with no field in it — `(human)`, `(S2)` — is not an annotation and passes through untouched.

Two things the digest can then say per task, and one it cannot.
It names the **model used**, taken from `.modelUsage` by [the cache-token discriminator](HeadlessModelSurface.md#the-modelusage-trap-almost-every-run-reports-a-second-model) rather than from its keys, since an auxiliary haiku call rides along on nearly every run and is frequently `keys[0]`.
It names the effort **requested**, because no output field reports the effort applied.
And on a halt where the session ran and closed nothing, it names the **escalation** — the annotation to raise the task to before re-running it — so that the human's one decision is yes/no rather than diagnosis.
A cheap tier fails by producing confident wrong output, which a re-run at the same tier repeats rather than exposes.

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

The caps of condition 6 are checked **before** the `(human)` gate, and the order is load-bearing rather than arbitrary.
Both can hold at once, and then the cap is the honest reason the loop stopped: the gated task was never going to run this time.
Gate-first reported `task-gated` — exit `1`, meaning *you are needed* — for a run that had merely finished its allotment.

### Failure mid-task — the driver never cleans up

It records `HEAD` before each task and, on failure, leaves the tree exactly as it stands and stops.
An unattended `git reset --hard` is the one action that can destroy work no human has ever seen, so recovery is a human's call.

### Permissions — `acceptEdits`, not `bypassPermissions`

`--permission-mode acceptEdits` plus an explicit `--allowedTools` list.
Headless, a tool call that is not allowed cannot raise a prompt, so it is denied and recorded in `permission_denials`, which condition 3 turns into a clean halt naming what the run needed.
`acceptEdits` covers file edits only, so the list has to carry the `git` invocations `next-session` step 8 makes.

**The design intent that the loop "tells you what to allowlist instead of being handed everything up front" does not survive contact with a real settings file**, and this is the one place the specification was wrong rather than merely incomplete.
`--allowedTools` is **added** to the settings files' `permissions.allow` rather than replacing it, so the driver's list is a floor and not a ceiling: it guarantees a minimum and bounds nothing.
Measured on this machine (`HardenAutoRun` T2, 2026-07-28), the user-level allowlist carries 248 entries including blanket `Bash`, `Edit`, `Write`, `Read`, `NotebookEdit`, `WebFetch`, and `WebSearch`, so almost no call a session makes is deniable and `permission-denied` is nearly unreachable.
Only a tool absent from every settings file can be denied — which is how the condition was eventually tripped, on `mcp__Wolfram__SymbolDefinition`.

Two things follow.
The defaults must **carry** what a class of task needs rather than wait to be told, so the seven official Wolfram MCP tools and `Bash(wolframscript:*)` are now in them.
And the allowlist is not what makes an unattended run safe: with blanket `Bash` allowed, the effective bound is the settings' `ask` list, which headless cannot prompt and therefore denies.
The `auto/<Item>` branch plus the human merge is the real containment, and it is load-bearing in a way this section previously implied it was not.
Operating detail is in [the runbook](AutoRunOperations.md#--allowedtools-is-a-floor-not-a-ceiling).

### The digest — the review surface

One gitignored `Work/Runs/<timestamp>-<Item>.md` per run: per-task verdict, the commit log, files touched, the `## Hand-off` delta, and accumulated tokens and cost.
The log range is `HEAD`-at-launch to `HEAD`, not `main..auto/<Item>`, so launching from `main` against a branch that already carries unmerged commits lists all of them rather than this run's.

Gitignored deliberately.
It is a human review surface read once, so under the one-destination rule it must not sit on any session's read path — the same reasoning that moved rationale out of `next-session/SKILL.md` and into articles like this one.
Because it accumulates the per-task usage figures, the pipeline re-measures T1's budget on itself on every run, which is the only proposed mechanism that keeps that measurement from going stale.

## Implementation

Built by T7, 2026-07-28.

| the spec's | is |
|---|---|
| driver | `scripts/auto-run.sh` — bash, needs `claude` and `jq` |
| its command | `commands/auto-run.md` — passes arguments through, then reads the digest and reports the stop reason |
| the deferred gate | `revise` § *Autonomous mode*, which `next-session` already reads every session |
| eligibility markers | documented in `work` § *The autonomy markers*, seeded as comments in `work_item_template.md` |
| unconditional commit | one clause in `next-session` step 8 — the liveness check is only sound if an autonomous run always commits |
| the autonomy signal | `--append-system-prompt`, naming the driver, the branch, and the item — see the third fact below |
| per-task routing | `parse_routing` in the same script, from the annotation `work` writes and `next-session` checks; `scripts/test-auto-run-routing.sh` is its regression test, run by hand and spending nothing |

### Stop reasons

The driver names the reason in the digest and on stderr, and its exit status is four-valued, not two:
`0` for a clean stop, `1` for any other halt, `130` for an interrupt, and `2` for a preflight failure.
The preflight group — a missing `claude` or `jq`, no git repository, no `Work/`, a tree already dirty at launch, an unknown option, or a named item that is not active or not marked eligible — is the one group that writes **no digest**, because it fails before the branch and the digest exist.

| reason | meaning |
|---|---|
| `item-complete` | no unchecked task remains — condition 1, the success exit |
| `cap-tasks` / `cap-wallclock` / `cap-cost` | a backstop from condition 6 |
| `needs-human` | condition 2 — the run wrote a question into `## Hand-off` rather than guessing |
| `task-gated` | the next task line carries `(human)` |
| `dirty-tree` | condition 4 — someone is mid-edit |
| `no-commit` / `no-box` | condition 5, liveness — the run reported success and closed nothing |
| `nonzero-exit` / `is-error` / `stop-reason` / `terminal-reason` / `permission-denied` | condition 3 |
| `bad-annotation` | the next task's routing annotation names an effort outside `low\|medium\|high\|xhigh\|max`, or a field that is neither `model:` nor `effort:` — checked before the spawn, so it costs nothing |
| `unparseable-output` | the run's stdout was not JSON; the digest quotes the first 1 kB of stdout and the first 1 kB of stderr |
| `item-vanished` | the item file is in neither `Work/Active/<Item>.md` nor `Work/Done/*-<Item>.md` — a session moved or renamed it, and the loop can no longer read its state |
| `interrupted` | `SIGINT` or `SIGTERM`; the digest is still written and the tree is left exactly as it stands |

Three implementation facts the specification did not anticipate:

**The digest and the dirty-tree condition collide.**
Writing `Work/Runs/<run>.md` makes the tree dirty, so the *second* task of every run would halt on condition 4 in any repo that has not gitignored the digest.
The driver excludes the path from its own check (`git status --porcelain -- . ':(exclude)Work/Runs/'`) rather than depending on a `.gitignore` it does not control, so it is correct in a scaffolded project too.
The rule is still in this repo's `.gitignore` and in `gitignore_dev.template`, because a digest that shows up in `git status` is noise for the human.

**Token accounting must read `.usage` alone, and must sum its four fields.**
The run JSON also carries `modelUsage`, which repeats the same counts keyed by model, so a recursive sum double-counts every figure the pipeline reports about itself.
And `.usage.input_tokens` is only the *uncached remainder*: the first real task reported 30 there against a true input of about 1.01 M, essentially all of it cache reads.
A digest that prints that field alone understates the pipeline's own price by four orders of magnitude, so the driver reports the total first and the breakdown after.

**A headless session cannot observe that it is headless.**
The first live run did its task correctly but recorded in `## Hand-off` that it had run as an interactive `/next-session`.
`revise` had asked the session to infer autonomous mode from the absence of a user, and absence is exactly what is not observable from inside a session — a session with no user looks identical to one whose user has not spoken yet.
So the driver states it, in `--append-system-prompt` rather than in the prompt, where it cannot be mistaken for an argument to the slash command; `revise` now says the notice is the only admissible evidence.
This is a general hazard for unattended work, not a bug in one skill: any instruction of the form *behave differently when nobody is watching* has to be told, never inferred.

### The supervised trial — what two real runs cost and changed

`EvaluateWorkItemsEfficiency` T8, 2026-07-28, against the throwaway item `AutoRunTrial`.
The parent item's hand-off forbade trialling on the item that owns the driver, since a driver bug would then work its own source.

| | run 1 (T1) | run 2 (T3) |
|---|---|---|
| stop reason | `task-gated` → after the fix, `cap-tasks` | `cap-tasks`, exit 0 |
| turns / wall clock | 26 / 4 min | 42 / 5.5 min |
| cost | $1.54 | $2.60 |
| input tokens | 1.01 M (30 uncached) | 2.68 M (68 uncached) |
| `permission_denials` | 0 | 0 |

Both runs closed their task, committed, and were verified by the liveness check; neither needed an `--allow` addition.
Run 1 exposed three defects — the autonomy signal, the cap/gate ordering, and the token line — all fixed in `05cdc45`, and run 2 confirmed each fix live.
The eight fail-closed and preflight paths were re-checked directly against this repo rather than a fixture: no eligible item, an item without the marker, an absent item, a modified tracked file, an untracked file, a written digest (correctly *not* dirty), the gate after the reordering, and both cap exits.

Two things the trial priced that the specification had guessed at.
**The per-task cost is set by turn count, not by cold start**: 26 turns cost $1.54 against a 31.5 k-token preamble, so the preamble is roughly 3 % of a real task's input and optimising it — T6's work — cannot move the pipeline's economics.
**The default caps are mismatched**: at $1.5–2.6 per task, `--max-cost 5.00` stops a run after two or three tasks, so the cost cap and not `--max-tasks 3` is the binding constraint on a default run.

The trial item closed on 2026-07-28 with its `(human)` task done interactively — the gate's designed exit, and the reason the item's terminal state under the driver is an immediate `task-gated` halt that spends nothing.
That last task also showed how a trial item can be drafted stale: it asked whether `/auto-run` belonged in `README.md`'s command list, and the task that built the driver had added the row sixteen minutes before the trial item existed.
A throwaway written to exercise the driver will tend to overlap the driver's own documentation, so its tasks are worth re-reading against `HEAD` at the start of the session rather than trusted as drafted.

### The failure trial — what four live halts cost and changed

`HardenAutoRun` T1 and T2, 2026-07-28, against the throwaway `AutoRunHaltTrial`.
The supervised trial above had run only tasks that *could not* fail, so four conditions had fired against a stub `claude` and nothing else.
Each task on the dummy carried its own sabotage instruction in its own text, rather than the operator breaking the harness around an innocent task — a malformed input tests the driver's parsing, not a session's behaviour.

| condition | task | stop reason | cost | turns |
|---|---|---|---|---|
| `needs-human` | T1 | `needs-human`, exit 1 | $2.03 | 16 |
| `no-commit` | T2 | `no-commit`, exit 1 | $1.71 | 16 |
| `no-box` | T3 | `no-box`, exit 1 | $1.77 | 16 |
| `permission-denied` | T4 | *did not fire* — `needs-human`, exit 1 | $4.09 | 21 |
| `permission-denied` | T5 | `permission-denied`, exit 1 | $3.00 | 21 |

All five reported `subtype: success`, confirming that the CLI's own verdict carries no information about whether the session did its job — the premise of condition 5.
Five tasks cost $12.60, against the trial's $1.54 and $2.60, so a failing task is no cheaper than a succeeding one: the driver halts *after* the process finishes, never during it.

Three findings, in ascending order of consequence.

**`no-commit` and `no-box` cannot be provoked by a well-behaved session.** Both had to be instructed explicitly, which locates what they actually guard: harness faults and malformed item files — a rejected `commit-msg` hook, a box ticked outside `### Done` — rather than misjudgement. That is a narrower remit than "liveness" suggests, and it is the right one.

**`needs-human` is reachable only from a session that closed its box.** The driver checks it *after* the liveness pair, so a session that follows `revise` literally — write the question, commit, stop — fails liveness first and halts as `no-box`. The reason is therefore honest for a task that finished and raised a follow-on question, and misleading for a task that genuinely could not proceed. The conditions were not reordered: `revise`'s instruction is what makes the ordering visible, and the runbook now says to read the `## Hand-off` delta on a `no-box` halt before believing it.

**The allowlist bounds nothing** — see [Permissions](#permissions--acceptedits-not-bypasspermissions) above. T4's failure to fire is the single most useful result of the whole item: the condition ran clean because `--allowedTools` extends the settings files instead of replacing them, so the supervised trial's "zero denials" had measured the settings' permissiveness and not the task's needs.

That last one also demonstrated the deferred gate working as designed.
T4 could not resolve its own situation, wrote a `needs-human:` question naming the two options it could see, and halted — and the operator answered with a third the session had not: trip the condition on an official-Wolfram MCP tool the settings do not name, needing neither a settings change nor a destructive command.

## What this does not settle

- **All four failure conditions have now fired live** — see [the failure trial](#the-failure-trial--what-four-live-halts-cost-and-changed). What remains stub-tested is the *harness*-fault group: `unparseable-output` and the three `condition 3` reasons (`nonzero-exit`, `is-error`, `stop-reason`/`terminal-reason`). Those fire on a CLI-level failure — a rejected flag, an expired login — rather than on anything a session does, so a stub is a closer model of them than it was of the four above, and provoking them live would mean breaking the CLI rather than the work.
- **Nothing but wiki prose has run unattended.** The trial item was chosen to be cheap to be wrong about, so the pipeline is unproven on the tasks it exists to serve: code, notebooks, proofs — anything whose deliverable `revise` does not exempt from sign-off.
- **The `(human)` marker and `> Autonomous: allowed` both work.** `AutoRunTrial` carries them; selection accepted the item and the gate halted on the marked task, as specified.
- **Nothing has yet run unattended that needed a tool the environment did not already allow.** The defaults now carry the Wolfram MCP set, but that was written from `CLAUDE.md`'s policy rather than from a run demanding it, because in this environment a run cannot demand it. Whether the set is *sufficient* for a real notebook or paclet task is unmeasured, and no halt will tell you here — only a narrow settings file elsewhere would.
- **Whether the driver should isolate itself from the user's settings is open.** Passing a minimal `--settings` file, or otherwise refusing to inherit 248 blanket allow rules, would make `--allowedTools` mean what this specification originally claimed. It would also be a change in the pipeline's security posture rather than a correction, so `HardenAutoRun` left it alone: its Spec forbade redesign, and the branch-plus-merge gate is doing the containment meanwhile.
- **Item selection is deliberately weak.** Requiring exactly one eligible item means the pipeline cannot work a queue. Priority ordering was rejected rather than solved, because a wrong autonomous ordering is invisible until the digest and the cost of the restriction is a human typing one item name.
- **The 31,479-token figure is environment-specific.** It includes the MCP tool schemas for every server configured on this machine. A scaffolded research project with a 3.3 kB `CLAUDE.md` and fewer servers pays materially less, so the number bounds this repo, not the plugin.
- **Whether cold start is worth its price is still open, and the price is larger than the floor suggests.** The ~31.5k figure is the preamble paid once per task; the first real task's *total* input was about 1.01 M tokens over 26 turns — almost entirely cache reads — for $1.54. Cold start is a small term inside a real session, not the dominant one, which weakens the case for optimising it and leaves the actual comparison untouched: what a warm session loses to rot remains unmeasured, and T1's open question about un-instrumented reading time applies here too.

## See also

- [The `/auto-run` operator runbook](AutoRunOperations.md) — the operating half of this article: what to do when a run halts, how to read a digest, and how a branch reaches `main`
- [The headless model and effort surface](HeadlessModelSurface.md) — `--model` and `--effort` on `claude -p`, measured on 2.1.235: which aliases resolve, which bad values halt, and why `modelUsage` names a model the task did not run on
- [The work item file format](ItemFileFormat.md) — T3: the five sections, and why `## Hand-off` is where this loop reads an item's state
- [Session Information Budget](SessionInformationBudget.md) — T1: the fixed preamble term this loop pays per task
- [Progress vs Wiki](ProgressWikiSplit.md) — T2: the one-destination rule the digest obeys
- `Work/Done/2026-07-28-EvaluateWorkItemsEfficiency.md` — the item this serves
- [The Claude Code hook contract](HookContract.md) — another harness behavior that had to be verified live rather than assumed
- [Status](../Status.md)
