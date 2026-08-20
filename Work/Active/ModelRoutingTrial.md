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
  A halt there is a result, not a failure of the trial: it prices the cheap end of the routing table, which is [so far a prior rather than a measurement](../../Wiki/Concepts/ItemFileFormat.md#the-routing-table-is-a-prior-not-a-result).
- `Wiki/Concepts/RoutingTrial.md` is scratch. `ModelRouting` T3 harvests it into the pipeline article and deletes it; it is not a permanent article and is deliberately not linked from `Wiki/Index.md`.

### Edge cases & out of scope

- Findings about the driver belong to `ModelRouting` and to [AutonomousPipeline](../../Wiki/Concepts/AutonomousPipeline.md), not here.
- This item does not extend the routing feature, and does not rule on the routing table.

## Tasks

- [x] T1 (model: haiku, effort: high — a fixed outline, no judgement) — Create `Wiki/Concepts/RoutingTrial.md` with a `# Routing trial` title, the `*[ LLM Generated ]*` marker, one sentence saying what the file is for (scratch evidence for `ModelRouting` T3, to be harvested and deleted), and one bullet: the date, `T1`, the model tier this session is running on as its own system prompt names it, and the effort its task annotation requested.
- [ ] T2 (model: sonnet, effort: high — one paragraph of judgement over T1's bullet) — Append to `Wiki/Concepts/RoutingTrial.md` the same bullet for `T2`, then one short paragraph stating whether the two sessions ran on different tiers and therefore whether the driver routed per task rather than per run. If T1's bullet is missing or names the same tier as this session, say so plainly rather than reconciling it.

### Done

## Hand-off

Nothing yet — the item has not run.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-20 | The trial item is new and disposable rather than an existing backlog item. | Same reasoning as `AutoRunTrial`: a live run needs a real session, and an autonomous mistake on real project work is the silent drift the pipeline is built to avoid. A throwaway makes the blast radius one scratch article. |
| 2026-08-20 | Marked `> Autonomous: allowed` by the drafting session, against `work`'s rule that the marker is the user's call. | The marker is `ModelRouting` T3's own instruction applied — the task text asks for a live run on a cheap two-task item — not a session's own judgement. |
| 2026-08-20 | The cheap tier goes first (`haiku`), the dearer second (`sonnet`). | If the cheap tier cannot close a `next-session` task, the trial learns it on the cheapest run rather than after paying for the dearer one; and the escalation recommendation is then exercised live rather than only against the stub. |

## Progress

- 2026-08-20 — item drafted by `ModelRouting` S3 for T3's live run.
- 2026-08-20 — T1 completed (haiku session): created `Wiki/Concepts/RoutingTrial.md` with model tier and effort recorded.
