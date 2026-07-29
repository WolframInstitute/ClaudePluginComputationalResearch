# Computational Research Plugin

A Claude plugin for AI-assisted computational research with a wiki-based knowledge management system, human revision workflow, guided tours, Wolfram paclet development, LaTeX/Typst paper scaffolding, an optional cited scientific journal, notebook generation, and session-based work tracking (spec/tasks/progress).

Inventory — layout, scripts, commands, templates, project types, notebook conversion engines, how to add a skill — is in [ARCHITECTURE.md](ARCHITECTURE.md), read on demand.
The skills themselves need no lookup: each one's `description:` frontmatter is already in context.
This file carries only what a session must know *before* it knows to look something up.

Every session follows the [revise](skills/revise/SKILL.md) protocol for code, functionality, plans, and deliverables: generate, present, **wait** for the user.
Wiki prose is exempt, and autonomous runs defer the gate to branch + digest (`revise` § *Autonomous mode*).

## Source formatting

Semantic line breaks: **on**
<!-- This repo's own prose follows the rule the plugin ships: prose in source files —
     markdown (.md) and LaTeX/Typst (.tex/.typ) — uses one sentence per line (semantic
     line breaks). Each sentence starts on its own source line; a long sentence may also
     break at clause boundaries. Source only; rendered output is unchanged. Do not reflow
     an existing paragraph onto one line, and do not add blank lines between a paragraph's
     sentences (a blank line still separates paragraphs). Exempt: code, tables, headings,
     and YAML front matter. Detect with:
     grep -qiE 'semantic line breaks:[[:space:]]*\*{0,2}on' CLAUDE.md && echo on || echo off -->

## Wolfram Kernel Execution Policy

Every running kernel consumes one of the license's `$MaxLicenseProcesses` seats: each Wolfram MCP server, each open front-end, and **each `wolframscript` invocation** (which spawns a fresh kernel).
Once seats are saturated, a new `wolframscript` call fails with a license error — the common failure mode when the official + unofficial Wolfram MCP servers and a front-end are all running.

**The plugin is MCP-first.** All Wolfram-touching skills prefer the official AgentTools MCP (`mcp__Wolfram__WolframLanguageEvaluator`, `WriteNotebook`, `ReadNotebook`, `TestReport`, `CodeInspector`, `SymbolDefinition`, `WolframLanguageContext`) — one persistent kernel, no extra seat.
The `.wls` scripts (paclet build/publish, notebook generation, `search_*`, `cite`) are kept as a **fallback** for when no MCP is attached (headless/cron runs) or for bulk batch use — they are not deleted.

Before spawning `wolframscript`, a skill checks headroom on the MCP (this costs no seat — it runs on the already-running kernel):

```wolfram
With[{free = $MaxLicenseProcesses - $LicenseProcesses}, free]
```

If `free <= 0`, the skill does **not** spawn `wolframscript`; it routes the work through the MCP or asks the user to free a seat.
`/check-env` reports live headroom and flags when two Wolfram MCP servers are configured at once.
This policy is **detect + warn** — it never hard-blocks.
The per-skill "Kernel execution (license-aware)" blocks are the short reminders of this rule; this section is authoritative.

## Knowledge Base (Wiki)

`Wiki/` is a plain-markdown knowledge base maintained by the LLM, initialized 2026-07-27.
Its scope in **this** repo is deliberately narrow — external dependencies (with recovery info) and cross-cutting concepts.
Plugin architecture stays in `ARCHITECTURE.md` and `README.md`; do not mirror the skill/script/command tables into `Wiki/`, or there will be two copies to keep current.

No human sign-off is needed for wiki prose.
Every article carries a `[ LLM Generated ]` marker under its `# Title`.
Execution state — active items, next tasks — lives in `Work/README.md`, not `Wiki/Status.md`.

## Plugin Maintenance

Version bumping and marketplace sync follow the global `~/.claude/CLAUDE.md` § *Versioning & Marketplace*: bump `.claude-plugin/plugin.json`, mirror `version` / `description` / `keywords` into `ClaudePluginMarketplace/.claude-plugin/marketplace.json`, commit and push both repos.
The marketplace clone is gitignored at `ClaudePluginMarketplace/`; if missing, re-clone:

```bash
git clone git@github.com:WolframInstitute/ClaudePluginMarketplace.git ClaudePluginMarketplace
```

### Blog post

The plugin's blog post lives in the author's **live** clone of `p135246/p135246.github.io`:

- `~/Library/CloudStorage/OneDrive-Personal/Web/p135246.github.io/Wolfram/_posts/2026-03-04-ai-assisted-computational-research.md`

When skills, commands, or features change, update the post there.
Two rules for every edit:

- **Short descriptions only.** A version-history entry is one short paragraph naming the main idea — the length of the 3.2 and 3.8 entries, not a feature list. Long, detailed, or enthusiastic entries get cut.
- **Always update `Last updated` at the top** to the date of the edit. It is a living document and the line goes stale silently.

This is an active, **public** repo that carries the author's own commits and may be ahead of / behind its remote — edit the post and present changes for review, but do **not** commit or push it as part of plugin changes; the author syncs and publishes it.
The in-project `ComputationalResearch/p135246.github.io/` clone is stale and **not** canonical.

### Keeping the docs current

When skills, scripts, commands, or templates are added, removed, or renamed, update the tables and counts in `ARCHITECTURE.md` and the skills table in `README.md`.
Inventory does not belong in this file: it is auto-loaded into every session, and a session does not need it resident — measured in [Wiki/Concepts/PreambleAudit.md](Wiki/Concepts/PreambleAudit.md).
Do not update `CLAUDE.md` in response to `CLAUDE.md`-only changes (that would cycle).
