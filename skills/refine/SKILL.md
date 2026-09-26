---
name: refine
description: >
  Shape a Work/Backlog item together with the user over a long sitting until it
  is ready to be worked — the user writes the human parts (Summary, Motivation,
  Acceptance criteria, any detail they care about) in their editor, while the
  LLM researches the code and wiki, writes the Technical details, keeps a list
  of open questions, and proposes the tasks and their routing. Ends with a
  readiness check and, on the user's word, the move to Work/Ready/ where
  /auto-run may pick it up. Use for: "refine X", "let's work on the backlog",
  "shape this item", "backlog refinement", "get X ready", or the /refine command.
  Not for executing tasks (next-session) or filing a quick new item (work).
---

# Refine a backlog item

Backlog refinement: the human and the LLM sit with one `Work/Backlog/` item for as long as it takes to make it ready.
The item is shared ground, and each side owns its part.
The format is in [`work` § *The item file format*](../work/SKILL.md#the-item-file-format); read `revise` first — this skill is its loop, held open for a whole sitting.

## When to use

- The user says "refine X", "let's work on the backlog", "shape this item", "get X ready", or runs `/refine`.
- `work` step 2 hands over here when an item needs more than one quick round.

## Who writes what

| part | written by | the other side |
|---|---|---|
| Title, Summary, Motivation, Acceptance criteria | **the user**, in their editor | the LLM suggests wording in chat when asked, and edits these only when told to |
| Prompt history | the LLM | quotes the user verbatim — never paraphrases |
| Technical details | **the LLM** | the user may edit any line; an edited line is theirs |
| `### Open questions` (inside Technical details) | the LLM | the user answers in chat or in the file |
| Tasks and routing | the LLM proposes | the user rules |
| Decisions | the LLM, from the user's answers | — |

The user's lines are protected content (`revise`): never reword them silently.
If a user-written sentence contradicts what the code shows, say so in chat and let them fix it.

## Steps

### 1. Open the item

Resolve the name in `Work/Backlog/` (create the item with `work` step 1 if it does not exist yet).
Read the whole file and whatever it links in `Wiki/`.
If the human sections are empty, ask the user what the item is for, in their words, and record their answer in Prompt history — do not fill the sections for them.
Set the header line `> Waiting on: you — <what>` whenever the next move is theirs, and remove it when it is not.

### 2. The loop

Each turn:

1. **Re-read the file first.** The user edits it in their editor between turns; work from what is on disk, never from memory of an earlier version.
2. Answer what they asked, or take the next open question.
3. Do the thinking the item needs — read the code, run small probes, check the wiki — and write what you learn into Technical details: the design, the data shapes, the edge cases, the traps.
4. Keep `### Open questions` as a numbered list of what only the user can decide, each one sentence with the options you see. When they answer, delete the question and put the answer where it belongs — a `## Decisions` row for a choice, a Technical-details sentence for a fact.
5. Tell the user briefly what changed in the file and what you need from them next.

Durable facts learned along the way — about the code, a tool, the mathematics — go to `Wiki/` as usual, and the item links them.
Keep Technical details to about a screen; if it keeps growing, propose splitting the item.

### 3. Propose the tasks

When the design has settled, propose `## Tasks`: one box per session, each routed (`work` § *The routing annotation*), `(human)` on any step the user wants to watch.
Check each Acceptance criterion against the list and say which tasks serve it; a criterion no task serves is a missing task.

### 4. Readiness check

Before the item can move, all of these hold — report them as a checklist:

- [ ] Summary, Motivation and Acceptance criteria are written, and the user has read them as they stand.
- [ ] `### Open questions` is empty or gone.
- [ ] Every Acceptance criterion is served by at least one task.
- [ ] Every task is routed or deliberately left to inherit, and gated with `(human)` where the user wants to watch.
- [ ] Technical details names the target (paclet, file, artifact) precisely enough for a cold session.

### 5. Move to Ready — only on the user's word

When the user says it is ready, `git mv` the file to `Work/Ready/<Name>.md`, add it to the Ready table in `Work/README.md`, and commit.
That move is the approval that lets `/auto-run` take the item, so never make it on your own judgement, and never mid-sitting "to save time".
If the user wants to start at once rather than queue it, move it to `Active/` instead and say that `/next-session` is the next step.

A sitting may end before the item is ready: leave it in `Backlog/`, make sure the open questions are written down, and set `> Waiting on:` so the next sitting knows where to start.

## When NOT to use

- Executing a task — that is `next-session`, one task per fresh session.
- Filing a quick item the user does not want to shape — that is `work`.
- Rewriting an item that is already `Active/` or further on — refinement is for the backlog; a Spec change after approval goes through `work` § *Updating the spec later*.
