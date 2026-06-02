# Computational Research Plugin

A Claude plugin for AI-assisted computational research with a wiki-based
knowledge management system, human revision workflow, guided tours, Wolfram
paclet development, LaTeX/Typst paper scaffolding, an optional cited
scientific journal, notebook generation, and session-based work tracking
(spec/tasks/progress).

## Wolfram Kernel Execution Policy

Every running kernel consumes one of the license's `$MaxLicenseProcesses` seats:
each Wolfram MCP server, each open front-end, and **each `wolframscript`
invocation** (which spawns a fresh kernel). Once seats are saturated, a new
`wolframscript` call fails with a license error — the common failure mode when
the official + unofficial Wolfram MCP servers and a front-end are all running.

**The plugin is MCP-first.** All Wolfram-touching skills prefer the official
AgentTools MCP (`mcp__Wolfram__WolframLanguageEvaluator`, `WriteNotebook`,
`ReadNotebook`, `TestReport`, `CodeInspector`, `SymbolDefinition`,
`WolframLanguageContext`) — one persistent kernel, no extra seat. The `.wls`
scripts (paclet build/publish, notebook generation, `search_*`, `cite`) are kept
as a **fallback** for when no MCP is attached (headless/cron runs) or for bulk
batch use — they are not deleted.

Before spawning `wolframscript`, a skill checks headroom on the MCP (this costs
no seat — it runs on the already-running kernel):

```wolfram
With[{free = $MaxLicenseProcesses - $LicenseProcesses}, free]
```

If `free <= 0`, the skill does **not** spawn `wolframscript`; it routes the work
through the MCP or asks the user to free a seat. `/check-env` reports live
headroom and flags when two Wolfram MCP servers are configured at once. This
policy is **detect + warn** — it never hard-blocks. The per-skill "Kernel
execution (license-aware)" blocks are the short reminders of this rule; this
section is authoritative.

## Plugin Architecture

```
.claude-plugin/plugin.json     — plugin metadata and version
skills/*/SKILL.md              — skill definitions (auto-discovered)
scripts/                       — bash and wolframscript utilities
commands/                      — slash command definitions
hooks/                         — PreToolUse hooks (e.g., block .nb reads)
skills/new-project/assets/    — templates for scaffolding
```

### Skills (19)

| Skill | Type | Purpose |
|-------|------|---------|
| `new-project` | scaffolding | Scaffold new projects (research, math-research, paclet-dev, paclet) |
| `scaffold-paper` | scaffolding | Scaffold Paper/ with LaTeX (amsart, biblatex) or Typst templates; then edit the user-owned doc |
| `journal` | scaffolding | Optional cited LaTeX/Typst journal (one day-file per day under entries/, dated def/thm/rem/claim); per-project toggle |
| `search-wolfram` | content | Search Wolfram docs, Function Repository, Community, writings |
| `search-math` | content | Search MathWorld, nLab, OEIS, DLMF, Wikipedia math |
| `init-wiki` | wiki | Create Wiki/ knowledge base from scratch |
| `update-wiki` | wiki | Update articles, index, status, log after changes |
| `check-wiki` | wiki | Audit wiki for staleness, gaps, broken links |
| `provenance` | workflow | Optionally track prompts/intent behind generated artifacts (ledger + embedded back-pointers); per-project toggle |
| `work` | workflow | Create/manage work items in Work/ (spec, tasks, per-session progress) |
| `next-session` | workflow | Run one task per fresh session against a work item, then stop |
| `revise` | protocol | Human revision loop — not invoked directly, other skills follow it |
| `add-resource` | content | Add papers/repos/tools with recovery info (also MathWorld/nLab/OEIS/DLMF/Wikipedia) |
| `cite` | content | Generate BibTeX from arXiv ID or DOI |
| `new-notebook` | content | Markdown-to-notebook pipeline via Wolfram MCP (research, computation, paper-analysis, theorem-proof templates) |
| `lean` | content | Drive Lean/Mathlib formalization sessions via lean-lsp MCP |
| `start-tour` | presentation | Interactive guided walkthrough with code |
| `build-paclet` | paclet | Build .paclet archive and install locally |
| `publish-paclet` | paclet | Build, install, publish to Wolfram Cloud, produce install URL |

### Scripts (25)

| Script | Language | Called by |
|--------|----------|----------|
| `scaffold-project.sh` | bash | new-project (research type) |
| `scaffold-math-project.sh` | bash | new-project (math-research type) |
| `scaffold-paclet-dev.sh` | bash | new-project (paclet-dev type) |
| `scaffold-paclet.sh` | bash | new-project (paclet type) |
| `scaffold-paper.sh` | bash | scaffold-paper skill (`--typst` for Typst) |
| `scaffold-journal.sh` | bash | journal skill (`--typst` for Typst) |
| `build_paclet.wls` | wolframscript | build-paclet skill |
| `publish_paclet.wls` | wolframscript | publish-paclet skill |
| `paclet_common.wl` | wolframscript | shared helper (build_paclet.wls, publish_paclet.wls) |
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
| `commit-msg` | sh | git hook copied into projects (`.githooks/`); enforces Conventional Commits |
| `check-env.sh` | bash | check-env command |
| `recover_resources.sh` | bash | copied into projects, also add-resource |
| `generate_notebooks.wls` | wolframscript | copied into projects |
| `publish_notebooks.wls` | wolframscript | copied into projects |

### Commands (20)

