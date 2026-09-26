# WorkDashboard

*[ LLM Generated ]*

> Type: investigation
> Waiting on: you — the first `/refine` sitting; the 2026-09-26 requests below reopen the read-only constraint.
<!-- Status is the folder. Move the file to change it. -->

## Spec

Origin: "In the future I would like to add some local web-based dashboard with access to the wiki and to the project work status and details." (2026-08-19.)
Reshaped 2026-09-26: "It would be great if the backlog could be edited interactively with human and AI somehow in web or wherever … I am still thinking of having some browser dashboard for dealing with the backlog."
And: "the dashboard should be also somehow reachable from phone (iphone) … perhaps there already are some solutions withing claude etc of some backlog management and agentic orchestrator... if not perhaps we should build an ios app or seomthing like that"

A project run under this plugin keeps its state in two plain-markdown trees: `Wiki/` (durable knowledge) and `Work/` (board, items, run digests).
Both are built to be read in an editor, which is fine for the session and poor for the operator: seeing where a project stands means opening half a dozen files.
The deliverable is a **local, read-only web dashboard** pointed at one project repo:

- the board — Backlog / Ready / Active / UnderReview / Done / Dropped, with each active item's next task and its model annotation (see `ModelRouting`), and each UnderReview item's test instructions;
- item pages — Spec / Tasks / Hand-off / Decisions rendered, checkboxes shown as state;
- the wiki — rendered pages with working relative links between articles;
- runs — `Work/Runs/` digests, and a live tail while `/auto-run` is executing.

### Constraints

- **Markdown stays the source of truth.** The dashboard renders the files; it never becomes a second store.
- **Editing is now wanted** (2026-09-26): the human edits an item's human sections in the browser and the AI takes part — the `refine` loop, in a page. Item moves stay the human's clicks, and each one is a commit.
- **Zero build step.** It must start with one command on a stock machine (`/dashboard` → a script serving the current repo); no npm install, no bundler, no daemon left running.
- **Reachable from an iPhone** (2026-09-26): read the board, edit the human sections, review an UnderReview item, and start a Ready item, from the phone. The worker stays the Mac: most tasks need the local Wolfram kernel and licence, which a cloud VM does not have.
- **Project-agnostic.** Pointed at any repo that follows the plugin layout (SyntheticInfrageometry is the first real target), not wired to this one.

### Design questions for T1 (decide before building)

- What already covers the phone, before anything is built (surveyed 2026-09-26, docs at code.claude.com/docs/en/): **Remote Control** drives a live Claude Code session on the Mac from the Claude iOS app, with the Mac's files, MCP servers and plugin, plus push notifications when a task finishes or needs input — so a `/refine` sitting or a review works from the phone today. The repos sit in **Dropbox**, whose iOS app already opens and edits the markdown. **Cloud sessions and routines** need the repo on GitHub and have no Wolfram kernel, so they suit only kernel-free tasks. **GitHub Issues + Projects** has a mature iOS app and `@claude` in issues, but would move the backlog out of markdown. Community Kanban tools for Claude Code sessions exist and were not evaluated. An iOS app is not needed unless all of these fail a trial.
- How the phone reaches the dashboard: a local server exposed over a private network (Tailscale), or a claude.ai Artifact that a Mac session republishes from the files, whose comments come back to that session.
- Where the AI joins the editing. Three shapes, markdown staying the one store in each: (a) the local server runs a headless `claude -p` on the item when the human asks, reusing the `/auto-run` machinery; (b) the page lives on claude.ai as an Artifact or a Claude Doc, where co-editing and comments already exist, synced back to the repo — a second store and a cloud copy of a private project; (c) the editor stays VS Code, where the human and Claude Code already co-edit, and the dashboard is only the overview. (a) is the default candidate.

- Live server rendering markdown per request vs. static regeneration on file change — mtime polling is probably enough for one user on localhost.
- Stack: smallest thing that renders markdown and serves files (Python stdlib + one markdown library is the default candidate); no framework unless a requirement forces one.
- One project per instance vs. a project switcher — one per instance is simpler and matches how the operator works.
- Whether existing markdown-site tools already do 90% of this and only the board view needs writing.

## Tasks

- [ ] T1 — design: survey existing markdown-serving tools against the constraints, pick the stack, and write the design as a wiki concept article; correct this Spec where it guessed.
- [ ] T2 — implement v1: the serving script under `scripts/`, a `/dashboard` command, board + item + wiki + runs views, README row.
- [ ] T3 (human) — operator trial against the SyntheticInfrageometry repo; rule on what v2 (if any) may write.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

A first version shipped on 2026-09-26 (5.2.0) as the [`board`](../../skills/board/SKILL.md) skill, built live with the operator rather than through this item's tasks: a claude.ai Artifact over `data/board.json`, with page-side edits of the human sections, move approvals, notes, new items and in-page "Ask Claude" queued in `data/pending.json` and applied by a manual sync. It answers the phone and co-editing constraints by way (b) of the design questions, not the default (a). What is left for T1–T3: the local-server alternative, the wiki view, `Work/Runs/` digests, and whether the item should be closed as done by the skill.
Depends on nothing, but renders `ModelRouting`'s task annotations if that lands first — keep the board view tolerant of their absence.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-09-26 | v1 may edit items, and every edit is a commit (reverses the 2026-08-19 read-only row) | The operator wants to shape the backlog in the browser together with the AI; committing each save keeps git the audit trail |
| 2026-08-19 | Markdown remains the single store; the dashboard is a view | A second store would fork the wiki's one-destination rule |

## Progress

- 2026-08-19 — item filed from the SyntheticInfrageometry walk-family session (operator request).
- 2026-09-26 — first version shipped as the `board` skill in a live session (operator request); see Hand-off.
