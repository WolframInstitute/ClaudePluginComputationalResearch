> **⚠️ Disclaimer.** This repo grows on the fly out of my own thoughts and needs around AI assistance in computational research. It is a working draft, in need of human revision and selective improvement. **Helpers and testers welcome!**

# 🤖 Computational Research

A Wolfram-centric [Claude](https://claude.ai) plugin for [AI-assisted computational research](https://p135246.github.io/wolfram/software/2026/03/04/ai-assisted-computational-research.html).
Available in the [WolframInstitute marketplace](https://github.com/WolframInstitute/ClaudePluginMarketplace).

* 📁 Turns a folder of resources — code, PDFs, Markdown, notebooks — into an organized git repo, and maintains it.
* 🗂️ Writes everything it generates into `Artifacts/` folders, one dated stem per artifact, and leaves the rest of the repo to you.
* 🐺 Imports and exports Wolfram notebooks via Markdown.
* 📚 Grows and maintains a wiki knowledge base.
* 🔍 Gathers and summarizes resources, keeping a Markdown summary and recovery instructions.
* 📦 Converts code into a paclet and builds, documents, and deploys it — every exported function self-contained enough to publish to the Function Repository on its own.
* 📓 Generates expository Wolfram notebooks and publishes them on Wolfram Cloud.
* 📝 Adds a LaTeX or Typst paper to `Paper/` and edits the user-owned document on request.
* 🧬 Optionally records the prompt and intent behind every generated artifact.
* 📔 Optionally keeps a running scientific journal in LaTeX or Typst.
* 🧭 Offers a guided tour through the project, and a revision protocol for deliverables.
* ✅ Tracks plans, todos, and state, and can work an opted-in item unattended onto a branch for review.

## 🗂️ Where things go

```
Project/
  Code/Artifacts/        notebooks about the code          new-notebook
  Research/Artifacts/    notes, and papers as notebooks    new-research-note, new-research-notebook
  Paper/                 your typeset papers               new-paper
  Wiki/                  what the project knows
  Work/                  what it is doing
  Resources/             what it has read
```

Everything the plugin generates lands in an `Artifacts/` folder — one dated stem per artifact, `<WhatItSettles>_YYMMDD`, shared by whatever files it needs and flat until the artifact grows its own code, data or build.
**Everything outside an `Artifacts/` folder is yours, and is never written or overwritten.**
That one path check is the whole protection rule; the convention is spelled out in [skills/new-notebook/artifacts.md](skills/new-notebook/artifacts.md).

## 📥 Installation

Distributed through the [WolframInstitute plugin marketplace](https://github.com/WolframInstitute/ClaudePluginMarketplace).
In **Claude Code** (CLI / VS Code extension) — the author's setup:

```bash
claude plugin marketplace add WolframInstitute/ClaudePluginMarketplace
claude plugin install computational-research@WolframInstitute
```

In the **Claude Desktop app**, install from the marketplace GUI.

## ⚙️ Setup

The plugin works best with [Wolfram Engine](https://www.wolfram.com/engine/) (or Mathematica), and draws on these MCP servers:

| Server | Required | Purpose | Source |
|--------|----------|---------|--------|
| **Wolfram** (official) | yes | Evaluation, notebook I/O, docs search, tests | [Wolfram/AgentTools](https://resources.wolframcloud.com/PacletRepository/resources/Wolfram/AgentTools) |
| **arxiv-latex-mcp** | recommended | Download LaTeX source of arXiv papers | [takashiishida/arxiv-latex-mcp](https://github.com/takashiishida/arxiv-latex-mcp) |
| **arxiv** | recommended | Search and download arXiv papers | [blazickjp/arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server) |

Install the official Wolfram server from a Wolfram session:

```wolfram
InstallMCPServer["ClaudeCode", "WolframLanguage"]
```

**🔑 License seats.** Every running kernel — each Wolfram MCP server, each open front-end, each `wolframscript` call — takes one of your `$MaxLicenseProcesses` seats. The plugin is MCP-first and checks headroom before spawning a kernel; see the [kernel execution policy](CLAUDE.md#wolfram-kernel-execution-policy).

<details>
<summary>Notes</summary>

* Operation in Cowork mode and Chat mode has not been tested.
* On older Wolfram versions the legacy [Wolfram/MCPServer](https://resources.wolframcloud.com/PacletRepository/resources/Wolfram/MCPServer) paclet still works as a fallback.
* The unofficial [sw1sh/WolframMCP](https://github.com/sw1sh/WolframMCP) server is optional; it adds Wolfram Language LSP support, similar to [Serena](https://github.com/oraios/serena).
* Running both Wolfram MCP servers at once uses two license seats — `/computational-research:check-env` reports live headroom and flags this.

</details>

## 🧩 Skills & Commands

Each skill is invoked by the slash command of the same name, `/computational-research:<skill>`.
Scripts, templates, project types, and the repo layout are in [ARCHITECTURE.md](ARCHITECTURE.md).

| Skill / Command | Description |
|-------|-------------|
| **new-project** | Scaffold a new project (research, math, paclet-dev, paclet) |
| **new-paper** | Add a LaTeX or Typst paper to `Paper/`, then edit it on request, to the shared writing guide |
| **journal** | Keep an optional cited LaTeX/Typst journal (def/thm/rem), and take what a paper cannot carry; off by default |
| **init-wiki** | Create a markdown knowledge base (Wiki/) |
| **update-wiki** | Update wiki articles, index, and backlinks |
| **check-wiki** | Audit the wiki for staleness and gaps |
| **search-wolfram** | Search Wolfram docs, Function Repository, Community, writings |
| **search-math** | Search MathWorld, nLab, OEIS, DLMF, Wikipedia math |
| **add-resource** | Add a paper, repo, or page with recovery info |
| **cite** | BibTeX from an arXiv ID or DOI |
| **new-notebook** | Build Wolfram notebooks from Markdown into `Code/Artifacts/` (dual-engine: auto-detects a richer converter for frontmatter/LaTeX-math sources) |
| **new-research-notebook** | A mathematics paper as a notebook, into `Research/Artifacts/`: settled results with complete proofs, experiments quarantined in a Ruliology section, everything numbered and cross-referenced by the front end |
| **new-research-note** | Freeze a conversation as a dated artifact in `Research/Artifacts/`: a plain LaTeX document (claims, complete proofs, named assumptions, a catalogue), an unevaluated paclet-free notebook and a loadable `.wl`, all sharing one stem; nothing uploaded |
| **lean** | Drive a Lean/Mathlib formalization session |
| **paclet-docs** | Generate a symbol reference page per exported paclet function |
| **build-paclet** | Build a paclet and install it locally |
| **publish-paclet** | Build with docs, install, publish to the Cloud, deploy the doc pages publicly |
| **work** | Manage multi-session work items (spec, tasks, hand-off, decisions, progress) |
| **next-session** | Run the next task in a fresh session, then stop |
| **refine** | Shape a backlog item with the user until it is ready to run |
| **provenance** | Track the prompt behind each generated artifact |
| **start-tour** | Run a guided tour of the project |
| **revise** | Human revision protocol for deliverables — skill only, no command |
| `check-env` | Check kernel and MCP availability — command only, no skill |
| `load-project` | Summarize project status — command only, no skill |
| `auto-run` | Work a Ready item unattended, one cold session per task, onto `auto/<Item>` for a human to review and merge — command only, no skill |

## 📄 License

MIT
