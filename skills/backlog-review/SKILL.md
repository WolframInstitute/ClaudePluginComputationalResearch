---
name: backlog-review
description: >
  Review a finished Work/ item with the user: find it in Work/UnderReview/ or
  on its unmerged auto/<Item> branch, show the run digest, walk the Acceptance
  criteria one by one with the test instructions of the tasks that serve each,
  run the checks that can be run, and end on the user's verdict — accept
  (merge the branch, item to Done/) or send back (merge the branch, a new task
  from the user's words, item to Active/). Nothing is fixed during the review.
  Use for: "review X", "review the item", "check the finished item", "accept
  X", "send X back", "merge the autolab branch", or the /backlog-review command.
  Not for running tasks (backlog-run) or going through the whole backlog.
---

# Review a finished item

The last human gate of an item's life: the work is done, and the user checks it against the Acceptance criteria they wrote.
The review is also where an autonomous run's branch is merged — the merge is the `document-revise` approval ([AutonomousPipeline](../../Wiki/Concepts/AutonomousPipeline.md)).
The item format and the folders are in [`backlog-add`](../backlog-add/SKILL.md); read `document-revise` first.

## When to use

- The user says "review X", "check the finished item", "accept X", "send X back", or runs `/backlog-review`.
- `backlog-run`, `/backlog-autolab` or `/backlog-run-scheduled` reported an item complete.

## Steps

### 1. Find the item

Resolve the name, or ask; with no name, list the candidates below and ask which.

- `git branch --list 'auto/*' --no-merged` names the branches still waiting.
  After an autonomous run the checkout shows the item in `Ready/` or `Active/`; only the branch has it in `UnderReview/`.
  Read it there: `git show auto/<Item>:Work/UnderReview/<Item>.md`.
- Otherwise the item is `Work/UnderReview/<Item>.md` in the checkout, from an interactive run, with no branch to merge.
- On its branch the item is in `Active/`: the run halted, and that is not a review.
  Quote its `## Hand-off` question and stop; answering it and resuming is `backlog-run`.
- Neither: the item has nothing to review; say where it is and stop.

With a branch, check now that it merges, before the user spends time on it: the checkout is clean, and `git merge-tree --write-tree HEAD auto/<Item>` exits 0.
A conflict stops the review: name the files and leave the resolution to the user.

### 2. Show what happened

- The newest run digest `Work/Runs/*-<Item>.md` in the checkout, if there is one: its stop reason, its tasks and their verdicts, its cost — in three or four lines.
- With a branch: `git log --oneline HEAD..auto/<Item>` and `git diff --stat HEAD...auto/<Item>`.
- The item's Summary, so the user has the goal in front of them.

### 3. Walk the Acceptance criteria

One criterion per turn, in the order the user wrote them:

1. Quote the criterion.
2. Name the tasks in `### Done` that serve it, each with its `**Test:**` bullets.
   A criterion no task serves is said plainly; it is a finding, not something to pass.
3. Run the checks that can be run — a script, a test suite, `claude plugin validate`, a `TestReport` on the Wolfram MCP — and report each as passed or failed with its one-line result.
   With a branch, run them where the branch is checked out: its autolab worktree under `~/.cache/autolab/<Repo>/<Item>` if it is still there, else a fresh `git worktree add` at that path, removed after the review.
   Never switch the operator's checkout.
4. Leave the rest to the user — opening a file, reading a page, looking at a picture — and wait for their word: it passes, or what is wrong.

Keep the user's findings in their own words, in the chat.
Nothing is fixed during the review, not even a typo: a fix made now would land unreviewed.
The user may say to go faster; then show the remaining criteria together and take one verdict.

### 4. The verdict

When every criterion has its answer, ask: accept, or send back.
No findings is not an acceptance; the user says it.

#### Accept

1. With a branch: `git merge --no-edit auto/<Item>`.
2. `git mv Work/UnderReview/<Item>.md Work/Done/$(date +%F)-<Item>.md`.
3. In the item: remove any `> Waiting on:` line, append `- **Review** YYYY-MM-DD — accepted.` to `## Progress`, and empty `## Hand-off`.
4. In `Work/README.md`: remove the item from its table; add one plain sentence on what the item delivered, if the index keeps such notes.
5. Commit `docs(work): <Item> accepted`.
6. With a branch: remove its worktree if it is still there (`git worktree remove <path>`, no `--force`), then `git branch -d auto/<Item>`.

#### Send back

1. With a branch: `git merge --no-edit auto/<Item>` — the work done so far is kept and continues on the checkout's branch.
2. Each finding becomes one new unchecked task in `## Tasks`, worded from the user's findings and routed ([`backlog-add` § *The routing annotation*](../backlog-add/SKILL.md#the-routing-annotation)).
   Present the tasks and their routing and wait for the user's ruling.
   Their findings go, quoted and dated, into `## Prompt history`.
3. `git mv Work/UnderReview/<Item>.md Work/Active/<Item>.md`; append `- **Review** YYYY-MM-DD — sent back: Tk added.` to `## Progress`; write the new task's context into `## Hand-off`.
4. In `Work/README.md`: move the item to the Active table with its next task.
5. Commit `docs(work): <Item> sent back from review`.
6. With a branch: remove its worktree as above, then `git branch -d auto/<Item>`; the next autonomous run starts a fresh branch.
   `> Autonomous: allowed` stays, so the item is still eligible.

Never push; pushing is the user's.

### 5. Stop

Say in one or two lines where the item is now, and for a send back that `/backlog-run <Item>` or `/backlog-autolab` takes the new task.

## The board

The board's **Accept** and **Send back** are this skill's step 4 without the walkthrough: the user's move on the page is the verdict.
`backlog-board` runs them at sync.
The board shows the checkout only, so an item whose finished run is still on an unmerged branch appears at its checkout folder; it is reviewed here, not from the board.

## When NOT to use

- An item still `Active/` or halted on its branch — that is `backlog-run`, after the hand-off question is answered.
- Changing the Spec of an item under review — that is `backlog-add` § *Updating the spec later*; a changed criterion is a send back.
- Dropping an item — a `git mv` into `Dropped/` per `backlog-add` § *Lifecycle*; an unmerged branch is then the user's to delete.
