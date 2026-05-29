# Computational Research Plugin

A Claude plugin for AI-assisted computational research with a wiki-based
knowledge management system, human revision workflow, guided tours, Wolfram
paclet development, LaTeX paper scaffolding, notebook generation, and
session-based work tracking (spec/tasks/progress).

## Plugin Architecture

```
.claude-plugin/plugin.json     — plugin metadata and version
skills/*/SKILL.md              — skill definitions (auto-discovered)
scripts/                       — bash and wolframscript utilities
commands/                      — slash command definitions
hooks/                         — PreToolUse hooks (e.g., block .nb reads)
skills/project-init/assets/    — templates for scaffolding
```

### Skills (17)

| Skill | Type | Purpose |
|-------|------|---------|
| `project-init` | scaffolding | Scaffold new projects (research, math-research, paclet-dev, paclet) |
| `paper-init` | scaffolding | Create Paper/ with LaTeX templates (amsart, biblatex, shared macros.sty) |
| `wolfram-resources` | content | Search Wolfram docs, Function Repository, Community, writings |
| `math-resources` | content | Search MathWorld, nLab, OEIS, DLMF, Wikipedia math |
| `wiki-init` | wiki | Create Wiki/ knowledge base from scratch |
| `wiki-update` | wiki | Update articles, index, status, log after changes |
| `wiki-health` | wiki | Audit wiki for staleness, gaps, broken links |
| `work` | workflow | Create/manage work items in Work/ (spec, tasks, per-session progress) |
| `next-session` | workflow | Run one task per fresh session against a work item, then stop |
| `revise` | protocol | Human revision loop — not invoked directly, other skills follow it |
| `resource-add` | content | Add papers/repos/tools with recovery info (also MathWorld/nLab/OEIS/DLMF/Wikipedia) |
| `cite-from-id` | content | Generate BibTeX from arXiv ID or DOI |
| `notebook-create` | content | Markdown-to-notebook pipeline via Wolfram MCP (research, computation, paper-analysis, theorem-proof templates) |
| `lean-bridge` | content | Drive Lean/Mathlib formalization sessions via lean-lsp MCP |
| `tour-start` | presentation | Interactive guided walkthrough with code |
| `paclet-build` | paclet | Build .paclet archive and install locally |
| `paclet-publish` | paclet | Build, install, publish to Wolfram Cloud, produce install URL |

### Scripts (22)

| Script | Language | Called by |
|--------|----------|----------|
| `scaffold-project.sh` | bash | project-init (research type) |
| `scaffold-math-project.sh` | bash | project-init (math-research type) |
| `scaffold-paclet-dev.sh` | bash | project-init (paclet-dev type) |
| `scaffold-paclet.sh` | bash | project-init (paclet type) |
| `scaffold-paper.sh` | bash | paper-init skill |
| `build_paclet.wls` | wolframscript | paclet-build skill |
| `publish_paclet.wls` | wolframscript | paclet-publish skill |
| `search_wolfram_docs.wls` | wolframscript | wolfram-resources skill |
| `search_function_repo.wls` | wolframscript | wolfram-resources skill |
| `search_wolfram_community.wls` | wolframscript | wolfram-resources skill (URL constructor) |
| `search_wolfram_writings.wls` | wolframscript | wolfram-resources skill |
| `search_wolfram_physics.wls` | wolframscript | wolfram-resources skill |
| `search_mathworld.wls` | wolframscript | math-resources skill |
| `search_nlab.wls` | wolframscript | math-resources skill |
| `search_oeis.wls` | wolframscript | math-resources skill |
| `search_dlmf.wls` | wolframscript | math-resources skill |
| `search_wikipedia_math.wls` | wolframscript | math-resources skill |
| `cite_from_id.wls` | wolframscript | cite-from-id skill |
| `check-env.sh` | bash | check-env command |
| `recover_resources.sh` | bash | copied into projects, also resource-add |
| `generate_notebooks.wls` | wolframscript | copied into projects |
| `publish_notebooks.wls` | wolframscript | copied into projects |

### Commands (18)

| Command | Invokes |
|---------|---------|
| `new-project` | project-init |
| `init-paper` | paper-init |
| `init-wiki` | wiki-init |
| `update-wiki` | wiki-update |
| `check-wiki` | wiki-health |
| `work` | work |
| `next-session` | next-session |
| `add-resource` | resource-add |
| `new-notebook` | notebook-create |
| `search-wolfram` | wolfram-resources |
| `search-math` | math-resources |
| `cite-id` | cite-from-id |
| `lean` | lean-bridge |
| `build-paclet` | paclet-build |
| `publish-paclet` | paclet-publish |
| `start-tour` | tour-start |
| `check-env` | check-env.sh + MCP ping |
| `load-project` | reads Wiki/ + Work/ status |

### Templates (in skills/project-init/assets/)

Scaffolding templates use `{{PLACEHOLDER}}` syntax processed by `sed`.

| Template | Purpose |
|----------|---------|
| `claude_template.md` | CLAUDE.md for research projects |
| `math_claude_template.md` | CLAUDE.md for math-research projects |
| `math_categories_template.md` | Math-domain taxonomy seed (adapted from PureMath) |
| `notebook_theorem_proof_template.md` | Theorem-proof notebook skeleton (used by notebook-create) |
| `formal_definition_template.md` | Wiki/Definitions/ article template |
| `formalization_checklist_template.md` | Work/Formalize-*.md skeleton, a Type: formalization work item (used by lean-bridge) |
| `work_item_template.md` | Work/<Name>.md skeleton: Spec / Tasks / Progress / Decisions (used by work, next-session) |
| `work_readme_template.md` | Work/README.md board, seeded by the scaffolds |
| `code_style_template.md` | Code-style rules appended to every generated CLAUDE.md (research, paclet-dev, paclet) |
| `main_template.tex` | LaTeX article (amsart, uses macros.sty) |
| `macros_template.sty` | Shared preamble: fonts, math, biblatex, theorems, macros |
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

The `project-init` skill asks users which type of project to create:

- **research** (default) — Code/, Wiki/, Work/, Resources/, optional Paper/.
  Open-ended exploration of a topic.
- **math-research** — Wiki/{Theorems,Definitions,Domains}/ and Work/ pre-created,
  math-domain taxonomy seeded, optional Lean/ subdirectory. Organised around
  precise theorems and definitions rather than open-ended exploration. Pairs
  with `math-resources`, `cite-from-id`, `lean-bridge`, and the `theorem-proof`
  notebook template.
- **paclet-dev** — WolframInstitute-style dev repo with paclet submodules
  (triple nesting: PacletName/PacletName/Kernel/), Code/ for experimental
  work, Wiki/, .gitmodules. Optional Paper/ (gitignored).
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
