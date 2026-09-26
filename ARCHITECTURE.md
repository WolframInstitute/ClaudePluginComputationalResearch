# Architecture

Reference inventory for the plugin: layout, scripts, commands, templates, project types, and the notebook conversion engines.

Read this when you need it — it is **not** auto-loaded.
`CLAUDE.md` carries only the policy a session must know before it can know it needs to look something up.

## The artifact convention

Everything the model generates goes into an `Artifacts/` folder, and everything outside one is the user's — the whole of `revise` § *Protected content* reduced to a path check.
`new-research-note` and `new-research-notebook` write to `Research/Artifacts/`, `new-notebook` to `Code/Artifacts/`, `new-paper` to `Paper/`, which is the user's document and not an artifact.
An artifact is one dated stem (`<WhatItSettles>_YYMMDD`) shared by whatever files it needs, flat until it grows its own code, data, bibliography or build; then the folder takes the stem and the files inside go bare.
Every file of an artifact is tracked, `.nb` included, and nothing is uploaded to the Cloud unless the user asks.
The canonical statement is [skills/new-notebook/artifacts.md](skills/new-notebook/artifacts.md); the three producers reference it rather than restating it.

## Layout

```
.claude-plugin/plugin.json     — plugin metadata and version
skills/*/SKILL.md              — skill definitions (auto-discovered)
skills/*/<topic>.md            — read-on-demand sibling docs, kept out of the unconditional read
                                 (e.g. next-session/paclet-worktree.md, paclet-dev only)
skills/new-notebook/artifacts.md — the artifact convention, shared by the three producers
scripts/                       — bash and wolframscript utilities
commands/                      — slash command definitions
agents/                        — subagent definitions (the autolab workers, one per effort level)
hooks/                         — PreToolUse hooks (e.g., block .nb reads)
skills/new-project/assets/    — templates for scaffolding
Wiki/                          — knowledge base: external dependencies, concepts
Work/                          — execution state (spec/tasks/hand-off/decisions/progress per item)
ARCHITECTURE.md                — this file
```

## Skills (25)

The skills are listed by area in [README.md](README.md) § *What it does*, the only human-facing copy.
Each skill's own `description:` frontmatter is injected into every session by the harness, so a third summary here would be a copy of a copy.

## Scripts (31)

| Script | Language | Called by |
|--------|----------|----------|
| `scaffold-project.sh` | bash | new-project (research type) |
| `scaffold-math-project.sh` | bash | new-project (math-research type) |
| `scaffold-paclet-dev.sh` | bash | new-project (paclet-dev type) |
| `scaffold-paclet.sh` | bash | new-project (paclet type) |
| `scaffold-paper.sh` | bash | new-paper skill (`--name` names the paper, `--subfolder` gives it its own directory, `--typst` for Typst; refuses to overwrite an existing source without `--force`, and reuses a `macros`/`references.bib` already in the folder) |
| `scaffold-journal.sh` | bash | journal skill (`--typst` for Typst) |
| `build_paclet.wls` | wolframscript | build-paclet skill |
| `publish_paclet.wls` | wolframscript | publish-paclet skill |
| `paclet_common.wl` | wolframscript | shared helper (build_paclet.wls, publish_paclet.wls); stages every top-level paclet item |
| `deploy_paclet_docs.wl` | wolframscript | publish-paclet skill (Get through the MCP); deploys Documentation/ pages as public cloud notebooks + HTML index, rewriting `paclet:` links |
| `search_wolfram_docs.wls` | wolframscript | search-wolfram skill |
| `search_function_repo.wls` | wolframscript | search-wolfram skill |
| `search_wolfram_community.wls` | wolframscript | search-wolfram skill (URL constructor) |
| `search_wolfram_writings.wls` | wolframscript | search-wolfram skill |
| `search_wolfram_physics.wls` | wolframscript | search-wolfram skill |
| `search_mathworld.wls` | wolframscript | search-math skill |
| `search_nlab.wls` | wolframscript | search-math skill |
| `search_oeis.wls` | wolframscript | search-math skill |
| `search_dlmf.wls` | wolframscript | search-math skill |
| `search_wikipedia_math.wls` | wolframscript | search-math skill |
| `cite_from_id.wls` | wolframscript | cite skill |
| `mathnotebook_post.wl` | wolframscript | new-research-notebook skill (Get through the MCP; marker → MathNotebook environment cells, embedded stylesheet, plus the generator passes `ReadCellTags` / `FoldExampleGroups` / `AssignCellIDs` / `ResearchHeadCells`) |
| `commit-msg` | sh | git hook copied into projects (`.githooks/`); enforces Conventional Commits |
| `check-env.sh` | bash | check-env command |
| `auto-run.sh` | bash | auto-run command; drives `next-session` unattended, one cold `claude -p` per task, onto `auto/<Item>`, each task on the model and effort its own routing annotation names |
| `work-board-build.py` | python | board skill; collects every `Work/` item under a root into the board's `data/board.json` |
| `work-board-sync.py` | python | board skill; applies the page's queued `data/pending.json` — section edits, notes, moves, new items — to the `Work/` files, commits nothing |
| `test-auto-run-routing.sh` | bash | nothing — run by hand after a change to `auto-run.sh`'s annotation parse; 36 assertions against fixture items and a stub `claude`, spends nothing |
| `recover_resources.sh` | bash | copied into projects, also add-resource |
| `generate_notebooks.wls` | wolframscript | copied into projects |
| `publish_notebooks.wls` | wolframscript | copied into projects |

