# Several sessions on one backlog

*[ LLM Generated ]*

> Type: investigation
> Autonomous: allowed
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
- 2026-10-05 — chose "work/<Item> everywhere" for the branch name.

## Technical details

### What exists

- `backlog-autolab` isolates each item in `~/.cache/autolab/<Repo>/<Item>` on `auto/<Item>`, outside the cloud-synced repo, and halts `worktree-busy` when git refuses the branch; that refusal is the only exclusivity the plugin has today.
- Paclet-dev items use `work/<item>` worktrees for the paclet submodule only (`skills/backlog-run/paclet-worktree.md`); the new name matches them.
- An interactive `backlog-run` moves the item `Ready/` → `Active/` in the checkout and commits; a second session started before that commit lands takes the same item.

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
- An item is started by dispatching `/computational-research:backlog-run <Item>` from Agent View, or by `/backlog-autolab` for several.
- `-w` puts the worktree at `<repo>/.claude/worktrees/`, inside the synced folder; the item's worktree is made outside it instead.
- Not built, kept for later: a "Start agent" button on the board that queues a start in `pending.json`, which the next sync dispatches as `claude --bg -n <Item>` in the item's worktree, and card statuses read from `claude agents --json` at sync.

### The claim

The claim is the branch plus the worktree, for every session:

- One branch name per item, `work/<Item>`, replacing `auto/<Item>` in `backlog-autolab`, `backlog-run-scheduled` (`scripts/auto-run.sh`), `backlog-review`, `backlog-info`, `backlog-board` and `document-revise`; the worktree outside the repo, as `backlog-autolab` makes it.
- `backlog-run` starts an item by creating or reusing that worktree; if git refuses because the branch is checked out elsewhere, it stops and names the worktree that has it.
- Merging the branch is the review (see [BacklogLifecycle](BacklogLifecycle.md)), for interactive and autonomous work alike.

### Edge cases & out of scope

- An abandoned worktree holds the claim forever; `backlog-info` reports worktrees whose item has no commit in a week.
- Branches made before the rename (`auto/BacklogLifecycle`, and those of any run before T2 lands) are still found: `backlog-review` and `backlog-info` read `auto/*` beside `work/*` until none is left.
- A paclet-dev item has `work/<Item>` in the dev repo and in the paclet submodule: two repos, one name.
- Out of scope: any shared server; two machines on one repo (the branch is then the claim through the remote).

## Tasks

- [ ] T3 (human) — a week of Agent View on a real project, items started by dispatching `/backlog-run <Item>`; record whether it is enough, and whether the board's Start button is wanted after all.
- [ ] T4 (human) — parallel `/backlog-autolab` trial, moved from `InSessionAutoRun` T5: two items with `--parallel 2`, each in its own worktree; neither tree touched by the other; the operator's checkout never switched. An orchestrator runs it, so it is yours to start; a worker cannot dispatch workers.
- [ ] T5 (model: sonnet, effort: high — doc pass) — README, AutonomousPipeline article, version bump.

### Done

