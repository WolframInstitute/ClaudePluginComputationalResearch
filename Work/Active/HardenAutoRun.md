# HardenAutoRun

*[ LLM Generated ]*

> Type: refactor

## Spec

Origin: the closing hand-off of `EvaluateWorkItemsEfficiency` (2026-07-28), which named two things about `/auto-run` that were still open when that item closed and had nowhere else to live.

`scripts/auto-run.sh` works — T8 landed two real tasks unattended and fixed three defects found live.
What it has never done is **fail**. The trial deliberately ran prose tasks that could not trip a stop condition, so three of the eight fail-closed paths have only ever fired against a stub `claude` in a fixture repo, and a stub cannot fail the way a session does.
Separately, the default allowlist contains no MCP tool, so the first autonomous task that touches Wolfram halts on its first call — predicted, never observed.

This item closes both gaps. It is maintenance on a working pipeline, not a redesign; do not re-open the design decisions in [AutonomousPipeline](../../Wiki/Concepts/AutonomousPipeline.md).

### Requirements

- **Trip each untested stop condition live, once.** `needs-human`, the liveness pair, and `permission-denied`. The cheapest route is a throwaway item whose tasks are *designed* to fail — the same shape as `AutoRunTrial`, which is the precedent for how to do this without risking real work.
- **Establish what the allowlist has to contain for a Wolfram task**, by running one and reading the denial rather than by predicting it. The trial's allowlist prediction was wrong in a useful direction (zero denials on prose), so predict nothing here.
- Record what each live failure actually looked like against what the runbook says it looks like — the same reconciliation that found five divergences when [AutoRunOperations](../../Wiki/Concepts/AutoRunOperations.md) was written against the script.

### Edge cases & out of scope

- Do not trial on an item that owns the driver, and do not trial on real work: use a throwaway.
- Not a rewrite of the stop-condition set. If a condition turns out wrong, correct it — do not add more.
- Cost: a live run is ~31.5 k tokens of preamble plus the task, and the `$5.00` cap is what actually bounds a run. Budget accordingly.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T1 — Create a throwaway item with tasks designed to trip `needs-human` and the liveness pair; run `/auto-run` against it and record what each halt actually looked like.
- [ ] T2 — Run one Wolfram-touching task unattended, read the `permission-denied` halt, and write the resulting MCP allowlist into the driver's defaults.

### Done

## Hand-off

Nothing yet — the Spec is the whole context.
Both remaining facts a session needs are linked from it: the stop-condition table in [AutonomousPipeline](../../Wiki/Concepts/AutonomousPipeline.md) and the per-stop-reason instructions in [AutoRunOperations](../../Wiki/Concepts/AutoRunOperations.md).

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-28 | Filed as a separate backlog item rather than kept as tasks on `EvaluateWorkItemsEfficiency`. | That item's question — is the work-item system efficient, and can it run unattended — is answered; this is maintenance on the artifact it produced, and folding it back in would keep an answered investigation open indefinitely. |

## Progress

- **S0** 2026-07-28 — filed from `EvaluateWorkItemsEfficiency`'s closing hand-off; no work done.
