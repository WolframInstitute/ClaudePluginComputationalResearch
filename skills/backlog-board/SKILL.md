---
name: backlog-board
description: >
  Publish and sync the work board — a private claude.ai page, readable on a
  phone, that shows every Work/ item under a root (one repo or a folder of
  repos): what needs the user, what is under review, active, ready and in the
  backlog, each item rendered and clickable. On the page the user edits the
  human sections, approves moves (Backlog → Ready, Accept, Send back), leaves
  notes, files new items and asks Claude about an item; those changes wait on
  the page until a session syncs them into the files. Use for: "sync the
  board", "refresh the board", "publish the board", "set up a board", or the
  /backlog-board command. Never on a timer — a sync is always the user's request.
---

# The work board

A web view of `Work/` for the human, built from the same markdown the sessions read.
The files stay the one source of truth: the page is a snapshot of them plus a queue of the user's changes, and a **sync** is the only thing that moves changes between the two.
The item format and the folders are in [`backlog-add`](../backlog-add/SKILL.md); the division of labour on an item is [`backlog-refine`](../backlog-refine/SKILL.md)'s.

## What lives where

- **The page** — [board.html](board.html), a fixed page published once as an Artifact with the capabilities `artifact`, `comments` (composer only), `sample` and `user`. It reads two data files published beside it.
- **`data/board.json`** — the snapshot, written by `${CLAUDE_PLUGIN_ROOT}/scripts/work-board-build.py <root> <out>`: every item's title, summary, progress, next task and full markdown.
- **`data/pending.json`** — the user's queued changes, written by the page itself (the `artifact` capability's files form): `edits` per item id (`sections`, `move`, `notes`, `kept` Claude answers) and `newItems`.
- **Comments** — claude.ai's own comment threads on the page; the page only opens the composer on a section.
- **`<root>/.claude/work-board.json`** — `{ "url": …, "title": … }`, so any later session finds the board. Commit it where the root is a repo.

## Set up a board

1. Pick the root (the repo, or the folder holding several repos) and a title — the project's name plus "Backlog", two to four words.
2. Build into a scratch folder: `work-board-build.py <root> <scratch>/data/board.json`, write `{"edits":{},"newItems":[]}` to `<scratch>/data/pending.json`, and copy `board.html` to `<scratch>/index.html` with `{{BOARD_TITLE}}` replaced.
3. Publish `<scratch>/index.html` with `files` for the two data files, `capabilities: {"artifact": {}, "comments": {"composer_only": true}, "sample": {}, "user": {}}`, and a one-line description.
4. Write `<root>/.claude/work-board.json`, and offer once to pin the board to the sidebar.

## Sync the board

Only when the user asks — from the laptop, or from the phone through Remote Control.

1. Read `<root>/.claude/work-board.json`. Read the artifact's `data/pending.json` and `data/board.json` with the Artifact tool (`action: "read"`, `path`), and its open comments with `ArtifactComments`.
2. If `pending.json` holds anything, run `work-board-sync.py <pending> <board> <root>` (`--dry-run` first if unsure). It applies, deterministically:
   - section edits — the user's words, verbatim, into Summary / Motivation / Acceptance criteria (a missing section is inserted in its place);
   - notes — one quoted, dated line each in `## Prompt history`;
   - moves — `git mv` between folders, with the date prefix into `Done/` or `Dropped/`;
   - new items — a Backlog file from the user's title, summary and motivation.

   It prints a JSON report and commits nothing.
3. Do what the report leaves to judgement, as `backlog-refine` would: fold each note and kept answer into Technical details, the open questions or a Decisions row; update each touched repo's `Work/README.md` for the moves. An **Accept** is the user's review — the item goes to `Done/`. A **Send back** needs a new task: write one from the user's note, and if there is no note, ask.
4. Answer or resolve the comments that asked for something, in their threads.
5. Commit each touched repo (`docs(work): sync from the board`), never push.
6. Rebuild `board.json` from the files, reset `pending.json` to empty, and republish the same page to the board's `url` with both data files. If the publish is refused because the page changed since step 1, the user saved something meanwhile: read `pending.json` again and repeat from step 2 for the new changes only.
7. Tell the user in two or three lines what changed and in which repos.

## Refresh the board

The same as step 6, for when the files changed but the user queued nothing.
If `pending.json` is not empty, sync instead — a refresh must never drop a queued change.

## When NOT to use

- Shaping an item in a long sitting — that is `backlog-refine`, in a session with the code at hand.
- Anything on a schedule or in a loop: the user asked for syncing to stay manual.
