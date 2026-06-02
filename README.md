# 🤖 Computational Research

A Wolfram-centric [Claude](https://claude.ai) plugin for [AI-assisted computational research](https://p135246.github.io/wolfram/software/2026/03/04/ai-assisted-computational-research.html).

* 📁 Turns a folder with resources (code, PDFs, Markdown, notebooks, ...) into an organized git repo, which it maintains.
* 🐺 Imports and exports Wolfram notebooks via conversion to Markdown.
* 📚 Grows and maintains a wiki knowledge base.
* 🔍 Gathers and summarizes resources, keeping a Markdown summary and recovery options (e.g. where to download).
* 📦 Converts code into a paclet and helps with its build and deployment (e.g. with or without docs, local build or cloud).
* 📓 Generates expository Wolfram notebooks and helps publish them on Wolfram Cloud (explicitly marked as LLM-generated, keeping a Markdown mirror).
* 📝 Scaffolds a LaTeX or Typst paper and edits the user-owned document on request.
* 🧬 Optionally records the prompt and intent behind every generated artifact, keeping it traceable.
* 📔 Optionally keeps a running scientific journal in LaTeX or Typst — concise, cited def/thm/rem entries of what was learned.
* 🧭 Offers a guided tour through the project for a human, and a revision protocol (stateful for multi-session work).
* ✅ Tracks plans, todos, and state.

> **⚠️ Disclaimer.** This repo grows on the fly out of my own thoughts and needs around AI assistance in computational research. It is a working draft, in need of human revision and selective improvement. **Helpers and testers welcome!**

## 📥 Installation

The plugin is distributed through the [WolframInstitute plugin marketplace](https://github.com/WolframInstitute/ClaudePluginMarketplace).

**Claude Code (CLI / VS Code extension)** — the author's setup:

```bash
claude plugin marketplace add WolframInstitute/ClaudePluginMarketplace
claude plugin install computational-research@WolframInstitute
```

**Claude Desktop app** — install from the marketplace GUI.

> **Note:** Operation in Cowork mode and Chat mode has not been tested.

## ⚙️ Recommended Setup

The plugin works best with [Wolfram Engine](https://www.wolfram.com/engine/) (or Mathematica).

**MCP servers** — the plugin draws on these:

| Server | Required | Purpose | Source |
|--------|----------|---------|--------|
| **Wolfram** (official) | yes | Evaluation, notebook I/O, docs search, tests | [Wolfram/AgentTools](https://resources.wolframcloud.com/PacletRepository/resources/Wolfram/AgentTools) |
| **arxiv-latex-mcp** | recommended | Download LaTeX source of arXiv papers | [takashiishida/arxiv-latex-mcp](https://github.com/takashiishida/arxiv-latex-mcp) |
| **arxiv** | recommended | Search and download arXiv papers | [blazickjp/arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server) |
| **wolfram** (unofficial) | optional | Additionally supports Wolfram Language LSP, similar to [Serena](https://github.com/oraios/serena) | [sw1sh/WolframMCP](https://github.com/sw1sh/WolframMCP) |

**Installing the official Wolfram server:**

```wolfram
InstallMCPServer["ClaudeCode", "WolframLanguage"]
```

> **Note:** On older Wolfram versions, the legacy [Wolfram/MCPServer](https://resources.wolframcloud.com/PacletRepository/resources/Wolfram/MCPServer) paclet still works as a fallback if that is what you have installed.

> **🔑 License seats.** Each running kernel — every Wolfram MCP server, every
> open front-end, every `wolframscript` call — consumes one of your license's
> `$MaxLicenseProcesses` seats. The plugin is **MCP-first**: it routes Wolfram
> work through the official server's single persistent kernel and treats the
> `.wls` scripts as a fallback for when no MCP is attached (e.g. headless runs).
> Before spawning `wolframscript` it checks headroom and warns rather than
> failing opaquely. Running both Wolfram MCP servers at once uses two seats —
> `/check-env` reports live headroom and flags this.

## 🧩 Skills

Skills share their name with the matching slash command (one name per feature),
grouped by domain.

| Skill | Description |
|-------|-------------|
| **new-project** | Scaffold a new project (research, math, paclet-dev, paclet) |
| **scaffold-paper** | Scaffold a LaTeX or Typst paper, then edit it on request |
| **journal** | Keep an optional cited LaTeX/Typst journal (def/thm/rem), off by default |
| **init-wiki** | Create a markdown knowledge base (Wiki/) |
| **update-wiki** | Update wiki articles, index, and log |
| **check-wiki** | Audit the wiki for staleness and gaps |
| **search-wolfram** | Search Wolfram docs, Function Repository, Community, writings |
| **search-math** | Search MathWorld, nLab, OEIS, DLMF, Wikipedia math |
| **add-resource** | Add a paper, repo, or page with recovery info |
| **cite** | BibTeX from an arXiv ID or DOI |
| **new-notebook** | Build Wolfram notebooks from Markdown |
| **lean** | Drive a Lean/Mathlib formalization session |
| **build-paclet** | Build a paclet and install it locally |
| **publish-paclet** | Build, install, and publish a paclet to the Cloud |
| **work** | Manage multi-session work items (spec, tasks, progress) |
| **next-session** | Run the next task in a fresh session, then stop |
| **provenance** | Track the prompt behind each generated artifact |
| **start-tour** | Run a guided tour of the project |
| **revise** | Human revision protocol for deliverables (no command) |

## ⌨️ Slash Commands

| Command | Description |
|---------|-------------|
| `/computational-research:new-project` | Scaffold a new project |
| `/computational-research:scaffold-paper` | Scaffold a LaTeX or Typst paper |
| `/computational-research:journal` | Toggle, scaffold, add, or list journal entries |
| `/computational-research:init-wiki` | Create the Wiki/ knowledge base |
| `/computational-research:update-wiki` | Update the wiki after changes |
| `/computational-research:check-wiki` | Audit the wiki |
| `/computational-research:search-wolfram` | Search the Wolfram ecosystem |
| `/computational-research:search-math` | Search external math resources |
| `/computational-research:add-resource` | Add a resource to the wiki |
| `/computational-research:cite` | BibTeX from an arXiv ID or DOI |
| `/computational-research:new-notebook` | Create a Wolfram notebook |
| `/computational-research:lean` | Drive a Lean/Mathlib session |
| `/computational-research:build-paclet` | Build and install a paclet |
| `/computational-research:publish-paclet` | Publish a paclet to the Cloud |
| `/computational-research:work` | Create or manage a work item |
| `/computational-research:next-session` | Run the next task, then stop |
| `/computational-research:provenance` | Toggle/show prompt tracking |
| `/computational-research:start-tour` | Start or resume a guided tour |
| `/computational-research:check-env` | Check kernel and MCP availability |
| `/computational-research:load-project` | Summarize project status |

## 📄 License

MIT
