---
name: backlog-info
description: >
  Go through the whole Work/ backlog with the user: read every item in
  Backlog/, Ready/ and UnderReview/ and every work/<Item> branch, and report
  what waits on the user (a review, a halted run's question, a Waiting-on
  line, queued board changes), what is stale (no Progress for a month, or a
  premise the code no longer has), which items overlap, and what to refine,
  merge, split or drop next. Changes nothing until the user says so; then each
  move is a git mv and an index update. Never moves an item to Ready and never
  syncs the board. Use for: "go through the backlog", "backlog info", "what's
  in the backlog", "what waits on me", "clean up the backlog", "what next", or
  the /backlog-info command. Not for shaping one item (backlog-refine) or
  reviewing a finished one (backlog-review).
---

# Go through the backlog

A look over the whole of `Work/`, now and then, so that nothing waits on the user unseen and nothing sits in the backlog after its reason is gone.
It reports first and moves nothing; the user rules on each proposal.
The item format and the folders are in [`backlog-add`](../backlog-add/SKILL.md); read `document-revise` first.

## When to use

- The user says "go through the backlog", "what waits on me", "clean up the backlog", "what next", or runs `/backlog-info`.
- After an autonomous run has left branches, or before choosing what to refine next.

## Steps

### 1. Gather

Read only; run everything in the operator's checkout, on its own branch.

- **The items.** Every file in `Work/Backlog/`, `Work/Ready/` and `Work/UnderReview/`, and the title and Summary of every `Work/Active/` item (for overlaps only).
  Per item keep: the title, the `> Waiting on:` line, the Summary, the paths and skill names its Technical details cite, and its **age** — the date in its last `## Progress` line, else `git log -1 --format=%cs -- <file>`:

  ```bash
  awk '/^## Progress/{p=1;next} /^## /{p=0} p&&/^- /{l=$0} END{print l}' <file> | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1
  ```

- **The branches.** Every session works an item on its own branch, `work/<Item>` — or `auto/<Item>`, made before the rename — so the checkout still shows the item in `Ready/` or `Active/`, and only its branch knows where the work stands.

  ```bash
  git branch --format='%(refname:short)' --list 'work/*' 'auto/*' --no-merged HEAD
  git branch --format='%(refname:short)' --list 'work/*' 'auto/*' --merged HEAD
  ```

  For each unmerged `<branch>`, find the item on it with `git ls-tree -r --name-only <branch> -- Work | grep '/<Item>.md$'` and read it with `git show`.
  In `UnderReview/` there, the work is finished; in `Active/` with a `needs-human:` line in `## Hand-off`, a run halted; in `Active/` without one, the item is in progress.
  A merged branch that still exists is only leftover.

- **The claims.** An item's worktree is its claim; one nobody works in holds the claim forever.

  ```bash
  git worktree list --porcelain
  ```

  For each worktree on a `work/*` or `auto/*` branch, the date of the branch's last commit is `git log -1 --format=%cs <branch>`.
  One with no commit in the last 7 days is **abandoned**, unless its tree is dirty, which `git -C <path> status --porcelain` shows; then it may be a session still at work, and it is only reported.

- **The board.** If `.claude/work-board.json` exists, read the board's `data/pending.json` with the Artifact tool (`action: "read"`, `path`).
  Anything in its `edits` or `newItems` is queued and not yet in the files.

### 2. Judge

- **Waits on you** — an item in `UnderReview/`, in the checkout or on its branch; a halted run's `needs-human:` question; a `> Waiting on: you` line; queued board changes; an abandoned claim.
- **Stale** — an item in `Backlog/` or `Ready/` with no Progress line in the last 30 days.
  Also stale, at any age: a premise gone — a file, skill or function its Technical details cite no longer exists (check each with `ls` or `grep`), or another item already delivered what it asks for (`Done/`, `Work/README.md`'s notes).
- **Overlaps** — two items, at least one in `Backlog/` or `Ready/`, that ask for the same outcome or change the same files.
  Name the shared thing in one sentence; a shared word is not an overlap.
- **Proposals** — at most one per item, each with its reason in one clause:
  - **refine** — open questions, an empty human section, or an item that has waited longest; `/backlog-refine <Item>`;
  - **merge** — an overlap; name the item that stays;
  - **split** — Technical details past a screen, or two outcomes that would be accepted separately;
  - **drop** — a premise gone, or delivered elsewhere;
  - **review** — `/backlog-review <Item>`; **answer** — quote the hand-off question; **sync** — `/backlog-board`;
  - **delete** a leftover merged branch with `git branch -d`;
  - **release** an abandoned claim with `git worktree remove <path>`, which leaves its branch.

  An item with nothing to propose is not listed under the proposals.
  Never propose moving an item to `Ready/`: that is the user's word at the end of a `backlog-refine` sitting.

### 3. Report

In the chat, in this order, each part left out when empty:

1. **Waits on you** — one line per thing, with the command that takes it up.
2. **Stale** — the item, its age or its missing premise.
3. **Overlaps** — the pair and what they share.
4. **Next** — the proposals, numbered, so the user can answer by number.

Close with one line on the rest: how many items are in each folder.
Then wait.

### 4. Apply what the user says

Only the proposals the user approves, in their words; a proposal they skip stays as it is.

- **Drop** — `git mv Work/<Folder>/<Item>.md Work/Dropped/$(date +%F)-<Item>.md`; append `- **Info** YYYY-MM-DD — dropped: <reason>.` to its `## Progress`.
  An unmerged `work/<Item>` or `auto/<Item>` branch is left for the user to delete.
- **Merge A into B** — B stays where it is.
  A's `## Prompt history` lines go into B's, in date order; one sentence in B's Technical details names what A added; a `## Decisions` row in B records the merge.
  A's human sections are the user's: quote them to the user and let them say what B takes, never rewrite them in.
  Then A is dropped as above with the reason `merged into B`; if B was in `Ready/`, it goes back to `Backlog/`, since its Spec changed.
- **Split** — the new item is filed with [`backlog-add`](../backlog-add/SKILL.md) step 1, in `Backlog/`, from the user's words; the old item loses that part of its Spec, with a `## Decisions` row.
- **Refine, review, answer, sync** — name the command; that work is another skill's, in its own sitting.
- **Delete a branch** — `git branch -d <branch>`, never `-D`.
- **Release a claim** — `git worktree remove <path>`, never `--force`; a dirty tree is the user's to commit or discard.

After the moves, fix `Work/README.md`: the Ready and UnderReview tables, and any sentence there that lists the backlog by name.
Commit `docs(work): backlog info — <what moved>`.
Never push.

### 5. Stop

Say in one or two lines what moved, and which proposal to take up next.

## When NOT to use

- Shaping one item — `backlog-refine`.
- Reviewing a finished item — `backlog-review`; this skill only points at it.
- Syncing the board — `backlog-board`; a sync is always the user's own request.
- An unattended run: this skill reports to a person and waits for their word, so `/backlog-autolab` and `/backlog-run-scheduled` never run it.
