# Architecture

Reference inventory for the plugin: layout, scripts, commands, templates, project types, and the notebook conversion engines.

Read this when you need it — it is **not** auto-loaded.
`CLAUDE.md` carries only the policy a session must know before it can know it needs to look something up.

## The three places

Every folder that holds documents (`Code/`, `Research/`, and `Artifacts/` itself) has the same three places: the folder itself for documents in progress, `Artifacts/` for what the plugin made once, `Archive/` for what is superseded.
The plugin never overwrites a file; outside `Artifacts/` it writes only on request — `document-revise` § *Protected content*.
`paper-create-note` and `paper-create-notebook` write to `Research/`, `notebook-create` to `Code/`, `paper-create` always to `Research/`: a document in progress goes in the folder, a one-off or an unsaid request in its `Artifacts/`.
There is no `Paper/` folder; a project that already has one keeps using it, and nothing is moved.
`Archive/` is created lazily by `/project-clean`, one per folder, `Artifacts/Archive/` included.
An artifact is one dated stem (`<WhatItSettles>_YYMMDD`) shared by whatever files it needs, flat until it grows its own code, data, bibliography or build; then the folder takes the stem and the files inside go bare.
Every file of an artifact is tracked except a generated `.nb`, whose `.md` source is tracked instead, and nothing is uploaded to the Cloud unless the user asks.
The canonical statement is [skills/notebook-create/artifacts.md](skills/notebook-create/artifacts.md); the producers, `document-revise` and `project-clean` reference it rather than restating it.

## Layout

```
.claude-plugin/plugin.json     — plugin metadata and version
skills/*/SKILL.md              — skill definitions (auto-discovered)
skills/*/<topic>.md            — read-on-demand sibling docs, kept out of the unconditional read
                                 (e.g. backlog-run/paclet-worktree.md, paclet-dev only)
skills/notebook-create/artifacts.md — the three-places convention, shared by the producers, `document-revise` and `project-clean`
scripts/                       — bash and wolframscript utilities
commands/                      — slash command definitions
agents/                        — subagent definitions (the autolab workers, one per effort level)
hooks/                         — PreToolUse hooks (e.g., block .nb reads)
skills/project-create/assets/    — templates for scaffolding
Wiki/                          — knowledge base: external dependencies, concepts
Work/                          — execution state (spec/tasks/hand-off/decisions/progress per item)
ARCHITECTURE.md                — this file
```

## Skills (27)

The skills are listed by area in [README.md](README.md) § *Functionality*, the only human-facing copy.
Each skill's own `description:` frontmatter is injected into every session by the harness, so a third summary here would be a copy of a copy.

## Scripts (32)

