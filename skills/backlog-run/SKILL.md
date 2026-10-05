---
name: backlog-run
description: >
  Run one disciplined work session against a Work/ item: pick the next
  incomplete task, study the Spec, implement exactly ONE task, append a Progress
  report, mark the task done, sync durable knowledge to the Wiki, commit, and
  STOP. Built to be run in a FRESH session each time to avoid context
  accumulation. Use for: "next session", "next task", "work the next task",
  "continue the work item", "resume <Name>", or the /backlog-run command. It
  does exactly one task then stops — it never chains tasks.
---

# Next Session

Run exactly **one** task against a `Work/` item, then stop.
Running each task in a fresh session is the whole point — it keeps context small and avoids the rot that builds up over a long chat.
Read `document-revise` first; it governs the deliverable.

## When to use

- The user says "next session", "next task", "work the next task", "continue the work item", "resume <Name>", or runs `/backlog-run`.
- Always in a **fresh** session — clean context per task is the whole point.

## Steps

### 1. Locate the item

- If a name was given (`/backlog-run GraphCurvature`), use `Work/Active/<Name>.md`, or `Work/Ready/<Name>.md`, which is started below.
  If it is in `Work/Backlog/`, it has not been approved: say so and ask before starting it — shaping it is [`backlog-refine`](../backlog-refine/SKILL.md).
  An item in `Work/UnderReview/`, `Work/Done/` or `Work/Dropped/` has no next task — surface that instead.
- Else read `Work/README.md` (it lists active items); if exactly one is active, use it; if several, ask which.

#### Claim it

An item is claimed by its branch, `work/<Item>`, checked out in its worktree, `~/.cache/autolab/<Repo>/<Item>`, `<Repo>` being the repo folder's name.
git lets a branch be checked out in one worktree only, so a second session that reaches for the item is refused, and git's refusal names the worktree that holds it.
The rule is the same for interactive and autonomous sessions, and a colleague follows it with plain git.
The worktree lies outside the repo because git surgery inside a cloud-synced folder races the sync daemon.