- [x] T2 (S1) (model: opus, effort: high — protocol writing) — the claim in `backlog-run`: a worktree per item for interactive sessions, the stop on a busy branch naming its worktree; `work/<Item>` in every skill and script that names `auto/<Item>`, legacy `auto/*` still read; `bash scripts/test-auto-run-routing.sh` passes.
  - **Test:** run `bash scripts/test-auto-run-routing.sh` — `59 passed, 0 failed`, with four checks under "the claim": a branch held by another worktree is refused and the refusal names it, a released branch is taken again, an unmerged `auto/` branch is continued.
  - **Test:** open [backlog-run § *Claim it*](../../skills/backlog-run/SKILL.md#claim-it) and step 9 — the branch `work/<Item>`, the worktree `~/.cache/autolab/<Repo>/<Item>`, the stop on git's refusal naming the worktree, the worktree removed when the session ends.
  - **Test:** run `git grep -n "auto/" -- skills commands scripts` — every hit reads a legacy `auto/<Item>` beside `work/<Item>`, or is the test's own fixture.
  - **Test:** in a throwaway repo, `git worktree add -b work/X ../a HEAD && git worktree add ../b work/X` — the second is refused: `'work/X' is already used by worktree at '…/a'`.
- [x] T1 (human) — decided in the 2026-10-05 refinement: `work/<Item>` everywhere, see Decisions.
  - **Test:** the Decisions table has the 2026-10-05 branch-name row.

## Hand-off

T2 done; T3 and T4 are the operator's, T5 the next agent task.
The README paragraph *Several sessions at once* was written on 2026-10-03; it still links `Work/Ready/ParallelSessions.md`.
For T5: `Wiki/Concepts/AutonomousPipeline.md` still describes the branch as `auto/<Item>` (its design sections, about ten places); the runbook, `Status.md` and the skills already say `work/<Item>`.
For T4: a `/backlog-autolab --parallel 2` run that works this item beside another counts, if its digests in `Work/Runs/` show the three checks.
`/backlog-run-scheduled` refuses a claimed item but still works in the checkout, not in a worktree; it needs a clean tree, so it sees no one's uncommitted work.
The worktree path keeps the name `~/.cache/autolab/` for interactive sessions too.

- needs-human: a paclet-dev repo (one with `.gitmodules`) is not claimed yet — `backlog-run` works there in the checkout as before, since a dev-repo worktree has no submodules checked out and [paclet-worktree.md](../../skills/backlog-run/paclet-worktree.md) commits the dev-repo tracking to `main`. Should such an item also get `work/<Item>` in the dev repo, with `Work/` and `Wiki/` committed there and merged at review (Technical details: "two repos, one name")? If yes, a new task rewrites `paclet-worktree.md` and tries a dev-repo worktree with its submodule.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-10-05 | The worktree is the claim: an interactive session makes it at start and removes it at the end, and a driver holds it for its run; `/backlog-autolab` no longer reuses a leftover worktree but halts `worktree-busy` on it | git's refusal is then the whole check, with no lock file; a worktree that outlives its session marks an abandoned or unfinished one, which `backlog-info` reports. Proposed by the LLM in T2, open to change |
| 2026-10-05 | One branch name per item, `work/<Item>`, for interactive and autonomous sessions; it replaces `auto/<Item>` | one rule a colleague can follow without the plugin, and it already names the paclet-dev worktrees; your call |
| 2026-10-04 | No link from the board to sessions for now | The board is a claude.ai page and cannot start a local process; a click could only act at the next sync. The operator does not need it yet; the design is kept in Technical details |
| 2026-10-04 | Sessions are run and watched in Claude Code's Agent View; no vibe-kanban, Kanban Code, GitHub Projects or own controller | Agent View already dispatches, shows and steers sessions, with Remote Control for the phone; the outside tools keep a second task store, and the GitHub orchestrators run in the cloud without the Wolfram kernel |
| 2026-10-03 | `Work/` stays the one store; Kanban Code, if used, is a view | its backlog is a per-machine JSON of sessions, not items; a second store forks the list. Proposed by the LLM, open to change |

## Progress

- **S0** 2026-10-03 — item filed from the operator's request; Kanban Code read from its README and source.
- 2026-10-04 — Agent View chosen over outside kanban tools and an own controller; board–session link deferred (operator decision).
- 2026-10-05 — parallel `/autolab` trial taken over from `InSessionAutoRun` (its T5) as T4.
- **R1** 2026-10-05 — refined with the operator: branch name `work/<Item>` decided (T1), T2 and T4 re-cut; moved to Ready.
- **S1** 2026-10-05 T2 — the claim: `work/<Item>` in its worktree for every session, the stop on a busy branch, legacy `auto/` read. → [backlog-run § Claim it](../../skills/backlog-run/SKILL.md#claim-it), [runbook](../../Wiki/Concepts/AutoRunOperations.md#landing-workitem-on-main), [Status](../../Wiki/Status.md)