| Script | Language | Called by |
|--------|----------|----------|
| `scaffold-project.sh` | bash | project-create (research type) |
| `scaffold-math-project.sh` | bash | project-create (math-research type) |
| `scaffold-paclet-dev.sh` | bash | project-create (paclet-dev type) |
| `scaffold-paclet.sh` | bash | project-create (paclet type) |
| `scaffold-paper.sh` | bash | paper-create skill (`--name` names the paper, `--subfolder` gives it its own directory, `--typst` for Typst; refuses to overwrite an existing source without `--force`, and reuses a `macros`/`references.bib` already in the folder) |
| `scaffold-journal.sh` | bash | paper-journal skill (`--typst` for Typst) |
| `build_paclet.wls` | wolframscript | paclet-build skill |
| `publish_paclet.wls` | wolframscript | paclet-publish skill |
| `paclet_common.wl` | wolframscript | shared helper (build_paclet.wls, publish_paclet.wls); stages every top-level paclet item |
| `deploy_paclet_docs.wl` | wolframscript | paclet-publish skill (Get through the MCP); deploys Documentation/ pages as public cloud notebooks + HTML index, rewriting `paclet:` links |
| `search_wolfram_docs.wls` | wolframscript | wiki-search-wolfram skill |
| `search_function_repo.wls` | wolframscript | wiki-search-wolfram skill |
| `search_wolfram_community.wls` | wolframscript | wiki-search-wolfram skill (URL constructor) |
| `search_wolfram_writings.wls` | wolframscript | wiki-search-wolfram skill |
| `search_wolfram_physics.wls` | wolframscript | wiki-search-wolfram skill |
| `search_mathworld.wls` | wolframscript | wiki-search-math skill |
| `search_nlab.wls` | wolframscript | wiki-search-math skill |
| `search_oeis.wls` | wolframscript | wiki-search-math skill |
| `search_dlmf.wls` | wolframscript | wiki-search-math skill |
| `search_wikipedia_math.wls` | wolframscript | wiki-search-math skill |
| `cite_from_id.wls` | wolframscript | paper-cite skill |
| `mathnotebook_post.wl` | wolframscript | paper-create-notebook skill (Get through the MCP; marker → MathNotebook environment cells, embedded stylesheet, plus the generator passes `ReadCellTags` / `FoldExampleGroups` / `AssignCellIDs` / `ResearchHeadCells`) |
| `source_lines.wl` | wolframscript | notebook-create, paper-create-note, paper-create-notebook and the document-revise round (Get through the MCP; `SourceLineNotebook` stamps each generated cell with its `.md` lines, `ShiftSourceLines` / `StampSourceLines` keep them in step during a round) |
| `commit-msg` | sh | git hook copied into projects (`.githooks/`); enforces Conventional Commits |
| `check-env.sh` | bash | project-check-env command |
| `auto-run.sh` | bash | backlog-run-scheduled command; drives `backlog-run` unattended, one cold `claude -p` per task, onto `work/<Item>`, each task on the model and effort its own routing annotation names |
| `work-board-build.py` | python | backlog-board skill; collects every `Work/` item under a root into the board's `data/board.json` |
| `work-board-sync.py` | python | backlog-board skill; applies the page's queued `data/pending.json` — section edits, notes, moves, new items — to the `Work/` files, commits nothing |
| `test-auto-run-routing.sh` | bash | nothing — run by hand after a change to `auto-run.sh`'s annotation parse; 36 assertions against fixture items and a stub `claude`, spends nothing |
| `recover_resources.sh` | bash | copied into projects, also wiki-add-resource |
| `generate_notebooks.wls` | wolframscript | copied into projects |
| `publish_notebooks.wls` | wolframscript | copied into projects |

## Commands (31)

Every skill has a slash command of the same name, `/computational-research:<skill>`; `document-revise` is also the protocol every other skill follows, and its command runs one revision round ([round.md](skills/document-revise/round.md)), reading and writing the document's `<stem>.provenance.md` (format: `skills/project-provenance/SKILL.md` § *Document provenance*, always on for a revised document, unlike the prompt ledger).
Four commands have no skill behind them:

| Command | Runs |
|---------|------|
| `project-check-env` | `scripts/check-env.sh` + an MCP ping; reports live license headroom |
| `project-load` | reads `Wiki/` + `Work/` status |
| `project-clean` | moves every numbered revision round but the latest into the folder's `Archive/`, by the naming rule in `skills/document-revise/round.md` |
| `backlog-run-scheduled` | `scripts/auto-run.sh`; then reads the digest it names and reports the stop reason — the headless path, kept for cron; `backlog-autolab` is the one to watch |

The `plugin:` prefix is **mandatory** headless — `claude -p "/backlog-run"` is a zero-cost no-op that reports `is_error: false`, while `/computational-research:backlog-run` expands. This is why `backlog-run-scheduled` verifies each run rather than trusting its exit status.

## Agents (6)

| Agent | Used by |
|-------|---------|
| `autolab-worker` | `backlog-autolab`, for a task whose annotation names no effort — inherits the session's |
| `autolab-worker-<effort>` | `backlog-autolab`, one each for `low`, `medium`, `high`, `xhigh`, `max`; the `Agent` tool has no effort parameter, so the definition carries it and the call's `model` sets the tier |

## Templates (in skills/project-create/assets/)

Scaffolding templates use `{{PLACEHOLDER}}` syntax processed by `sed`.

