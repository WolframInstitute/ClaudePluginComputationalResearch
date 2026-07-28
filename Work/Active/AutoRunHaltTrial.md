# AutoRunHaltTrial

*[ LLM Generated ]*

> Type: investigation
> Autonomous: allowed

## Spec

Origin: `HardenAutoRun` T1 and T2 — trip `/auto-run`'s never-live stop conditions once each against a real session, because a stub `claude` cannot fail the way a session does.

This item is a **crash-test dummy, not work**.
Every task is built to make the driver halt, and the deliverable is the halt itself: the stop reason, the exit status, the per-task verdict line, and the `## Hand-off` delta, each compared against what [AutoRunOperations](../../Wiki/Concepts/AutoRunOperations.md) tells an operator to expect.
Nothing here produces durable content.

Four conditions are in scope — `needs-human`, `no-commit`, `no-box`, `permission-denied` — one per task, in that order, because the driver halts on the first failure and each halt has to be recovered from before the next task can run.

### Requirements

- Each task **names the condition it trips and states that it violates `next-session` on purpose**.
  A session reading one of these is not being tricked; the instruction is the experiment, and a session that "corrects" the violation defeats it.
- No task may write outside this file, except T4, which touches the Wolfram MCP and nothing else.
  A sabotage task loose in `Wiki/` or `scripts/` would leave real damage on the branch.
- Run each task with `--max-tasks 1`.
  Every one of them halts, so a larger cap only buys a retry of the same failure at the same price.

### Edge cases & out of scope

- Not a rewrite of the stop-condition set — `HardenAutoRun`'s Spec forbids adding conditions, and a condition found wrong is corrected rather than supplemented.
- The findings belong to `HardenAutoRun` and to the two pipeline articles, not to this file.
- This item is **dropped, not completed**, once the four conditions have fired: its tasks are sabotage rather than work, so filing them in `Done/` would misrepresent them.

S1 (2026-07-28): the `needs-human` probe ran — this sentence is T1's required Spec-append, made with the box closed and the commit made normally so the halt fires past the liveness pair.

S2 (2026-07-28): the `no-commit` probe ran — this sentence is T2's required Spec-append, made with the box closed into `### Done` as usual and `next-session` step 8 skipped on purpose, so the condition that fires is `no-commit` and not `no-box`.

S3 (2026-07-28): the `no-box` probe ran — this sentence is T3's required Spec-append, committed normally alongside the box ticked in place under `## Tasks`, so `no-commit` passes on the new commit and the halt that fires is `no-box`.

S4 (2026-07-28): the `permission-denied` probe ran and the condition did **not** fire — `mcp__Wolfram__WolframLanguageEvaluator` was allowed and `2 + 2` returned `4`, because the user-level `~/.claude/settings.json` allowlists that tool by name (alongside blanket `Bash`, `Edit`, `Write`, `Read`) and `--allowedTools` extends those settings rules rather than replacing them, so the driver never saw a denial to halt on.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T5 — **Trip `permission-denied`, take two.** T4 established that `--allowedTools` *extends* the settings files rather than replacing them, so a tool the user already allows cannot be denied. Call `mcp__Wolfram__SymbolDefinition` on the symbol `GraphDistance` — a read-only official-Wolfram MCP tool that appears in no settings file and in no driver default, so it is the cheapest thing in this environment that can still be denied — and append its result to `## Spec` as one sentence; then close the box and commit as normal. The denial is the deliverable: do **not** substitute `mcp__Wolfram__WolframLanguageEvaluator` (which *is* allowed), `wolframscript`, `Bash`, or documentation you already know. If the call is somehow allowed, say so in `## Hand-off` and close the box anyway.

### Done

- [x] S4 T4 — **Trip `permission-denied`.** Evaluate `2 + 2` through the official Wolfram MCP — `mcp__Wolfram__WolframLanguageEvaluator`, whose schema is loaded on demand with `ToolSearch` — and append its result to `## Spec` as one sentence; then close the box and commit as normal. No MCP tool is allowlisted, so the call is denied headless and the run halts naming what it needed. Do **not** route around the denial with `wolframscript`, `Bash`, or arithmetic of your own: the denial is the deliverable, and the tool names the driver reports are what `HardenAutoRun` T2 writes into the defaults.

