# Several sessions on one backlog

*[ LLM Generated ]*

> Type: investigation
> Waiting on: you — the open questions, and whether to trial Kanban Code.
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
- Whether Kanban Code is used beside the plugin is decided from a trial, and the decision is recorded.

## Prompt history

- 2026-10-03 — "Also regarding the backlog we want to explore the possibility how to deal with multiple agents/claude sessions working on different things in the backlog. There is github.com/langwatch/kanban-code. Could we possibly use it? Does it require the backlog to be in github online? In that case it should be in the dev repos."

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
2. Trial Kanban Code for a week as a view over the sessions, with cards started by hand on `/computational-research:next-session <Item>`, before deciding?
3. If its GitHub import is wanted, mirror Ready items to issues in each dev repo, or not at all?

## Tasks

- [ ] T1 (human) — decide the open questions; install Kanban Code if the trial is wanted.
- [ ] T2 (model: opus, effort: high — protocol writing) — the claim in `next-session`: worktree per item for interactive sessions, the stop on a busy branch, the shared branch name with `autolab` and `auto-run.sh`.
- [ ] T3 (human) — the Kanban Code trial, if chosen; record the ruling in the Decisions table and a wiki resource article.
- [ ] T4 (model: sonnet, effort: high — doc pass) — README, AutonomousPipeline article, version bump.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Fresh item.
The README paragraph *Several sessions at once* was written on 2026-10-03.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-10-03 | `Work/` stays the one store; Kanban Code, if used, is a view | its backlog is a per-machine JSON of sessions, not items; a second store forks the list. Proposed by the LLM, open to change |

## Progress

- **S0** 2026-10-03 — item filed from the operator's request; Kanban Code read from its README and source.