| Template | Purpose |
|----------|---------|
| `claude_template.md` | CLAUDE.md for research projects |
| `math_claude_template.md` | CLAUDE.md for math-research projects |
| `math_categories_template.md` | Math-domain taxonomy seed (adapted from PureMath) |
| `notebook_theorem_proof_template.md` | Theorem-proof notebook skeleton (used by notebook-create) |
| `formal_definition_template.md` | Wiki/Definitions/ article template |
| `formalization_checklist_template.md` | Work/Backlog/Formalize-*.md skeleton, a Type: formalization work item (used by paper-lean) |
| `work_item_template.md` | Work item skeleton: a human-first Spec (Summary / Motivation / Acceptance criteria / Prompt history / Technical details), then Tasks / Hand-off / Decisions / Progress (used by backlog-add, backlog-run); the ten sections are the whole file, status is the folder (Backlog/Ready/Active/UnderReview/Done/Dropped) |
| `work_readme_template.md` | Work/README.md active-item index, seeded by the scaffolds |
| `code_style_template.md` | Code-style rules (input, layout, naming, mathematical objects, exported functions, graphics, snippets, comments, testing, commits) + the `Semantic line breaks` (one-sentence-per-source-line) toggle, appended to every generated CLAUDE.md (research, math-research, paclet-dev, paclet) |
| `artifacts_index_template.md` | Index of an `Artifacts/` folder, one text for `Code/` and `Research/` (used by all three project scaffolds) |
| `project_readme_template.md` | The project's own README: states the three places and that papers live in `Research/` (used by the scaffolds) |
| `main_template.tex` | LaTeX article (amsart, uses macros.sty) |
| `macros_template.sty` | Shared LaTeX preamble: fonts, math, biblatex, theorems, macros |
| `main_template.typ` | Typst article (imports macros.typ, native bibliography) |
| `macros_template.typ` | Shared Typst preamble: style, math shorthand, theorem blocks |
| `journal_template.tex` | LaTeX master journal doc (article + macros.sty, \input day-files, \printbibliography) |
| `journal_template.typ` | Typst master journal doc (imports macros.typ, #include day-files, #bibliography) |
| `latexmkrc_template` | latexmk config |
| `tools_starter.wl` | Starter Wolfram code file |
| `pacletinfo_template.wl` | PacletInfo.wl |
| `kernel_main_template.wl` | Paclet main loader (Package + PackageExport + ClearAll) |
| `usage_template.wl` | Usage.wl stub |
| `run_tests_template.wls` | wolframscript test runner (submodule root) |
| `run_all_tests_template.wl` | RunAllTests.wl (Tests/ directory) |
| `readme_paclet_template.md` | Paclet README |
| `gitignore_dev.template` | Dev repo .gitignore |
| `gitignore_submodule.template` | Paclet submodule .gitignore |

Available placeholders: `{{PROJECT_NAME}}`, `{{TOPIC_DESCRIPTION}}`, `{{GOALS}}`, `{{PACLET_NAME}}`, `{{ORG_NAME}}`, `{{AUTHOR}}`, `{{EMAIL}}`, `{{TITLE}}`, `{{ABSTRACT}}`, `{{CODE_DIR}}`, `{{ITEM_NAME}}`.

## Project Types (scaffolding)

The `project-create` skill asks users which type of project to create:

- **research** (default) — Code/Artifacts/, Research/Artifacts/, Wiki/, Work/, Resources/; papers go in Research/.
  Open-ended exploration of a topic.
- **math-research** — Wiki/{Theorems,Definitions,Domains}/ and Work/ pre-created, math-domain taxonomy seeded, optional Lean/ subdirectory.
  Organised around precise theorems and definitions rather than open-ended exploration.
  Pairs with `wiki-search-math`, `paper-cite`, `paper-lean`, and the `theorem-proof` notebook template.
- **paclet-dev** — WolframInstitute-style dev repo with paclet submodules (triple nesting: PacletName/PacletName/Kernel/), Code/ for experimental work, Wiki/, .gitmodules.
  Research/ is tracked; papers go there.
  Work items that change paclet code land as PRs on the paclet submodules — developed on a `work/<item>` branch in a gitignored `<Paclet>--<item>/` worktree — while the dev repo's Wiki and Work stay linear on `main` (see the `backlog-run` skill).
- **paclet** — standalone Wolfram paclet (double nesting), clean repo structure.
  Optional Wiki/.

All paclet types use `Package[]` / `PackageExport` / `PackageScope` (not BeginPackage/EndPackage) for paclet code.
Every exported function is written to stand on its own — liftable out of the paclet and publishable to the Wolfram Function Repository unchanged, which is what rules out the private helper shared between two of them; the rule ships to projects in `code_style_template.md` § *Exported functions*.

## Notebook conversion engines

`notebook-create` has two Markdown→cells engines and picks between them **by inspecting the source**, not by configuration:

- **Built-in** — `ImportString[md, {"Markdown", "Notebook"}]`. The default.
- **Rich** — `WolframInstitute/MarkdownToNotebook`, called as the local clone at pinned SHA `204db7c`, with `Template: Default` and `"Evaluate" -> False`.
  Selected when the source has YAML frontmatter or LaTeX math, and only if `MarkdownToNotebook/` is present; otherwise it falls back to the built-in engine and says so.
  Never clone it silently.

See `Wiki/Resources/MarkdownToNotebook.md` for the pin, the recovery command, and why the reverse direction (`NotebookToMarkdown`) is used nowhere.
`paclet-docs` does **not** use the rich engine — it uses the official MCP doc tools.

`paper-create-notebook` uses the rich engine as the **parser half of a two-half pipeline**: MarkdownToNotebook produces the cells, then `scripts/mathnotebook_post.wl` applies the MathNotebook environments, equation numbering, and citations.
The split is forced, not stylistic — the converter's `::: theorem` / `::: proof` divs exist only under `Template: Chapter` (which swaps in the WolframBookTools stylesheet, absent from a stock install), are **silently dropped** under `Default`, and even under `Chapter` give one `Theorem` style for every label, colliding section-derived numbers, no anchors, no cross-references, and no citations.
That skill generates **one-way**: the `.md` is the source of truth and the user edits it while reading the `.nb`, with a per-cell `CellID` fingerprint stored in `TaggingRules` to detect `.nb` edits and stop a regeneration rather than overwrite them.

Its writing rules live in `skills/paper-create-notebook/style.md`, which `paper-create` reads too — one guide for a paper whether it ships as `.nb`, LaTeX or Typst.
The mechanics (pipeline, conversion call, stylesheet, references) are in the `build.md` sibling, so `SKILL.md` carries authoring conventions and nothing else.

`paper-create-note` uses neither parser: its notebook goes through `notebook-create`'s conversion, ships **unevaluated** (Input cells only, no paclet load), carries `"SourceLines"` in each cell like every generated notebook, and is one of five files sharing a dated stem in `Research/Artifacts/` — a plain `article`-class LaTeX document with its `.pdf`, the notebook source and the notebook, and a loadable `.wl`.
Its first request goes to the document's provenance file, and version 1 of the text files is committed as written, the baseline for hand edits.
Nothing it writes is deployed to the Cloud.

## How to Add a New Skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter (`name`, `description`)
2. Write the body to the **standard skeleton** — every skill carries these four sections, in this order where content allows:
   `## When to use` (triggers), `## Steps` (the procedure, numbered `### 1. Title`), `## Integration with other skills`, `## When NOT to use`.
   Domain sections (policy blocks, formats, references) may sit between them; deep mechanics go to read-on-demand sibling `.md` files next to `SKILL.md` (see `backlog-run/paclet-worktree.md` for the convention)
3. The plugin system auto-discovers skills from the `skills/` directory
4. If the skill needs a script, add it to `scripts/` and reference it via `${CLAUDE_PLUGIN_ROOT}/scripts/<name>`
5. If the skill should have a slash command, create `commands/<name>.md`
6. Add the skill to its area table under README.md § *Functionality*, and update this file's tables