## Commands (27)

Every skill has a slash command of the same name, `/computational-research:<skill>`, except `revise`, which is a protocol other skills follow rather than a command.
Three commands have no skill behind them:

| Command | Runs |
|---------|------|
| `check-env` | `scripts/check-env.sh` + an MCP ping; reports live license headroom |
| `load-project` | reads `Wiki/` + `Work/` status |
| `auto-run` | `scripts/auto-run.sh`; then reads the digest it names and reports the stop reason — the headless path, kept for cron; `autolab` is the one to watch |

The `plugin:` prefix is **mandatory** headless — `claude -p "/next-session"` is a zero-cost no-op that reports `is_error: false`, while `/computational-research:next-session` expands. This is why `auto-run` verifies each run rather than trusting its exit status.

## Agents (6)

| Agent | Used by |
|-------|---------|
| `autolab-worker` | `autolab`, for a task whose annotation names no effort — inherits the session's |
| `autolab-worker-<effort>` | `autolab`, one each for `low`, `medium`, `high`, `xhigh`, `max`; the `Agent` tool has no effort parameter, so the definition carries it and the call's `model` sets the tier |

## Templates (in skills/new-project/assets/)

Scaffolding templates use `{{PLACEHOLDER}}` syntax processed by `sed`.

| Template | Purpose |
|----------|---------|
| `claude_template.md` | CLAUDE.md for research projects |
| `math_claude_template.md` | CLAUDE.md for math-research projects |
| `math_categories_template.md` | Math-domain taxonomy seed (adapted from PureMath) |
| `notebook_theorem_proof_template.md` | Theorem-proof notebook skeleton (used by new-notebook) |
| `formal_definition_template.md` | Wiki/Definitions/ article template |
| `formalization_checklist_template.md` | Work/Backlog/Formalize-*.md skeleton, a Type: formalization work item (used by lean) |
| `work_item_template.md` | Work item skeleton: a human-first Spec (Summary / Motivation / Acceptance criteria / Prompt history / Technical details), then Tasks / Hand-off / Decisions / Progress (used by work, next-session); the ten sections are the whole file, status is the folder (Backlog/Ready/Active/UnderReview/Done/Dropped) |
| `work_readme_template.md` | Work/README.md active-item index, seeded by the scaffolds |
| `code_style_template.md` | Code-style rules + the `Semantic line breaks` (one-sentence-per-source-line) toggle, appended to every generated CLAUDE.md (research, math-research, paclet-dev, paclet) |
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

The `new-project` skill asks users which type of project to create:

- **research** (default) — Code/Artifacts/, Research/Artifacts/, Wiki/, Work/, Resources/, optional Paper/.
  Open-ended exploration of a topic.
- **math-research** — Wiki/{Theorems,Definitions,Domains}/ and Work/ pre-created, math-domain taxonomy seeded, optional Lean/ subdirectory.
  Organised around precise theorems and definitions rather than open-ended exploration.
  Pairs with `search-math`, `cite`, `lean`, and the `theorem-proof` notebook template.