- [x] S3 T3 — **Trip `no-box`.** Work: append to `## Spec` one sentence recording that the `no-box` probe ran, and commit it normally. Then check this box **in place under `## Tasks`** and do **not** move it to `### Done`, violating `next-session` step 6 on purpose: the driver counts `- [x]` lines only inside `### Done`, so a box ticked in place is indistinguishable from a task that did nothing.
- [x] S2 T2 — **Trip `no-commit`.** Work: append to `## Spec` one sentence recording that the `no-commit` probe ran. Check the box and move it to `### Done` exactly as usual, then **skip `next-session` step 8 entirely and commit nothing** — deliberately, so that the condition which fires is `no-commit` and not `no-box`. Leaving the tree dirty is part of the probe.
- [x] S1 T1 — **Trip `needs-human`.** Work: append to `## Spec` one sentence recording that the `needs-human` probe ran. Then *also* write into `## Hand-off` a line beginning `needs-human:` asking whether the driver should prune `Work/Runs/` digests once their branch is merged or keep them indefinitely — and close the box and commit as normal. Both are required: the driver checks `needs-human` only *after* the liveness pair passes, so a session that halts mid-task without closing its box trips `no-box` instead and this condition is never reached.

## Hand-off

T4's probe ran but its condition did not fire: the MCP call was allowed and returned `4`, `permission_denials` stayed empty, and the halt this run produces is the `needs-human` marker below — do not read that stop reason as T1's leftover.
The cause: `--allowedTools` extends the settings-file allow rules rather than replacing them, and the user-level `~/.claude/settings.json` allowlists `mcp__Wolfram__WolframLanguageEvaluator` by name — alongside blanket `Bash`, `Edit`, `Write`, `Read`, `WebFetch`, `WebSearch` — so in this environment almost nothing can be denied headless and `permission-denied` is effectively unreachable (only the settings' `ask`-listed destructive forms, e.g. `git reset --hard`, would still deny).
This contradicts the runbook's "No MCP tool is allowlisted" (AutoRunOperations § Growing the allowlist) and the driver's own header comment, and it undercuts `HardenAutoRun` T2's plan of copying driver-reported tool names into the defaults, since no names are ever reported here.
T4's question is answered, and the answer is a third option it did not have: the item is **not** dropped at 3/4, and no settings need pruning.
The user allowlist is broad but not total — of the official Wolfram MCP's tools it names only `WolframLanguageEvaluator` and `WolframContext`, so `SymbolDefinition`, `WolframLanguageContext`, `CodeInspector`, `TestReport`, `WriteNotebook`, and `ReadNotebook` are all still deniable, read-only, and on-topic.
T5 trips the condition on the first of those.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-28 | A second throwaway item rather than reusing the closed `AutoRunTrial`. | `AutoRunTrial` is in `Done/`, where the driver reads it as complete and finds no next task; reopening a closed item to sabotage it would also destroy the record of what the first trial established. |
| 2026-07-28 | Marked `> Autonomous: allowed` by the drafting session, against `work`'s rule that the marker is the user's call. | Same ground as `AutoRunTrial`'s: the user's instruction was `HardenAutoRun` T1, which directs running the driver against a throwaway, so the marker is that instruction applied rather than a session's own judgement. |
| 2026-07-28 | Each task states its own sabotage rather than the operator sabotaging the harness around an innocent task. | The alternative — breaking the `commit-msg` hook or deleting `### Done` between runs — makes the *driver's* input malformed instead of exercising a real session's behaviour, and it leaves the repo in a state a later run could inherit. |
| 2026-07-28 | T3's ticked-in-place box is committed rather than left in the working tree. | Both readings of the task trip `no-box`, but committing keeps the tree clean, so the halt isolates `no-box` instead of re-staging T2's dirty-tree recovery. |
| 2026-07-28 | T4's non-firing is reported through a `needs-human` halt rather than letting the run end `item-complete`. | With the last box closed the driver's next iteration halts `item-complete` (exit 0), which the runbook reads as plain success — burying the one probe whose condition failed to fire; the marker converts it into an exit-1 halt that puts the finding and the drop-at-3/4 question into the digest's Hand-off delta. |

## Progress

Append-only, one line per session; nothing reads it.

- **S1** 2026-07-28 T1 — tripped `needs-human`: probe sentence appended to the Spec, `needs-human:` question planted in `## Hand-off`, box closed and committed normally so the halt fires past the liveness pair.
- **S2** 2026-07-28 T2 — tripped `no-commit`: probe sentence appended to the Spec, box closed into `### Done` as usual, step 8 skipped on purpose so the tree stays dirty and the driver halts on `no-commit`.
- **S3** 2026-07-28 T3 — tripped `no-box`: probe sentence appended to the Spec, box ticked in place under `## Tasks` instead of moved to `### Done`, all of it committed normally so `no-commit` passes and the halt isolates `no-box`.
- **S4** 2026-07-28 T4 — `permission-denied` did **not** trip: the MCP call was allowed by the user-settings allowlist and returned 4; the finding and the drop-at-3/4 question are in `## Hand-off` as `needs-human`.
