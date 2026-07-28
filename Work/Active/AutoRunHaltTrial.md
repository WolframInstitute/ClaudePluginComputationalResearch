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

## Tasks

One unchecked box ≈ one focused session.

- [x] T3 — **Trip `no-box`.** Work: append to `## Spec` one sentence recording that the `no-box` probe ran, and commit it normally. Then check this box **in place under `## Tasks`** and do **not** move it to `### Done`, violating `next-session` step 6 on purpose: the driver counts `- [x]` lines only inside `### Done`, so a box ticked in place is indistinguishable from a task that did nothing.
- [ ] T4 — **Trip `permission-denied`.** Evaluate `2 + 2` through the official Wolfram MCP — `mcp__Wolfram__WolframLanguageEvaluator`, whose schema is loaded on demand with `ToolSearch` — and append its result to `## Spec` as one sentence; then close the box and commit as normal. No MCP tool is allowlisted, so the call is denied headless and the run halts naming what it needed. Do **not** route around the denial with `wolframscript`, `Bash`, or arithmetic of your own: the denial is the deliverable, and the tool names the driver reports are what `HardenAutoRun` T2 writes into the defaults.

### Done

- [x] S2 T2 — **Trip `no-commit`.** Work: append to `## Spec` one sentence recording that the `no-commit` probe ran. Check the box and move it to `### Done` exactly as usual, then **skip `next-session` step 8 entirely and commit nothing** — deliberately, so that the condition which fires is `no-commit` and not `no-box`. Leaving the tree dirty is part of the probe.
- [x] S1 T1 — **Trip `needs-human`.** Work: append to `## Spec` one sentence recording that the `needs-human` probe ran. Then *also* write into `## Hand-off` a line beginning `needs-human:` asking whether the driver should prune `Work/Runs/` digests once their branch is merged or keep them indefinitely — and close the box and commit as normal. Both are required: the driver checks `needs-human` only *after* the liveness pair passes, so a session that halts mid-task without closing its box trips `no-box` instead and this condition is never reached.

## Hand-off

T3 leaves its box ticked in place under `## Tasks` on purpose — the tree is clean and the Spec-append commit exists, so the operator recovery is moving that one line into `### Done` with its session number (S3), nothing more.
Once the box is relocated, T4 needs no other setup.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-28 | A second throwaway item rather than reusing the closed `AutoRunTrial`. | `AutoRunTrial` is in `Done/`, where the driver reads it as complete and finds no next task; reopening a closed item to sabotage it would also destroy the record of what the first trial established. |
| 2026-07-28 | Marked `> Autonomous: allowed` by the drafting session, against `work`'s rule that the marker is the user's call. | Same ground as `AutoRunTrial`'s: the user's instruction was `HardenAutoRun` T1, which directs running the driver against a throwaway, so the marker is that instruction applied rather than a session's own judgement. |
| 2026-07-28 | Each task states its own sabotage rather than the operator sabotaging the harness around an innocent task. | The alternative — breaking the `commit-msg` hook or deleting `### Done` between runs — makes the *driver's* input malformed instead of exercising a real session's behaviour, and it leaves the repo in a state a later run could inherit. |
| 2026-07-28 | T3's ticked-in-place box is committed rather than left in the working tree. | Both readings of the task trip `no-box`, but committing keeps the tree clean, so the halt isolates `no-box` instead of re-staging T2's dirty-tree recovery. |

## Progress

Append-only, one line per session; nothing reads it.

- **S1** 2026-07-28 T1 — tripped `needs-human`: probe sentence appended to the Spec, `needs-human:` question planted in `## Hand-off`, box closed and committed normally so the halt fires past the liveness pair.
- **S2** 2026-07-28 T2 — tripped `no-commit`: probe sentence appended to the Spec, box closed into `### Done` as usual, step 8 skipped on purpose so the tree stays dirty and the driver halts on `no-commit`.
- **S3** 2026-07-28 T3 — tripped `no-box`: probe sentence appended to the Spec, box ticked in place under `## Tasks` instead of moved to `### Done`, all of it committed normally so `no-commit` passes and the halt isolates `no-box`.
