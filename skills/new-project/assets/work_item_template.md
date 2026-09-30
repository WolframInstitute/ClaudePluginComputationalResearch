# {{ITEM_TITLE}}

*[[ LLM Generated ]]*

> Type: research    <!-- research | formalization | refactor | investigation -->
<!-- Optional header lines: `> Target: <paclet or artifact>`, `> Waiting on: you — <what>`.
     Moving the item to Ready/ lets /auto-run work it unattended; in Backlog/ it never runs. -->
<!-- Status is the folder: Backlog/ Ready/ Active/ UnderReview/ Done/ Dropped/. Move the file to change it.
     The title is plain words; the filename stays CamelCase. Format: Wiki/Concepts/ItemFileFormat.md -->

## Summary

Two or three sentences a newcomer understands: what this item delivers, and for whom.
No code, no symbol names — a reader who stops here knows what the item is.

## Motivation

- Why it matters: the problem, and what goes wrong if it is left alone.
- At most five bullets.

## Acceptance criteria

- What is true when the item is done, stated as an outcome a human can check.
- At most seven bullets. Tasks are how to get there; these are where "there" is.

## Prompt history

- YYYY-MM-DD — "the user's own words that prompted or reshaped this item, verbatim"

## Technical details

The contract to build against, for the sessions that do the work — corrected in place when it turns out wrong, never appended to.
A quick item may need one paragraph; a heavy one fills the subsections below.
Past about one screen it is a sign the item should be split.

### Requirements

- ...

### Design / API

Function signatures, data shapes, theorem statements.

### Edge cases & out of scope

- ...

### Open questions

1. What only the user can decide, one sentence each with the options. Empty before the item moves to `Ready/`.

## Tasks

One unchecked box ≈ one focused session — small enough to finish, report, and commit in a single sitting.

<!-- Route each task: (model: haiku|sonnet|opus|fable, effort: low|medium|high|xhigh|max — reason).
     Both fields optional, model first; absent means inherit. See work § The routing annotation. -->

- [ ] T1 (model: opus, effort: xhigh — design-critical) — ...
- [ ] T2 (model: sonnet, effort: high — mechanical) — ...    <!-- append `(human)` to a task /auto-run must not run unattended; keep it outside the routing parens -->


### Done

(completed tasks move here with the session that closed them)

<!-- Each closed box carries one to four indented test instructions for the human reviewer, e.g.
       [x] T1 (S1) — ...
         - **Test:** open [the file](../../path) — what the reviewer should see.
         - **Test:** run `...` — the expected result. -->

## Hand-off

Overwritten each session, not appended to: what the next session must know that is not yet true anywhere else — half-finished state, a blocker, a branch left open.
Empty is the right answer when the next task needs nothing but the Spec.

(nothing yet)

## Decisions

One row per choice between real alternatives; one sentence each.
A reversal **edits** the row it reverses — the table never carries a row and its contradiction.
Link the evidence rather than restating it.

| Date | Decision | Rationale |
|---|---|---|

## Progress

Append-only audit trail, **one line per session**, newest at the bottom.
Nothing reads this: durable facts are in `Wiki/`, choices in `## Decisions`, carry-forward in `## Hand-off`.

- **S1** YYYY-MM-DD T1 — one clause naming what changed. → [what was filed](...)
