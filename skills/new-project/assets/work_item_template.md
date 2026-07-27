# {{ITEM_NAME}}

*[ LLM Generated ]*

> Type: research    <!-- research | formalization | refactor | investigation -->
<!-- Status is the folder: Active/ Backlog/ Done/ Dropped/. Move the file to change it. -->
<!-- These five sections are the whole file. Format: Wiki/Concepts/ItemFileFormat.md -->

## Spec

Origin: <!-- the originating request that prompted this item (provenance) -->

One-paragraph goal: what this work item delivers and why.
A quick item may stop here; a heavy one fills the subsections below.
This is the contract — corrected in place when it turns out wrong, never appended to.

### Requirements

- ...

### Design / API

Function signatures, data shapes, theorem statements — the contract to build against.

### Edge cases & out of scope

- ...

## Tasks

One unchecked box ≈ one focused session — small enough to finish, report, and commit in a single sitting.

- [ ] T1 — ...
- [ ] T2 — ...

### Done

(completed tasks move here with the session that closed them)

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
