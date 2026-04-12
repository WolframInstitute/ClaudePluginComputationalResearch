# Computational Research Plugin

A Claude plugin for AI-assisted computational research with a wiki-based
knowledge management system, human revision workflow, guided tours, Wolfram
paclet development, LaTeX paper scaffolding, and notebook generation.

## Plugin Architecture

```
.claude-plugin/plugin.json     — plugin metadata and version
skills/*/SKILL.md              — skill definitions (auto-discovered)
scripts/                       — bash and wolframscript utilities
commands/                      — slash command definitions
hooks/                         — PreToolUse hooks (e.g., block .nb reads)
skills/project-init/assets/    — templates for scaffolding
```

### Skills (13)

| Skill | Type | Purpose |
|-------|------|---------|
| `project-init` | scaffolding | Scaffold new projects (research, paclet-dev, paclet) |
| `paper-init` | scaffolding | Create Paper/ with LaTeX templates (amsart, biblatex, shared macros.sty) |
| `wolfram-resources` | content | Search Wolfram docs, Function Repository, Community, writings |
| `wiki-init` | wiki | Create Wiki/ knowledge base from scratch |
| `wiki-update` | wiki | Update articles, index, status, log after changes |
| `wiki-health` | wiki | Audit wiki for staleness, gaps, broken links |
| `wiki-plan` | wiki | Structured plans in Wiki/Plans/ with lifecycle |
| `revise` | protocol | Human revision loop — not invoked directly, other skills follow it |
| `resource-add` | content | Add papers/repos/tools with recovery info |
| `notebook-create` | content | Markdown-to-notebook pipeline via Wolfram MCP |
| `tour-start` | presentation | Interactive guided walkthrough with code |
| `paclet-build` | paclet | Build .paclet archive and install locally |
| `paclet-publish` | paclet | Build, install, publish to Wolfram Cloud, produce install URL |

### Scripts (15)

| Script | Language | Called by |
|--------|----------|----------|
| `scaffold-project.sh` | bash | project-init (research type) |
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
| `check-env.sh` | bash | check-env command |
| `recover_resources.sh` | bash | copied into projects, also resource-add |
| `generate_notebooks.wls` | wolframscript | copied into projects |
| `publish_notebooks.wls` | wolframscript | copied into projects |

### Commands (14)

| Command | Invokes |
|---------|---------|
| `new-project` | project-init |
| `init-paper` | paper-init |
| `init-wiki` | wiki-init |
| `update-wiki` | wiki-update |
| `check-wiki` | wiki-health |
| `plan` | wiki-plan |
| `add-resource` | resource-add |
| `new-notebook` | notebook-create |
| `search-wolfram` | wolfram-resources |
| `build-paclet` | paclet-build |
| `publish-paclet` | paclet-publish |
| `start-tour` | tour-start |
| `check-env` | check-env.sh + MCP ping |
| `load-project` | reads Wiki/ status |

### Templates (in skills/project-init/assets/)

Scaffolding templates use `{{PLACEHOLDER}}` syntax processed by `sed`.

| Template | Purpose |
|----------|---------|
| `claude_template.md` | CLAUDE.md for research projects |
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
`{{TITLE}}`, `{{ABSTRACT}}`.

## Project Types (scaffolding)

The `project-init` skill asks users which type of project to create:

- **research** (default) — Code/, Wiki/, Resources/, optional Paper/.
  Open-ended exploration of a topic.
- **paclet-dev** — WolframInstitute-style dev repo with paclet submodules
  (triple nesting: PacletName/PacletName/Kernel/), Code/ for experimental
  work, Wiki/, .gitmodules. Optional Paper/ (gitignored).
- **paclet** — standalone Wolfram paclet (double nesting), clean repo
  structure. Optional Wiki/.

All types use `Package[]` / `PackageExport` / `PackageScope` (not
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

The plugin's blog post lives in a local clone of `p135246/p135246.github.io`
(gitignored). When skills, commands, or features change, update the post:

- `p135246.github.io/Wolfram/_posts/2026-03-04-ai-assisted-computational-research.md`

If missing, re-clone:
```bash
git clone git@github.com:p135246/p135246.github.io.git p135246.github.io
```

### Keeping CLAUDE.md current

When skills, scripts, commands, or templates are added, removed, or renamed,
update the tables and counts in this file to match. Do not update CLAUDE.md
in response to CLAUDE.md-only changes (that would cycle).
