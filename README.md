# computational-research

A Claude plugin for AI-assisted computational research. Provides a plain-markdown
wiki (knowledge base), a human revision workflow for code and deliverables, a
guided tour system, resource management with recovery, notebook generation via
Wolfram MCP, and activity logging.

Works with any research domain — mathematics, physics, computer science, etc.
Domain-agnostic workflow adapts to the project.

Read the motivation behind this plugin:
[AI-Assisted Computational Research](https://p135246.github.io/wolfram/software/2026/03/04/ai-assisted-computational-research.html)

## Installation

### 1. Add the marketplace

```bash
claude plugin marketplace add WolframInstitute/ClaudePluginMarketplace
```

In Claude Desktop, go to Settings → Plugins → Add Marketplace and enter
`WolframInstitute/ClaudePluginMarketplace`.

### 2. Install the plugin

```bash
claude plugin install computational-research@WolframInstitute
```

In Claude Desktop, find **computational-research** in the marketplace and click
Install.

## Requirements

- [Wolfram Engine](https://www.wolfram.com/engine/) or Mathematica
- [wolframscript](https://www.wolfram.com/wolframscript/) in PATH

## MCP Servers

| Server | Purpose | Source |
|--------|---------|--------|
| **Wolfram** (official) | Wolfram Language evaluation | Paclet `Wolfram/MCPServer` (Mathematica 14.2+) |
| **wolfram** (unofficial) | Notebook creation and editing | [sw1sh/WolframMCP](https://github.com/sw1sh/WolframMCP) |
| **arxiv** | Search and download arXiv papers | [blazickjp/arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server) |
| **arxiv-latex-mcp** | Read LaTeX source of arXiv papers | [takashiishida/arxiv-latex-mcp](https://github.com/takashiishida/arxiv-latex-mcp) |

You need **at least one** Wolfram MCP. Both arXiv servers are needed for the full
paper management workflow.

## Skills

| Skill | Description |
|-------|-------------|
| **wiki-init** | Initialize a plain-markdown knowledge base (Wiki/) in any repo |
| **wiki-update** | Update wiki articles, index, status, and log after changes |
| **wiki-health** | Audit the wiki for stale articles, broken links, and gaps |
| **wiki-plan** | Create or update structured plans with history tracking |
| **revise** | Human revision protocol for code, functionality, and deliverables |
| **resource-add** | Add papers, repos, notebooks, or other resources with recovery info |
| **notebook-create** | Create or modify Wolfram notebooks via Markdown→MCP pipeline |
| **tour-start** | Interactive guided tour with narrative and runnable code per section |
| **computational-exploration** | Scaffold a new research project with wiki, code, papers, and notebooks |

## Slash Commands

| Command | Description |
|---------|-------------|
| `/computational-research:check-env` | Check Wolfram kernel and MCP availability |
| `/computational-research:new-project` | Scaffold a new research project |
| `/computational-research:add-resource` | Add a paper or resource to the wiki |
| `/computational-research:load-project` | Summarize project status from the wiki |

## Design Principles

1. **Plain markdown only.** No databases, no embeddings. Works on GitHub, in
   Obsidian, in any text editor.
2. **LLM-navigable.** Index.md is the entry point. Folder structure is the taxonomy.
3. **Human-readable.** Encyclopedia-style articles, not raw dumps.
4. **Revision for code, not prose.** Code and plans get human review. Wiki articles
   are documentation maintained automatically.
5. **Resources are recoverable.** Wiki/Resources/ is the source of truth (tracked).
   Resources/ holds ephemeral files (gitignored). `Scripts/recover_resources.sh`
   rebuilds from `## Recover` sections.
6. **On-demand local state.** Tour/ and Resources/ are created only when needed,
   gitignored. Wiki/ is tracked.
7. **Domain-agnostic.** Wiki subfolder names adapt to the project. The workflow
   (index, status, log, plans, resources, tour) is universal.

## Wiki Structure

The wiki is plain markdown — fully navigable on GitHub, in Obsidian, or any
text editor. `Wiki/Index.md` is the entry point.

```
Wiki/
  Index.md          master index (start here)
  Status.md         current project state
  Log.md            reverse-chronological activity log
  Concepts/         cross-cutting concepts
  Resources/        papers, repos, tools (summaries with recovery info)
  Plans/            roadmaps, task breakdowns
  Notebooks/        markdown sources for .nb files
  <Domain>/         project-specific folders
```

All cross-references use standard markdown relative links, so every link is
clickable on GitHub.

## License

MIT