- **Started on it** — this session's repository already has the item's branch checked out, because a driver put it there (`/backlog-autolab` in the item's worktree, `/backlog-run-scheduled` in the checkout) → the claim is the driver's; go on.
- **Otherwise**, from the checkout, with `git -C <repo>` and absolute paths:
  - `work/<Item>` exists → `git -C <repo> worktree add <path> work/<Item>`.
  - Else `auto/<Item>` exists, an unmerged branch from before the rename → the same with `auto/<Item>`; it stays the item's branch until it is merged.
  - Else → `git -C <repo> worktree add -b work/<Item> <path> HEAD`.
- **git refuses** because the branch is already used by a worktree → **stop**.
  Say that the item is claimed and name the worktree from git's message.
  Do not work in that worktree: whoever holds it may be mid-task, and their uncommitted work is not this session's to see.
  An abandoned claim is released by removing its worktree (`git worktree remove <path>`), which is the operator's call; [`backlog-info`](../backlog-info/SKILL.md) lists the worktrees whose item has had no commit in a week.
  Any other refusal — the path exists, say — stops the session too, quoting git.
- A repo with submodules (`.gitmodules`, a paclet-dev repo) is not claimed this way yet, since submodules in a worktree are untried: work in the checkout as before.

From here on the worktree is the repository this session works in.
Every Bash command starts with `cd <path> &&` or uses `git -C <path>`, file tools take absolute paths under `<path>`, and every repo-relative path a skill names — `Work/Active/<Item>.md`, `Wiki/...` — means `<path>/<that path>`.
Read the item there: its branch carries every earlier session's work.

**Start a Ready item** in the worktree, unless its branch already has it in `Active/`: `git mv Work/Ready/<Item>.md Work/Active/<Item>.md` and commit `chore(work): start <Item> from Ready`.
In the checkout the item stays in `Ready/` until its branch is merged.

### 2. Load context

Read the item file — the Spec (`## Summary` through `## Technical details`, or a single `## Spec` in an older item), `## Tasks`, `## Hand-off`, `## Decisions`.
The Acceptance criteria are what the task serves: if the task as written would not move the item toward them, say so rather than doing it.
The format holds that read flat in session count, so there is no partial-read rule: `## Progress` is one line per session and nothing in it is needed (see `Wiki/Concepts/ItemFileFormat.md`).
An item that predates the format carries multi-paragraph Progress blocks — read only the last one or two of those, and give the item a `## Hand-off` in step 5.

### 3. Pick the task

Take the first unchecked box in `## Tasks`.
State it back to the user, with its [routing annotation](../backlog-add/SKILL.md#the-routing-annotation) if it has one.
Compare the annotated model against the tier you are running on — by tier, never by id string, since the same tier reports different ids — and on a mismatch state both and stop for the user's call: one `/model` and a fresh session cost less than a task run on the wrong tier, and a cheap tier returns a confident wrong answer with nothing in the output to flag it.
If they say proceed, name the tier you actually ran on in the Progress line.
Effort cannot be self-checked, since nothing reports it — state the requested level and let the operator set it.
An unparseable annotation, or an effort outside `low|medium|high|xhigh|max`, halts here rather than defaulting silently.
In an autonomous run the driver set the model from this same annotation, so a mismatch there is a driver bug: write it into `## Hand-off` with `needs-human:` instead of proceeding.

### 4. Do exactly one task

Implement that single task — code, notebook, proof, whatever it calls for — following the `document-revise` loop for the deliverable.
Do not start the next task.
If the task changes a paclet submodule (paclet-dev), make the edits in that paclet's worktree on the item's branch — procedure in [paclet-worktree.md](paclet-worktree.md), read only in that case.

### 5. File what the session produced

**One fact, one destination — nothing is written twice**: file each fact per the destination table in [backlog-add § *The item file format*](../backlog-add/SKILL.md#the-item-file-format) (rationale: `Wiki/Concepts/ItemFileFormat.md`).

The Progress line, appended at the bottom:

```
- **SN** YYYY-MM-DD Tk — one clause naming what changed. → [links to what was filed](...)
```

Filing a fact in `Wiki/` **discharges** the obligation to state it in Progress — the line links it rather than summarising it.
Do not add sections to the item file: conclusions go to `Wiki/`, blockers to `## Hand-off`.

If the project has prompt tracking on (see the [project-provenance](../project-provenance/SKILL.md) skill), the session's prompt goes to the `Wiki/Prompts.md` ledger, not into the item file.

Prose written here and in the step-4 deliverable follows the `Semantic line breaks` toggle in `CLAUDE.md` § *Source formatting*.

### 6. Close the task

Check the box and move it to `### Done` with the session number.
Under it, write the task's **test instructions** — one to four indented bullets telling the human reviewer how to check it:

```
- [x] T2 (S3) — drop the Group A symbols.
  - **Test:** open [Kernel/Main.wl](../../Kernel/Main.wl) — the eleven `$Infra*Color` exports are gone.
  - **Test:** run `TestReport["Tests/ToolsTests.wlt"]` — all pass.
```

Name the place (a relative link), the action, and what they should see — not what the session did, which is Progress.
If nothing is checkable by a human, write one bullet saying so and why.
Update the item's line in `Work/README.md` (next task).
If that was the **last** task, the work is finished but not accepted: `git mv` the file from `Active/` into `UnderReview/` (clean name) and move its index line to the UnderReview table.
Only the user moves it on to `Done/`, in a [`backlog-review`](../backlog-review/SKILL.md).
The folder is now its status — there is no field to flip.

### 7. Sync durable knowledge

Invoke `wiki-update` for the durable facts from step 5 — a new function, a result, a definition, a gotcha about an external tool.
It updates `Wiki/` articles and `Status.md`.
When a fact contradicts what an article says, **edit the article**; `Wiki/` is the one surface where a fact can be corrected instead of contradicted, which is why durable content goes there rather than into an append-only log.
`Work/` (the folders + the index, already updated above) owns active items and blockers.

If the project's scientific journal is on (see the [paper-journal](../paper-journal/SKILL.md) skill), append a concise dated def/thm/rem/claim entry for what was established this session, citing resources used.
When off, skip.

### 8. Commit

The commit goes on the item's branch, in its worktree — never on the checkout's branch, which the work reaches only when [`backlog-review`](../backlog-review/SKILL.md) merges it; that merge is the review, for interactive and autonomous work alike.
If the user commits, use the `commit` skill. git history is now the project's audit trail, so write a message that names the item and task.
In an autonomous run (see `document-revise` § *Autonomous mode*) there is no user to ask: commit unconditionally, on the `work/<Item>` branch you were started on. The driver reads the new commit and the newly checked box as proof the task ran.
In a paclet-dev repo, paclet code is committed in its worktree on `work/<item>` and the dev-repo tracking (`Work/`, `Wiki/`, `Code/`) on `main` — see [paclet-worktree.md](paclet-worktree.md).

### 9. Stop

Release the claim, if this session made the worktree: `git -C <repo> worktree remove <path>`, no `--force`.
The branch stays and carries the work to the next session, which makes the worktree again.
git refuses a dirty tree: then leave it, and say that the item stays claimed until the work is committed or the worktree is removed.
A worktree a driver made is the driver's to remove.

Say: "Session N complete (Tk).
Start a fresh session and run /backlog-run for the next task."
If the item went to `UnderReview/`, say instead that it is ready for review with `/backlog-review <Name>`, and point at the test instructions.
Do not continue.

## Type-aware execution

For a `Type: formalization` item, "do one task" (step 4) means close one Lean sub-goal via the `paper-lean` core loop.
Which Mathlib lemma or tactic closed it is a durable fact — it goes to the `Wiki/` theorem article, not into the item file.

## Integration with other skills

- `backlog-add` creates and formats the items this skill executes; the one-fact destination table lives there.
- `document-revise` governs the deliverable (and its *Autonomous mode* governs `/backlog-autolab` workers and `/backlog-run-scheduled` sessions).
- `wiki-update` files the durable facts in step 7; `paper-journal` and `project-provenance` are fed when their toggles are on.
- `commit` writes the audit-trail commit in step 8.

## When NOT to use

- Creating or re-scoping an item — that is `backlog-add`.
- Chaining a second task in the same session — never; start a fresh session instead.
- An archived item (`Done/` or `Dropped/`) — it has no next task.
