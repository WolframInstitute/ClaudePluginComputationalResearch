# A skill for every step of an item's life

*[ LLM Generated ]*

> Type: feature
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
- Every skill is named `<area>-<word>`, and skills of one area share a prefix; the backlog skills are `backlog-add`, `backlog-refine`, `backlog-info`, `backlog-board`, `backlog-run`, `backlog-autolab`, `backlog-run-scheduled`, `backlog-review`.

## Prompt history

- 2026-10-03 — "We need a great system in backlog processing and refinement. We also need a great system in iterative AI-assisted refinement of one document. ... All this should be nicely described in the README and should have well thought skills with good names."
- 2026-10-04 — "can we make some more expressibe names that start with the same letteer? like backlog-add ... or something like that? This should be true for all skills"
- 2026-10-04 — "backlog-? / rename all / I dont understand, you take the simplest clever option / The main goal is to have a backlog that we can refine and several sessions can work on it"
- 2026-10-04 — "backlog-add / backlog-refine / backlog-info / backlog-board / backlog-run / backlog-autolab / backlog-run-scheduled / backlog-review"
- 2026-10-04 — "yes go on" (add the naming criterion, move to Ready)

## Technical details

### Names

Every skill and command is `<area>-<word>`, with a further word only where one is needed; the area is the README section it belongs to.
The backlog family carries the item's whole life, so typing `/backlog-` lists it.

| Area | Now | New |
|---|---|---|
| backlog | `work` | `backlog-add` |
| | `refine` | `backlog-refine` |
| | (new) | `backlog-info` |
| | `board` | `backlog-board` |
| | `next-session` | `backlog-run` |
| | `autolab` | `backlog-autolab` |
| | `auto-run` | `backlog-run-scheduled` |
| | (new) | `backlog-review` |
| project | `new-project`, `load-project`, `check-env`, `clean` | `project-create`, `project-load`, `project-check-env`, `project-clean` |
| | `start-tour`, `provenance` | `project-tour`, `project-provenance` |
| document | `revise` | `document-revise` |
| wiki | `init-wiki`, `check-wiki`, `update-wiki` | `wiki-init`, `wiki-check`, `wiki-update` |
| | `add-resource`, `search-math`, `search-wolfram` | `wiki-add-resource`, `wiki-search-math`, `wiki-search-wolfram` |
| notebook | `new-notebook` | `notebook-create` |
| paclet | `build-paclet`, `publish-paclet`, `paclet-docs` | `paclet-build`, `paclet-publish`, `paclet-docs` |
| paper | `new-paper`, `new-research-notebook`, `new-research-note` | `paper-create`, `paper-create-notebook`, `paper-create-note` |
| | `cite`, `journal`, `lean` | `paper-cite`, `paper-journal`, `paper-lean` |

The rename is a clean break: no alias stubs, a major version bump, and the old → new table in the release note and the blog post.
`backlog-refine` and `document-revise` make "you refine an item, you revise a document" visible in the names.

### The two new skills

- `backlog-info`: reads every item in `Backlog/` and `Ready/` and every unmerged `auto/*` branch; reports per item its `> Waiting on:` line, its age since the last Progress line, and overlaps with other items; proposes refine / merge / drop / split; applies only what the user says, each move a `git mv` and a `Work/README.md` update.
  If the board has queued changes, it says so and points at `backlog-board`; it does not sync.
- `backlog-review`: takes an `UnderReview/` item in the checkout, or an item whose `auto/<Item>` branch has it in `UnderReview/`; shows the run digest if there is one; walks the Acceptance criteria with the test instructions of the tasks that serve each; runs the checks it can run.
  On accept: `git merge auto/<Item>`, `git mv` to `Done/<date>-<Item>.md`, fix `Work/README.md`, commit, `git branch -d auto/<Item>`.
  On send back: the same merge, then a new task from the user's words, the item to `Active/` on `main`; the next run starts a fresh branch.
  It absorbs `work` § *Review*; the board's Accept / Send back at sync runs the same steps without the walkthrough (`skills/board/SKILL.md:48`).

### What the code shows

- After an autonomous run the checkout still shows the item in `Ready/`; only the branch has it in `UnderReview/` (or `Active/` if the run halted) — `skills/autolab/SKILL.md:103`, `commands/auto-run.md:18`.
  So both new skills read `git branch --list 'auto/*'` and `git show auto/<Item>:Work/...`, not the folders alone.
- The merge is already named "the `revise` approval" — `skills/autolab/SKILL.md:158`, `commands/auto-run.md:36`; the review is where it now happens.
- Old names appear in about 30 files: skill bodies, `commands/`, `README.md`, `ARCHITECTURE.md`, `Wiki/`, the `new-project` templates, and `scripts/scaffold-paclet*.sh`.

### Edge cases & out of scope

- `backlog-info` never moves an item to `Ready/` on its own; that stays `backlog-refine`'s last step on the user's word.
- A branch that does not merge cleanly stops the review; it does not resolve conflicts.
- A halted run (item `Active/` on its branch) is not a review; `backlog-info` reports it with the hand-off question.
- Projects scaffolded earlier keep the old names in their own `CLAUDE.md` and `Work/README.md`; they are not rewritten.
- Out of scope: any change to the item file format; how several sessions claim items (that is [ParallelSessions](ParallelSessions.md)).

## Tasks

- [ ] T1 (model: sonnet, effort: medium — mechanical) — rename every skill and command to the table; fix every cross-reference, the templates and the scripts; `claude plugin validate` passes.
- [ ] T2 (model: opus, effort: high — protocol writing) — `backlog-review` skill and command, lifting `work` § *Review*; `backlog-board` runs its steps for Accept / Send back.
- [ ] T3 (model: opus, effort: high — protocol writing) — `backlog-info` skill and command.
- [ ] T4 (human) — trial: one backlog check and one review of a real item.
- [ ] T5 (model: sonnet, effort: high — doc pass) — README and ARCHITECTURE tables, the refine/revise sentence, the blog post (the idea: each step of an item's life has a name), major version bump with the rename table.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Fresh item.
The README *Autolab* section was rewritten on 2026-10-03 with the five steps and the table, linking the new names to `skills/work/SKILL.md` until the skills exist.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-10-03 | You refine an item, you revise a document | both are standard usage: backlog refinement, a revised paper; proposed by the LLM, open to change |
| 2026-10-04 | Every skill named `<area>-<word>`; the item lifecycle under `backlog-` | the user asked for expressive names sharing a prefix, for all skills |
| 2026-10-04 | Backlog names: `backlog-add`, `-refine`, `-info`, `-board`, `-run`, `-autolab`, `-run-scheduled`, `-review` | the user's list |
| 2026-10-04 | Clean rename, no alias stubs, major version bump | simplest; the user left the choice to the LLM |
| 2026-10-04 | The review merges the branch, on accept and on send back; send back continues on `main` | the merge is already the approval; one place of truth; the user left the choice to the LLM |
| 2026-10-04 | `backlog-info` reports queued board changes but does not sync | the board's rule: a sync is always the user's request; the user left the choice to the LLM |

## Progress

- **S0** 2026-10-03 — item filed from the operator's request; README section written first.
- **R1** 2026-10-04 — refined with the operator: names `<area>-<word>` for every skill, the backlog family settled, review merges, tasks re-cut; moved to Ready.
