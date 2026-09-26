# AutolabTrialT4

*[ LLM Generated ]*

> Type: investigation
> Autonomous: allowed

## Spec

Origin: `InSessionAutoRun` T4 — "serial trial against a throwaway item of three tasks, one of which is built to halt `needs-human`: the Agent map shows each worker, the halt reaches the chat, the branch and digest are right."

Give `/autolab` a real item to run serially, so T4 exercises the actual dispatch/verify loop instead of reasoning about it from the Spec.
The item's value is the trial itself; its tasks are small, textual, and disposable.

### Requirements

- Every task must be doable with no human present, and cheap to be wrong about — wiki-scratch prose, which `revise` exempts from sign-off.
- Exactly one task (T2) is built to make the worker write `needs-human` into `## Hand-off` and stop, so the trial can watch that halt reach the orchestrating chat.
- Nothing here may edit `skills/autolab/SKILL.md`, `commands/autolab.md`, `agents/autolab-worker*.md`, or `Work/Active/InSessionAutoRun.md` — the item under trial must not modify its own driver mid-run.

### Edge cases & out of scope

- Findings about `/autolab`'s behaviour belong to `InSessionAutoRun` T4 and to the pipeline wiki article, not here.
- This item does not extend `/autolab`.

## Tasks

- [ ] T1 (model: sonnet, effort: low) — Create `Wiki/Concepts/AutolabTrialScratch.md`: one line naming today's date and the number of files directly under `commands/` in this repo. Link it from `Wiki/Index.md`.
- [ ] T2 (model: sonnet, effort: low) — `Wiki/Concepts/AutolabTrialScratch.md` needs a second line naming this trial's placeholder tag: choose between `alpha` and `beta`. Nothing in this repo or in this Spec picks between them, and writing either down silently commits the project to it. Do not choose it yourself — follow `revise` § *Autonomous mode*: write the open question into `## Hand-off` as a `needs-human:` line, do not edit the wiki article, commit only the hand-off, and stop.
- [ ] T3 (model: sonnet, effort: low) — Add one line to `Wiki/Concepts/AutolabTrialScratch.md` recording which of `alpha`/`beta` the operator picked, once `## Hand-off` no longer holds the open question.

### Done

## Hand-off

(nothing yet)

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-09-26 | Marked `> Autonomous: allowed` by the drafting session, against `work`'s rule that the marker is the user's call. | Same reasoning as `AutoRunTrial` (2026-07-28): the user's instruction was `InSessionAutoRun` T4 itself, which directs a throwaway item built to run under `/autolab` — the marker is that instruction applied, not a session's own judgement. |
| 2026-09-26 | T2's halt is scripted (an explicit either/or with instructions to defer) rather than an organically ambiguous task. | T4 is a plumbing test of whether `needs-human` propagates through verify and reaches the chat, not a test of whether a worker recognizes ambiguity unprompted — a deterministic trigger isolates the mechanism under test. |

## Progress

Append-only, one line per session; nothing reads it.