| Command | Invokes |
|---------|---------|
| `new-project` | new-project |
| `scaffold-paper` | scaffold-paper |
| `journal` | journal |
| `init-wiki` | init-wiki |
| `update-wiki` | update-wiki |
| `check-wiki` | check-wiki |
| `search-wolfram` | search-wolfram |
| `search-math` | search-math |
| `add-resource` | add-resource |
| `cite` | cite |
| `new-notebook` | new-notebook |
| `lean` | lean |
| `build-paclet` | build-paclet |
| `publish-paclet` | publish-paclet |
| `work` | work |
| `next-session` | next-session |
| `provenance` | provenance |
| `start-tour` | start-tour |
| `check-env` | check-env.sh + MCP ping |
| `load-project` | reads Wiki/ + Work/ status |

### Templates (in skills/new-project/assets/)

Scaffolding templates use `{{PLACEHOLDER}}` syntax processed by `sed`.

| Template | Purpose |
|----------|---------|
| `claude_template.md` | CLAUDE.md for research projects |
| `math_claude_template.md` | CLAUDE.md for math-research projects |
| `math_categories_template.md` | Math-domain taxonomy seed (adapted from PureMath) |
| `notebook_theorem_proof_template.md` | Theorem-proof notebook skeleton (used by new-notebook) |
| `formal_definition_template.md` | Wiki/Definitions/ article template |
| `formalization_checklist_template.md` | Work/Backlog/Formalize-*.md skeleton, a Type: formalization work item (used by lean) |
| `work_item_template.md` | Work item skeleton: Spec / Tasks / Progress / Decisions (used by work, next-session); status is the folder (Active/Backlog/Done/Dropped) |
| `work_readme_template.md` | Work/README.md active-item index, seeded by the scaffolds |
| `code_style_template.md` | Code-style rules appended to every generated CLAUDE.md (research, paclet-dev, paclet) |
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

Available placeholders: `{{PROJECT_NAME}}`, `{{TOPIC_DESCRIPTION}}`,
`{{GOALS}}`, `{{PACLET_NAME}}`, `{{ORG_NAME}}`, `{{AUTHOR}}`, `{{EMAIL}}`,
`{{TITLE}}`, `{{ABSTRACT}}`, `{{CODE_DIR}}`, `{{ITEM_NAME}}`.

## Project Types (scaffolding)

The `new-project` skill asks users which type of project to create:

- **research** (default) — Code/, Wiki/, Work/, Resources/, optional Paper/.
  Open-ended exploration of a topic.
- **math-research** — Wiki/{Theorems,Definitions,Domains}/ and Work/ pre-created,
  math-domain taxonomy seeded, optional Lean/ subdirectory. Organised around
  precise theorems and definitions rather than open-ended exploration. Pairs
  with `search-math`, `cite`, `lean`, and the `theorem-proof`
  notebook template.
- **paclet-dev** — WolframInstitute-style dev repo with paclet submodules
  (triple nesting: PacletName/PacletName/Kernel/), Code/ for experimental
  work, Wiki/, .gitmodules. Optional Paper/ (gitignored). Work items that change
  paclet code land as PRs on the paclet submodules — developed on a `work/<item>`
  branch in a gitignored `<Paclet>--<item>/` worktree — while the dev repo's
  Wiki and Work stay linear on `main` (see the `next-session` skill).
- **paclet** — standalone Wolfram paclet (double nesting), clean repo
  structure. Optional Wiki/.

All paclet types use `Package[]` / `PackageExport` / `PackageScope` (not
BeginPackage/EndPackage) for paclet code.

## How to Add a New Skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter (`name`, `description`)
2. Write the procedural instructions in the body
3. The plugin system auto-discovers skills from the `skills/` directory
4. If the skill needs a script, add it to `scripts/` and reference it via
   `${CLAUDE_PLUGIN_ROOT}/scripts/<name>`
5. If the skill should have a slash command, create `commands/<name>.md`
6. Update README.md skills table and this file's tables

## Plugin Maintenance

After any changes to plugin files:
1. Commit and push this repo
2. If the version was bumped, also update `ClaudePluginMarketplace/`:
   - Edit `ClaudePluginMarketplace/.claude-plugin/marketplace.json`
   - Bump `version`, update `description` and `keywords` to match plugin.json
   - `cd ClaudePluginMarketplace && git add -A && git commit -m "..." && git push`

The marketplace repo (`WolframInstitute/ClaudePluginMarketplace`) is cloned
locally at `ClaudePluginMarketplace/` (gitignored). If missing, re-clone:
```bash
git clone git@github.com:WolframInstitute/ClaudePluginMarketplace.git ClaudePluginMarketplace
```

### Blog post

The plugin's blog post lives in the author's **live** clone of
`p135246/p135246.github.io`:

- `~/Library/CloudStorage/OneDrive-Personal/Web/p135246.github.io/Wolfram/_posts/2026-03-04-ai-assisted-computational-research.md`

When skills, commands, or features change, update the post there. This is an
active, **public** repo that carries the author's own commits and may be ahead
of / behind its remote — edit the post and present changes for review, but do
**not** commit or push it as part of plugin changes; the author syncs and
publishes it. The in-project `ComputationalResearch/p135246.github.io/` clone is
stale and **not** canonical.

### Keeping CLAUDE.md current

When skills, scripts, commands, or templates are added, removed, or renamed,
update the tables and counts in this file to match. Do not update CLAUDE.md
in response to CLAUDE.md-only changes (that would cycle).
