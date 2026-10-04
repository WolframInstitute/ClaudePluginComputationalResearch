# Several sessions on one backlog

*[ LLM Generated ]*

> Type: investigation
> Waiting on: you — open question 1, and the Agent View trial.
<!-- Status is the folder: Backlog/ Ready/ Active/ UnderReview/ Done/ Dropped/. Move the file to change it. -->

## Summary

Several sessions may work the same backlog at once: the operator's own, the agents', a colleague's.
An item is claimed by its branch: whoever works it does so on the item's own branch in its own worktree, and git lets a branch be checked out only once.
The Work folders stay the one list; a kanban tool, if one is used, is a view of it.

## Motivation

- Today only the autonomous workers run in worktrees; an interactive session works in the checkout, so two sessions can start the same item and the second one sees the first one's half-done files.
- The operator asked whether an outside kanban tool for Claude Code sessions can take this over.
- A colleague joining a project needs a rule they can follow without the plugin.

## Acceptance criteria

The README's *Several sessions at once* paragraph is true:

- Two sessions cannot take the same item; the second one is told who has it.
- A session working an item never sees another session's uncommitted work.
- An item's branch and worktree are named by one rule, the same for interactive and autonomous sessions.
- Sessions are watched and steered in Claude Code's Agent View, and a trial confirms it is enough.

## Prompt history

- 2026-10-03 — "Also regarding the backlog we want to explore the possibility how to deal with multiple agents/claude sessions working on different things in the backlog. There is github.com/langwatch/kanban-code. Could we possibly use it? Does it require the backlog to be in github online? In that case it should be in the dev repos."
- 2026-10-04 — "We need to turn board into something like vibe-kanban where we will also see the work items being done by multiple sessions, where i could start multiple sessions and view their output and communicate with them... like a control interface.. Is it the best to build our own board or would it be the best to make our backlog into github backlog and kanban board and use some standard orchestrator"
- 2026-10-04 — "lets not use the vibe kanban etc and lets use the default the agentic view. If it brings what i want.... but then it should be somehow connected with our board that i can click there for agent to process"
- 2026-10-04 — "well okey it is not such a problem not to connect the board then, forget it if it is too bad"

## Technical details

### What exists

- `autolab` isolates each item in `~/.cache/autolab/<Repo>/<Item>` on `auto/<Item>`, outside the cloud-synced repo, and halts `worktree-busy` when git refuses the branch; that refusal is the only exclusivity the plugin has today.
- Paclet-dev items use `work/<item>` worktrees for the paclet submodule only.
- An interactive `next-session` moves the item `Ready/` → `Active/` in the checkout and commits; a second session started before that commit lands takes the same item.

### Kanban Code (langwatch/kanban-code, read 2026-10-03)

- A native macOS app (macOS 26 or later; this machine qualifies), Apache-2.0, 327 stars, created 2026-02-28, last push 2026-10-03, last release v0.1.32 on 2026-08-10.
- A card is a Claude Code session: it discovers sessions in `~/.claude/projects/`, runs each in tmux, moves cards by Claude Code hooks (In Progress / Waiting / In Review / Done), and sends push notifications.
- Its backlog is local, in `~/.kanban-code/links.json`, per machine; cards are made in the app or imported from GitHub issues through `gh`. It does not need GitHub. It does not read markdown, and the `kanban` CLI has no command to create a card.
- It creates worktrees at `<repo>/.claude/worktrees/<name>`, inside the repo, which in a Dropbox or OneDrive folder races the sync daemon (see `CLAUDE.md` § *MathNotebook*).
- It has grown servers, cloud machines and a secrets vault; the board is a part of a larger system.

So it is a session manager, not a backlog: it would be a second store beside `Work/` unless every Ready item were mirrored to a GitHub issue in its dev repo, and even then the issue would hold only a link and the start prompt.
vibe-kanban has the same shape: tasks in its own store, one worktree per task, logs, follow-ups and diff review.

### Agent View (Claude Code 2.1.289, read 2026-10-04)

- `claude agents` lists every session on the machine, interactive and background, and dispatches, attaches to and replies to them; Remote Control reaches the same sessions from the phone.
- `claude --bg -n <name> "<prompt>"` starts a background session that appears there at once; `claude agents --json` prints each session's `cwd`, `name` and `status` for scripts.
- An item is started by dispatching `/computational-research:next-session <Item>` from Agent View, or by `/autolab` for several.
- `-w` puts the worktree at `<repo>/.claude/worktrees/`, inside the synced folder; the item's worktree is made outside it instead.
- Not built, kept for later: a "Start agent" button on the board that queues a start in `pending.json`, which the next sync dispatches as `claude --bg -n <Item>` in the item's worktree, and card statuses read from `claude agents --json` at sync.

### The claim

The claim is the branch plus the worktree, for every session:

- One branch name per item, `work/<Item>`, replacing `auto/<Item>`; the worktree outside the repo as `autolab` does it.
- `next-session` starts an item by creating or reusing that worktree; if git refuses because the branch is checked out elsewhere, it stops and names the worktree that has it.
- Merging the branch is the review (see [BacklogLifecycle](BacklogLifecycle.md)), for interactive and autonomous work alike.

### Edge cases & out of scope

- An abandoned worktree holds the claim forever; `backlog` reports worktrees whose item has no commit in a week.
- Out of scope: any shared server; two machines on one repo (the branch is then the claim through the remote).

### Open questions

1. One branch name for both paths, `work/<Item>`, with the paclet-dev worktrees keeping their own rule?
2. ~~Trial Kanban Code?~~ Answered 2026-10-04: no; Agent View instead.
3. ~~Mirror Ready items to GitHub issues?~~ Answered 2026-10-04: no; the backlog stays in `Work/`.

## Tasks

- [ ] T1 (human) — decide open question 1.
- [ ] T2 (model: opus, effort: high — protocol writing) — the claim in `next-session`: worktree per item for interactive sessions, the stop on a busy branch, the shared branch name with `autolab` and `auto-run.sh`.
- [ ] T3 (human) — a week of Agent View on a real project, items started by dispatching `next-session`; record whether it is enough, and whether the board's Start button is wanted after all.
- [ ] T4 (model: sonnet, effort: high) — parallel `/autolab` trial, moved from `InSessionAutoRun` T5: two throwaway items with `--parallel 2`, each in its own worktree; neither tree touched by the other; the operator's checkout never switched.
- [ ] T5 (model: sonnet, effort: high — doc pass) — README, AutonomousPipeline article, version bump.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Fresh item.
The README paragraph *Several sessions at once* was written on 2026-10-03.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-10-04 | No link from the board to sessions for now | The board is a claude.ai page and cannot start a local process; a click could only act at the next sync. The operator does not need it yet; the design is kept in Technical details |
| 2026-10-04 | Sessions are run and watched in Claude Code's Agent View; no vibe-kanban, Kanban Code, GitHub Projects or own controller | Agent View already dispatches, shows and steers sessions, with Remote Control for the phone; the outside tools keep a second task store, and the GitHub orchestrators run in the cloud without the Wolfram kernel |
| 2026-10-03 | `Work/` stays the one store; Kanban Code, if used, is a view | its backlog is a per-machine JSON of sessions, not items; a second store forks the list. Proposed by the LLM, open to change |

## Progress

- **S0** 2026-10-03 — item filed from the operator's request; Kanban Code read from its README and source.
- 2026-10-04 — Agent View chosen over outside kanban tools and an own controller; board–session link deferred (operator decision).
- 2026-10-05 — parallel `/autolab` trial taken over from `InSessionAutoRun` (its T5) as T4.
