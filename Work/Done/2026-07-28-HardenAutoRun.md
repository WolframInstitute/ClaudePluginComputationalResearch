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

*None — both tasks are done and the item is complete.*

### Done

- [x] S2 T2 — Run one Wolfram-touching task unattended, read the `permission-denied` halt, and write the resulting MCP allowlist into the driver's defaults.
- [x] S1 T1 — Create a throwaway item with tasks designed to trip `needs-human` and the liveness pair; run `/auto-run` against it and record what each halt actually looked like.

## Hand-off

Complete — nothing carries forward.
The evidence is in [AutonomousPipeline § The failure trial](../../Wiki/Concepts/AutonomousPipeline.md#the-failure-trial--what-four-live-halts-cost-and-changed) and [AutoRunOperations § What the four failure halts actually look like](../../Wiki/Concepts/AutoRunOperations.md#what-the-four-failure-halts-actually-look-like); the driver's new defaults are in `scripts/auto-run.sh`.

One question the item deliberately did not answer, recorded in that article's *What this does not settle*: whether the driver should stop inheriting the user's 248 blanket allow rules — by passing a minimal `--settings` file or equivalent — so that `--allowedTools` bounds a run rather than merely floors it.
That is a change of security posture, not a correction, and this Spec forbade redesign.
It is the obvious next backlog item if the author wants one.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-28 | Filed as a separate backlog item rather than kept as tasks on `EvaluateWorkItemsEfficiency`. | That item's question — is the work-item system efficient, and can it run unattended — is answered; this is maintenance on the artifact it produced, and folding it back in would keep an answered investigation open indefinitely. |
| 2026-07-28 (S1) | Each task on the throwaway states its own sabotage, rather than the operator breaking the harness around an innocent task. | Deleting `### Done` or disabling the `commit-msg` hook between runs would test the driver's tolerance of malformed input, not a real session's behaviour — and it leaves the repo in a state a later run can inherit. |
| 2026-07-28 (S2) | The stop-condition ordering that makes `needs-human` reachable only after liveness passes was documented, not changed. | The Spec forbids adding conditions and directs correcting a wrong one; the ordering is not wrong — it is `revise`'s "write the question and stop" that collides with it, and the honest fix is telling the operator to read the `## Hand-off` delta on a `no-box` halt. |
| 2026-07-28 (S2) | The Wolfram MCP defaults were written from `CLAUDE.md`'s MCP-first policy rather than from what the run reported denied. | T4 established that a run in this environment cannot report what it needs, so the Spec's "predict nothing, read the denial" instruction had no denial to read; the policy list is the only non-guess available, and the gap is recorded rather than papered over. |
| 2026-07-28 (S2) | Isolating the driver from the user's settings was left undone. | It would make `--allowedTools` bound a run as originally specified, but that is a change in security posture rather than a correction of one, and this Spec's scope is maintenance. |

## Progress

- **S0** 2026-07-28 — filed from `EvaluateWorkItemsEfficiency`'s closing hand-off; no work done.
- **S1** 2026-07-28 T1 — tripped `needs-human`, `no-commit`, and `no-box` live against the throwaway `AutoRunHaltTrial` (now in `Dropped/`), and reconciled all three against the runbook. → [AutonomousPipeline § The failure trial](../../Wiki/Concepts/AutonomousPipeline.md#the-failure-trial--what-four-live-halts-cost-and-changed), [AutoRunOperations](../../Wiki/Concepts/AutoRunOperations.md#what-the-four-failure-halts-actually-look-like)
- **S2** 2026-07-28 T2 — found `permission-denied` nearly unreachable because `--allowedTools` extends the settings files instead of replacing them, tripped it on a tool the settings do not name, and gave the driver the Wolfram MCP defaults. → [AutoRunOperations § `--allowedTools` is a floor, not a ceiling](../../Wiki/Concepts/AutoRunOperations.md#--allowedtools-is-a-floor-not-a-ceiling), [AutonomousPipeline § Permissions](../../Wiki/Concepts/AutonomousPipeline.md#permissions--acceptedits-not-bypasspermissions), `scripts/auto-run.sh`
