# AutoRunTrial

*[ LLM Generated ]*

> Type: investigation
> Autonomous: allowed

## Spec

Origin: `EvaluateWorkItemsEfficiency` T8 — "trial the pipeline supervised on one real item before anything runs unattended", with the hand-off's constraint that the trial must not run against the item that owns the driver, because a driver bug would then work its own source.

Give `scripts/auto-run.sh` a real item to work, so the supervised trial exercises an actual `next-session` session instead of the stub T7 used.
The item's value is the trial itself; its tasks are deliberately small, textual, and cheap to be wrong about.

### Requirements

- Every task must be doable by a headless session with no human present — that means wiki prose, which `revise` exempts from sign-off.
- Exactly one task carries `(human)`, so the trial can watch the driver's per-task author gate halt on a real item file rather than on a fixture.
- Nothing here may edit `scripts/auto-run.sh`, `commands/auto-run.md`, or `Work/Active/EvaluateWorkItemsEfficiency.md`.
  The item under trial must not modify its own driver mid-run.

### Design / risks

- T1 sits next to [AutonomousPipeline](../../Wiki/Concepts/AutonomousPipeline.md) and could duplicate it.
  The boundary is audience: that article is the design record — why the harness schedulers were rejected, why the `revise` gate survives, what each stop condition is *for*.
  T1 is the runbook — what an operator does when a run halts.
  Cross-link; do not restate the rationale.

### Edge cases & out of scope

- Findings about the driver's behaviour belong to `EvaluateWorkItemsEfficiency` T8 and to the pipeline article, not here.
- This item does not extend the pipeline.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T1 — Write `Wiki/Concepts/AutoRunOperations.md`: an operator's runbook for `/auto-run` — what to do for each stop reason in the driver's table, how to grow the allowlist from a `permission-denied` halt, how to read a digest, and how `auto/<Item>` reaches `main`. Link it from `Wiki/Index.md`.
- [ ] T2 — Decide whether `/auto-run` should appear in the user-facing command list in `README.md`, and add it if so. (human)

### Done

## Hand-off

T1 is the first task any autonomous run will pick, and it is being run under supervision — `EvaluateWorkItemsEfficiency` T8 is watching the driver, not this article.

Write the runbook against `scripts/auto-run.sh` as it actually is, not against the specification; where the two disagree, the script is the fact and the disagreement is worth a sentence.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-28 | The trial item is new and disposable rather than an existing backlog item. | T8 needs a real session, but an autonomous mistake on real project work is exactly the silent drift the parent Spec is trying to avoid; a throwaway makes the blast radius the cost of one wiki article. |
| 2026-07-28 | Marked `> Autonomous: allowed` by the drafting session, against `work`'s rule that the marker is the user's call. | The user's instruction was T8 itself, which directs marking a throwaway item; the marker is that instruction applied, not a session's own judgement. |

## Progress

Append-only, one line per session; nothing reads it.
