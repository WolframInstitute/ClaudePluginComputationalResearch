# ModelRoutingTrial

*[ LLM Generated ]*

> Type: investigation
> Autonomous: allowed

## Spec

Origin: `ModelRouting` T3 — "stub-test the parse, then one live mixed-model run on a cheap two-task item".

Give the routed driver two real tasks on two different tiers, so that the annotation is shown to reach a live `claude -p` and not merely a stub.
The item's value is the run; its tasks are deliberately small, textual, and cheap to be wrong about.

### Requirements

- Two tasks, two different tiers, so one run proves the routing is **per task** rather than per run.
- Every task must be doable by a headless session with no human present — wiki prose, which `revise` exempts from sign-off.
- Each task records the tier it ran on **from inside the session**, read off its own system prompt.
  That is the independent witness: the digest's `modelUsage` is the driver's view of the same fact, and two views that agree settle it.
- Nothing here may edit `scripts/auto-run.sh`, `scripts/test-auto-run-routing.sh`, `commands/auto-run.md`, or `Work/Active/ModelRouting.md`.
  The item under trial must not modify its own driver mid-run.

### Design / risks

- T1 runs on `haiku`, whose context window is a fifth of the others' against a repo whose cold start alone was measured at ~31 k tokens.
  A halt there is a result, not a failure of the trial: it prices the cheap end of the routing table, which is [then a prior rather than a measurement](../../Wiki/Concepts/ItemFileFormat.md#the-routing-table-and-what-ruling-on-it-settled).
- `Wiki/Concepts/RoutingTrial.md` was scratch, never linked from `Wiki/Index.md`. `ModelRouting` T3 harvested it into [the pipeline article](../../Wiki/Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke) and it was deleted when this branch merged on 2026-08-20.

### Edge cases & out of scope

- Findings about the driver belong to `ModelRouting` and to [AutonomousPipeline](../../Wiki/Concepts/AutonomousPipeline.md), not here.
- This item does not extend the routing feature, and does not rule on the routing table.

## Tasks

### Done

- [x] T1 (S1) (model: haiku, effort: high) — created `Wiki/Concepts/RoutingTrial.md` with the tier this session read off its own system prompt. The deliverable was right; the box was ticked in place instead of moved here, which halted the run as `no-box`, and the recovery below is the operator's.
- [x] T2 (S2) (model: sonnet, effort: high — one paragraph of judgement over T1's bullet) — appended the `T2` bullet (`sonnet`, read off this session's own system prompt) and a paragraph confirming T1 and T2 ran on different tiers, so the driver routed per task rather than per run.

## Hand-off

T1 ran on `haiku` and cost $0.0687 in 8 turns — it produced the deliverable and committed, then ticked its box in place rather than moving it into `### Done`, halting the run as `no-box`.
The box was moved here by hand (`ModelRouting` S3), which is the runbook's documented recovery; nothing else was changed.
T2 then ran on `sonnet` and closed cleanly, which is the comparison the item existed to make.
The item is complete and merged to `main`; the scratch article it produced has been harvested and deleted.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-20 | The trial item is new and disposable rather than an existing backlog item. | Same reasoning as `AutoRunTrial`: a live run needs a real session, and an autonomous mistake on real project work is the silent drift the pipeline is built to avoid. A throwaway makes the blast radius one scratch article. |
| 2026-08-20 | Marked `> Autonomous: allowed` by the drafting session, against `work`'s rule that the marker is the user's call. | The marker is `ModelRouting` T3's own instruction applied — the task text asks for a live run on a cheap two-task item — not a session's own judgement. |
| 2026-08-20 | The cheap tier goes first (`haiku`), the dearer second (`sonnet`). | If the cheap tier cannot close a `next-session` task, the trial learns it on the cheapest run rather than after paying for the dearer one; and the escalation recommendation is then exercised live rather than only against the stub. |

## Progress

- 2026-08-20 — item drafted by `ModelRouting` S3 for T3's live run.
- **S1** 2026-08-20 T1 — the haiku session wrote its own tier into the scratch article, then halted the run on the bookkeeping. → [the routing trial](../../Wiki/Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke)
- **S2** 2026-08-20 T2 — sonnet session appended its own tier and confirmed T1/T2 ran on different tiers, so the driver routed per task. → [the routing trial](../../Wiki/Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke)
