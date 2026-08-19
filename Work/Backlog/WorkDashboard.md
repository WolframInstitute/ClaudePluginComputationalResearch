# WorkDashboard

*[ LLM Generated ]*

> Type: investigation
<!-- Status is the folder: Active/ Backlog/ Done/ Dropped/. Move the file to change it. -->

## Spec

Origin: "In the future I would like to add some local web-based dashboard with access to the wiki and to the project work status and details." (2026-08-19.)

A project run under this plugin keeps its state in two plain-markdown trees: `Wiki/` (durable knowledge) and `Work/` (board, items, run digests).
Both are built to be read in an editor, which is fine for the session and poor for the operator: seeing where a project stands means opening half a dozen files.
The deliverable is a **local, read-only web dashboard** pointed at one project repo:

- the board — Active / Backlog / Done / Dropped, with each active item's next task and its model annotation (see `ModelRouting`);
- item pages — Spec / Tasks / Hand-off / Decisions rendered, checkboxes shown as state;
- the wiki — rendered pages with working relative links between articles;
- runs — `Work/Runs/` digests, and a live tail while `/auto-run` is executing.

### Constraints

- **Markdown stays the source of truth.** The dashboard renders the files; it never becomes a second store.
- **Read-only in v1.** No checkbox toggling, no item moves, no run-launch button — those are write actions against the repo and belong to a later item if ever.
- **Zero build step.** It must start with one command on a stock machine (`/dashboard` → a script serving the current repo); no npm install, no bundler, no daemon left running.
- **Project-agnostic.** Pointed at any repo that follows the plugin layout (SyntheticInfrageometry is the first real target), not wired to this one.

### Design questions for T1 (decide before building)

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

Fresh item; nothing in flight.
Depends on nothing, but renders `ModelRouting`'s task annotations if that lands first — keep the board view tolerant of their absence.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-19 | v1 is read-only | Write actions change the repo's integrity story (hooks, revise protocol) and are not needed to see project state |
| 2026-08-19 | Markdown remains the single store; the dashboard is a view | A second store would fork the wiki's one-destination rule |

## Progress

- 2026-08-19 — item filed from the SyntheticInfrageometry walk-family session (operator request).
