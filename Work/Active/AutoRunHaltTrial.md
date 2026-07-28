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

## Tasks

One unchecked box ≈ one focused session.

- [ ] T1 — **Trip `needs-human`.** Work: append to `## Spec` one sentence recording that the `needs-human` probe ran. Then *also* write into `## Hand-off` a line beginning `needs-human:` asking whether the driver should prune `Work/Runs/` digests once their branch is merged or keep them indefinitely — and close the box and commit as normal. Both are required: the driver checks `needs-human` only *after* the liveness pair passes, so a session that halts mid-task without closing its box trips `no-box` instead and this condition is never reached.
- [ ] T2 — **Trip `no-commit`.** Work: append to `## Spec` one sentence recording that the `no-commit` probe ran. Check the box and move it to `### Done` exactly as usual, then **skip `next-session` step 8 entirely and commit nothing** — deliberately, so that the condition which fires is `no-commit` and not `no-box`. Leaving the tree dirty is part of the probe.
- [ ] T3 — **Trip `no-box`.** Work: append to `## Spec` one sentence recording that the `no-box` probe ran, and commit it normally. Then check this box **in place under `## Tasks`** and do **not** move it to `### Done`, violating `next-session` step 6 on purpose: the driver counts `- [x]` lines only inside `### Done`, so a box ticked in place is indistinguishable from a task that did nothing.
- [ ] T4 — **Trip `permission-denied`.** Evaluate `2 + 2` through the official Wolfram MCP — `mcp__Wolfram__WolframLanguageEvaluator`, whose schema is loaded on demand with `ToolSearch` — and append its result to `## Spec` as one sentence; then close the box and commit as normal. No MCP tool is allowlisted, so the call is denied headless and the run halts naming what it needed. Do **not** route around the denial with `wolframscript`, `Bash`, or arithmetic of your own: the denial is the deliverable, and the tool names the driver reports are what `HardenAutoRun` T2 writes into the defaults.

### Done

## Hand-off

Nothing yet.
Each task carries its own sabotage instruction, and the recovery an operator performs between tasks is `HardenAutoRun`'s to record, not this file's.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-28 | A second throwaway item rather than reusing the closed `AutoRunTrial`. | `AutoRunTrial` is in `Done/`, where the driver reads it as complete and finds no next task; reopening a closed item to sabotage it would also destroy the record of what the first trial established. |
| 2026-07-28 | Marked `> Autonomous: allowed` by the drafting session, against `work`'s rule that the marker is the user's call. | Same ground as `AutoRunTrial`'s: the user's instruction was `HardenAutoRun` T1, which directs running the driver against a throwaway, so the marker is that instruction applied rather than a session's own judgement. |
| 2026-07-28 | Each task states its own sabotage rather than the operator sabotaging the harness around an innocent task. | The alternative — breaking the `commit-msg` hook or deleting `### Done` between runs — makes the *driver's* input malformed instead of exercising a real session's behaviour, and it leaves the repo in a state a later run could inherit. |

## Progress

Append-only, one line per session; nothing reads it.
