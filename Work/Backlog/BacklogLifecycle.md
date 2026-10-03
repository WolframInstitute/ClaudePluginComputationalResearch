# A skill for every step of an item's life

*[ LLM Generated ]*

> Type: feature
> Waiting on: you — the names, and the open questions.
<!-- Status is the folder: Backlog/ Ready/ Active/ UnderReview/ Done/ Dropped/. Move the file to change it. -->

## Summary

An item is filed, refined, run and reviewed, and each of these steps has a skill with a plain name.
Two steps are missing today: going through the whole backlog, and reviewing a finished item.
One name is weak: the skill that files an item is called work.

## Motivation

- After an autonomous run the operator merges the branch, reads the digest, checks the criteria and moves the file by hand; nothing guides that.
- The backlog grows and nothing goes through it: stale items, overlaps and items whose premise is gone sit until someone notices.
- "Refine" and "revise" are easy to confuse unless the README says once which is which.

## Acceptance criteria

The README's *Autolab* section is true:

- Filing, refining, going through the backlog, running and reviewing each have a skill, and the README names them in that order.
- Going through the backlog reports what waits on you, what is stale, and what to refine, merge or drop next, and moves an item only on your word.
- Reviewing a finished item walks you through your acceptance criteria with each task's test instructions, merges the item's branch if there is one, and ends with the item in Done or back in Active with a new task.
- The README says in one sentence that you refine an item and revise a document.

## Prompt history

- 2026-10-03 — "We need a great system in backlog processing and refinement. We also need a great system in iterative AI-assisted refinement of one document. ... All this should be nicely described in the README and should have well thought skills with good names."

## Technical details

### Requirements

- `new-item` replaces `work` as the filing skill; `work` stays as an alias in the description for a release, then goes.
- `backlog`: reads every item in `Backlog/` and `Ready/`, plus the board's queued new items and notes if a board exists; reports per item its `> Waiting on:` line, its age since the last Progress line, and overlaps with other items; proposes refine / merge / drop / split; applies only what the user says, each move a `git mv` and a `Work/README.md` update.
- `review`: takes an `UnderReview/` item, or an `Active/` item with an unmerged `auto/<Item>` branch; shows the run digest if there is one; walks the Acceptance criteria with the test instructions of the tasks that serve each; runs the checks it can run; on accept merges the branch, moves the item to `Done/` with the date prefix; on send back writes the new task from the user's words and moves the item to `Active/`.
  It absorbs `work` § *Review* and the board's Accept / Send back.
- `refine` stays as it is; `revise` stays as it is.

### Edge cases & out of scope

- `backlog` never moves an item to `Ready/` on its own; that stays `refine`'s last step on the user's word.
- A `review` of an item whose branch does not merge cleanly stops and says so; it does not resolve conflicts.
- Out of scope: any change to the item file format.

### Open questions

1. Names: `new-item` for filing (matching `new-project`, `new-paper`), or keep `work`? `backlog` for going through the backlog, or `triage`?
2. Does `review` merge the branch, or only check and leave the merge to the user?
3. Should `backlog` also sync the board first, so the phone's queued changes are part of what it goes through?

## Tasks

- [ ] T1 (human) — settle the names and the open questions; approve the README table.
- [ ] T2 (model: opus, effort: high — protocol writing) — `review` skill and command, lifting `work` § *Review*; `board` points to it for Accept / Send back.
- [ ] T3 (model: opus, effort: high — protocol writing) — `backlog` skill and command.
- [ ] T4 (model: sonnet, effort: medium — mechanical) — rename `work` to the chosen name with the alias; update every cross-reference.
- [ ] T5 (human) — trial: one backlog pass and one review of a real item.
- [ ] T6 (model: sonnet, effort: high — doc pass) — README, ARCHITECTURE counts, the blog post (the idea: each step of an item's life has a name), version bump.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Fresh item.
The README *Autolab* section was rewritten on 2026-10-03 with the five steps and the table, linking the new names to `skills/work/SKILL.md` until the skills exist.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-10-03 | You refine an item, you revise a document | both are standard usage: backlog refinement, a revised paper; proposed by the LLM, open to change |

## Progress

- **S0** 2026-10-03 — item filed from the operator's request; README section written first.
