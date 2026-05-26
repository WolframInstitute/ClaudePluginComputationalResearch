# Computational Research

A Wolfram-centric [Claude](https://claude.ai) plugin for [AI-assisted computational research](https://p135246.github.io/wolfram/software/2026/03/04/ai-assisted-computational-research.html). Turns a folder with code and resources into an organized repo, maintains the repo, gathers and summarizes resources, grows a wiki knowledge base, scaffolds a LaTeX paper, turns Wolfram code into a paclet, helps with its compilation and publication, generates expository Wolfram notebooks via Markdown and publishes them on [Wolfram Cloud](https://www.wolframcloud.com), offers a tour guiding a human through the project, offers a revision workflow and explicit activity logging.

## Installation

Install from the [WolframInstitute plugin marketplace](https://github.com/WolframInstitute/ClaudePluginMarketplace):

```bash
claude plugin marketplace add WolframInstitute/ClaudePluginMarketplace
claude plugin install computational-research@WolframInstitute
```

**Claude Desktop app:** Install from the plugin marketplace GUI. Note: Claude Desktop runs in a VM (Cowork mode) where filesystem access is limited — this path has not been fully tested.

The author uses the plugin with the Claude Code extension for VS Code.

## Recommended Setup

The plugin works best with [Wolfram Engine](https://www.wolfram.com/engine/) (or Mathematica) and the following MCP servers:

| Server | Required | Purpose | Source |
|--------|----------|---------|--------|
| **Wolfram** (official) | yes | Wolfram Language evaluation, notebook generation | [Wolfram/MCPServer](https://resources.wolframcloud.com/PacletRepository/resources/Wolfram/MCPServer) |
| **arxiv-latex-mcp** | recommended | LaTeX source of arXiv papers | [takashiishida/arxiv-latex-mcp](https://github.com/takashiishida/arxiv-latex-mcp) |
| **arxiv** | recommended | Search and download arXiv papers | [blazickjp/arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server) |
| **wolfram** (unofficial) | optional | Wolfram Language LSP | [sw1sh/WolframMCP](https://github.com/sw1sh/WolframMCP) |

## Skills

| Skill | Description |
|-------|-------------|
| **project-init** | Scaffold a new project (research, math-research, paclet-dev, paclet) |
| **paper-init** | Create Paper/ with LaTeX article templates (amsart, biblatex, shared macros) |
| **wiki-init** | Initialize a plain-markdown knowledge base (Wiki/) in any repo |
| **wiki-update** | Update wiki articles, index, status, and log after changes |
| **wiki-health** | Audit the wiki for stale articles, broken links, and gaps |
| **wiki-plan** | Create or update structured plans with history tracking |
| **revise** | Human revision protocol for code, functionality, and deliverables |
| **resource-add** | Add papers, repos, notebooks, MathWorld/nLab/OEIS/DLMF/Wikipedia entries with recovery info |
| **cite-from-id** | Generate BibTeX entries from arXiv IDs or DOIs |
| **notebook-create** | Create or modify Wolfram notebooks via Markdown→MCP pipeline (research, computation, paper-analysis, theorem-proof templates) |
| **tour-start** | Interactive guided tour with narrative and runnable code per section |
| **wolfram-resources** | Search Wolfram docs, Function Repository, Community, and Wolfram writings |
| **math-resources** | Search MathWorld, nLab, OEIS, DLMF, and Wikipedia math articles |
| **lean-bridge** | Drive Lean/Mathlib formalization sessions via the lean-lsp MCP |
| **paclet-build** | Build a Wolfram paclet archive and install locally |
| **paclet-publish** | Build, install, and publish a paclet to Wolfram Cloud |

## Slash Commands

| Command | Description |
|---------|-------------|
| `/computational-research:new-project` | Scaffold a new project (research, math-research, paclet-dev, paclet) |
| `/computational-research:init-paper` | Create Paper/ with LaTeX templates |
| `/computational-research:init-wiki` | Initialize Wiki/ knowledge base |
| `/computational-research:update-wiki` | Update wiki after changes |
| `/computational-research:check-wiki` | Audit wiki for staleness and gaps |
| `/computational-research:plan` | Create or update a structured plan |
| `/computational-research:add-resource` | Add a paper or resource to the wiki |
| `/computational-research:new-notebook` | Create a Wolfram notebook |
| `/computational-research:search-wolfram` | Search Wolfram ecosystem resources |
| `/computational-research:search-math` | Search MathWorld, nLab, OEIS, DLMF, Wikipedia math |
| `/computational-research:cite-id` | Generate BibTeX from an arXiv ID or DOI |
| `/computational-research:lean` | Drive a Lean/Mathlib formalization session |
| `/computational-research:build-paclet` | Build paclet and install locally |
| `/computational-research:publish-paclet` | Build, install, publish to Wolfram Cloud |
| `/computational-research:start-tour` | Start or resume a guided project tour |
| `/computational-research:check-env` | Check Wolfram kernel and MCP availability |
| `/computational-research:load-project` | Summarize project status from wiki |

## License

MIT
