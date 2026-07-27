# 🤖 Computational Research

A Wolfram-centric [Claude](https://claude.ai) plugin for [AI-assisted computational research](https://p135246.github.io/wolfram/software/2026/03/04/ai-assisted-computational-research.html).

> **⚠️ Disclaimer.** This repo grows on the fly out of my own thoughts and needs around AI assistance in computational research. It is a working draft, in need of human revision and selective improvement. **Helpers and testers welcome!**

* 📁 Turns a folder of resources — code, PDFs, Markdown, notebooks — into an organized git repo, and maintains it.
* 🐺 Imports and exports Wolfram notebooks via Markdown.
* 📚 Grows and maintains a wiki knowledge base.
* 🔍 Gathers and summarizes resources, keeping a Markdown summary and recovery instructions.
* 📦 Converts code into a paclet and builds, documents, and deploys it.
* 📓 Generates expository Wolfram notebooks and publishes them on Wolfram Cloud.
* 📝 Scaffolds a LaTeX or Typst paper and edits the user-owned document on request.
* 🧬 Optionally records the prompt and intent behind every generated artifact.
* 📔 Optionally keeps a running scientific journal in LaTeX or Typst.
* 🧭 Offers a guided tour through the project, and a revision protocol for deliverables.
* ✅ Tracks plans, todos, and state.

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

| Skill / Command | Description |
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
| **research-notebook** | Research document notebook: definitions, conjectures with evidence, open questions, literature |
| **lean** | Drive a Lean/Mathlib formalization session |
| **paclet-docs** | Generate a symbol reference page per exported paclet function |
| **build-paclet** | Build a paclet and install it locally |
| **publish-paclet** | Build, install, and publish a paclet to the Cloud |
| **work** | Manage multi-session work items (spec, tasks, progress) |
| **next-session** | Run the next task in a fresh session, then stop |
| **provenance** | Track the prompt behind each generated artifact |
| **start-tour** | Run a guided tour of the project |
| **revise** | Human revision protocol for deliverables — skill only, no command |
| `check-env` | Check kernel and MCP availability — command only, no skill |
| `load-project` | Summarize project status — command only, no skill |

## 📄 License

MIT