- **paclet-dev** — WolframInstitute-style dev repo with paclet submodules (triple nesting: PacletName/PacletName/Kernel/), Code/ for experimental work, Wiki/, .gitmodules.
  Optional Paper/ (gitignored).
  Work items that change paclet code land as PRs on the paclet submodules — developed on a `work/<item>` branch in a gitignored `<Paclet>--<item>/` worktree — while the dev repo's Wiki and Work stay linear on `main` (see the `next-session` skill).
- **paclet** — standalone Wolfram paclet (double nesting), clean repo structure.
  Optional Wiki/.

All paclet types use `Package[]` / `PackageExport` / `PackageScope` (not BeginPackage/EndPackage) for paclet code.
Every exported function is written to stand on its own — liftable out of the paclet and publishable to the Wolfram Function Repository unchanged, which is what rules out the private helper shared between two of them; the rule ships to projects in `code_style_template.md` § *Exported functions*.

## Notebook conversion engines

`new-notebook` has two Markdown→cells engines and picks between them **by inspecting the source**, not by configuration:

- **Built-in** — `ImportString[md, {"Markdown", "Notebook"}]`. The default.
- **Rich** — `WolframInstitute/MarkdownToNotebook`, called as the local clone at pinned SHA `204db7c`, with `Template: Default` and `"Evaluate" -> False`.
  Selected when the source has YAML frontmatter or LaTeX math, and only if `MarkdownToNotebook/` is present; otherwise it falls back to the built-in engine and says so.
  Never clone it silently.

See `Wiki/Resources/MarkdownToNotebook.md` for the pin, the recovery command, and why the reverse direction (`NotebookToMarkdown`) is used nowhere.
`paclet-docs` does **not** use the rich engine — it uses the official MCP doc tools.

`new-research-notebook` uses the rich engine as the **parser half of a two-half pipeline**: MarkdownToNotebook produces the cells, then `scripts/mathnotebook_post.wl` applies the MathNotebook environments, equation numbering, and citations.
The split is forced, not stylistic — the converter's `::: theorem` / `::: proof` divs exist only under `Template: Chapter` (which swaps in the WolframBookTools stylesheet, absent from a stock install), are **silently dropped** under `Default`, and even under `Chapter` give one `Theorem` style for every label, colliding section-derived numbers, no anchors, no cross-references, and no citations.
That skill generates **one-way**: the `.md` is the source of truth and the user edits it while reading the `.nb`, with a per-cell `CellID` fingerprint stored in `TaggingRules` to detect `.nb` edits and stop a regeneration rather than overwrite them.

Its writing rules live in `skills/new-research-notebook/style.md`, which `new-paper` reads too — one guide for a paper whether it ships as `.nb`, LaTeX or Typst.
The mechanics (pipeline, conversion call, stylesheet, references) are in the `build.md` sibling, so `SKILL.md` carries authoring conventions and nothing else.

`new-research-note` uses neither: its notebook goes through `mcp__Wolfram__WriteNotebook` directly, ships **unevaluated** (Input cells only, no paclet load), and is one of five files sharing a dated stem in `Research/Artifacts/` — a plain `article`-class LaTeX document with its `.pdf`, the notebook source and the notebook, and a loadable `.wl`.
Nothing it writes is deployed to the Cloud.

## How to Add a New Skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter (`name`, `description`)
2. Write the body to the **standard skeleton** — every skill carries these four sections, in this order where content allows:
   `## When to use` (triggers), `## Steps` (the procedure, numbered `### 1. Title`), `## Integration with other skills`, `## When NOT to use`.
   Domain sections (policy blocks, formats, references) may sit between them; deep mechanics go to read-on-demand sibling `.md` files next to `SKILL.md` (see `next-session/paclet-worktree.md` for the convention)
3. The plugin system auto-discovers skills from the `skills/` directory
4. If the skill needs a script, add it to `scripts/` and reference it via `${CLAUDE_PLUGIN_ROOT}/scripts/<name>`
5. If the skill should have a slash command, create `commands/<name>.md`
6. Add the skill to its area table under README.md § *What it does*, and update this file's tables
