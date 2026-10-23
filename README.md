> **⚠️ Disclaimer.** This repo grows on the fly out of my own thoughts and needs around AI assistance in computational research. It is a working draft, in need of human revision and selective improvement. **Helpers and testers welcome!**

# 🤖 Computational Research

A Wolfram-centric [Claude](https://claude.ai) plugin for [AI-assisted computational research](https://p135246.github.io/wolfram/software/2026/03/04/ai-assisted-computational-research.html).
Available in the [WolframInstitute marketplace](https://github.com/WolframInstitute/ClaudePluginMarketplace).

* ⚙️ **Autosetup** installs the MCP servers and tools, and checks the environment.
* 📁 **Autoorganization** sorts a project into folders and keeps it tidy.
* 📚 **Autoknowledge** grows and maintains a wiki of what the project knows.
* 🔍 **Autoresources** gathers resources and keeps track of how to recover them.
* 🐺 Converts Wolfram notebooks to and from Markdown.
* 📓 Writes expository notebooks, and mathematics papers as notebooks.
* 📦 Turns code into a documented paclet and publishes it.
* 📝 Supports human-owned papers and paclet designs, with concise research companions and edits on request.
* 📐 Formalizes proofs in Lean.
* 🧮 **Paper verification** builds code and tests beside a mathematics paper and checks it statement by statement.
* 📔 Keeps a scientific journal of what was learned, if you want one.
* 🧬 Records the prompt behind everything it generates, if you want that.
* 🗃️ **Autolab** manages a backlog of work and works through it while you are away.
* 🤝 Shows you every deliverable, and revises it from the notes you write into it, keeping every version and remembering your corrections.
* 🧭 Gives a guided tour of the project.

## 🔄 Workflows

### 1. Organization of materials and resources

Organize your folder into a structure maintained by the LLM, or scaffold a new project from a research question.

```
Project/
  Code/          code items
  <PacletName>/  optional paclet folder
  Research/      research items
  Wiki/          knowledge base maintained by the LLM
  Work/          backlog managed by the LLM
  Resources/     downloaded material
```

The project is version-controlled with Git.
Resources are downloaded and stored locally, with recovery instructions committed to Git instead of the downloaded files.
Within each folder, `Artifacts/` holds notes and notebooks on individual topics, while `Archive/` holds superseded material.
Documents intended as outputs are developed iteratively in the folder itself, as described below.

### 2. Assisted writing of output documents

The author develops the main document directly, in numbered iterations such as `document1.tex`, `document2.tex`, and so on.
For each iteration, the LLM maintains a matching notes file, such as `document1_notes.tex`, following the document’s structure while exploring related questions and proposing additions.

The author decides what to incorporate and when to begin the next iteration.
The LLM edits the main document only on explicit request.

See the [document ownership rules](skills/paper-create/workflow.md).

### 3. Assisted paclet development

Paclet development follows the same workflow, with a design notebook as the main document.
For a paclet named `Infrageometry`, keep `Infrageometry1.nb` and `Infrageometry1_notes.nb` in the repository root beside the paclet folder.
The author develops the design in the notebook; the LLM proposes additions in the notes and implements the accepted design.

See the [paclet design rules](skills/project-create/paclet-design.md).

### 4. Backlog management and execution

Define and refine work items, have agents execute them in parallel in separate worktrees, and review the results.
Work items follow the Kanban lifecycle Backlog → Ready → Active → UnderReview → Done, with each stage represented by a folder.
The plugin can deploy a web control board for managing the backlog.

See the [work-item format](Wiki/Concepts/ItemFileFormat.md) and [execution details](Wiki/Concepts/AutonomousPipeline.md).

## 📥 Installation

Requires the [Wolfram Engine](https://www.wolfram.com/engine/).
In **Claude Code**:

```bash
claude plugin marketplace add WolframInstitute/ClaudePluginMarketplace
claude plugin install computational-research@WolframInstitute
```

In **Claude Desktop**, install from the marketplace GUI.
Cowork and Chat mode have not been tested.

Install the official Wolfram MCP server from a Wolfram session:

```wolfram
InstallMCPServer["ClaudeCode", "WolframLanguage"]
```

| Server | Purpose |
|---|---|
| [Wolfram/AgentTools](https://resources.wolframcloud.com/PacletRepository/resources/Wolfram/AgentTools) — required | Computation, notebook I/O, documentation and tests |
| [arxiv-latex-mcp](https://github.com/takashiishida/arxiv-latex-mcp) — recommended | Download arXiv LaTeX sources |
| [arxiv](https://github.com/blazickjp/arxiv-mcp-server) — recommended | Search and download papers |

Each running Wolfram kernel uses a license seat.
The plugin prefers the existing MCP kernel and checks capacity before starting another; see the [kernel policy](CLAUDE.md#wolfram-kernel-execution-policy).

## 🧩 Functionality

### ⚙️ Autosetup

| Skill / command | Purpose |
|---|---|
| [project-check-env](commands/project-check-env.md) | Check tools, kernel access and license capacity |
| — | Automatic setup: [planned](Work/Backlog/AutoSetup.md), no skill yet |

### 📁 Autoorganization

| Skill / command | Purpose |
|---|---|
| [project-create](skills/project-create/SKILL.md) | Set up a research, mathematics or paclet project |
| [project-load](commands/project-load.md) | Summarize the project and next steps |
| [project-clean](commands/project-clean.md) | Move superseded material into `Archive/` |

### 📚 Autoknowledge

| Skill / command | Purpose |
|---|---|
| [wiki-init](skills/wiki-init/SKILL.md) | Start the wiki |
| [wiki-update](skills/wiki-update/SKILL.md) | Record new findings |
| [wiki-check](skills/wiki-check/SKILL.md) | Find gaps, stale entries and broken links |

### 🔍 Autoresources

| Skill / command | Purpose |
|---|---|
| [wiki-add-resource](skills/wiki-add-resource/SKILL.md) | Save and summarize a source |
| [wiki-search-wolfram](skills/wiki-search-wolfram/SKILL.md) | Search Wolfram documentation, repositories and Community |
| [wiki-search-math](skills/wiki-search-math/SKILL.md) | Search MathWorld, nLab, OEIS, DLMF and Wikipedia |
| [paper-cite](skills/paper-cite/SKILL.md) | Make BibTeX from an arXiv ID or DOI |

### 🐺 Notebook and Markdown conversion

| Skill / command | Purpose |
|---|---|
| [notebook-create](skills/notebook-create/SKILL.md) | Convert between Wolfram notebooks and Markdown |

### 📓 Expository notebooks and mathematics papers

| Skill / command | Purpose |
|---|---|
| [notebook-create](skills/notebook-create/SKILL.md) | Create or edit an expository Wolfram notebook |
| [paper-create-notebook](skills/paper-create-notebook/SKILL.md) | Write a requested mathematics paper as a notebook |
| [paper-create-note](skills/paper-create-note/SKILL.md) | Turn a conversation into a mathematical note |

### 📦 Paclet development and publishing

| Skill / command | Purpose |
|---|---|
| [paclet-build](skills/paclet-build/SKILL.md) | Build and install locally |
| [paclet-docs](skills/paclet-docs/SKILL.md) | Write function reference pages |
| [paclet-publish](skills/paclet-publish/SKILL.md) | Publish the paclet and documentation when requested |

### 📝 Human-owned papers and paclet designs

| Skill / command | Purpose |
|---|---|
| [paper-create](skills/paper-create/SKILL.md) | Set up a LaTeX or Typst paper and its notes |
| [document-setup](skills/document-setup/SKILL.md) | Identify the current document and notes; create a missing pair when requested |
| [document-propose](skills/document-propose/SKILL.md) | Investigate a question and put proposed additions in the notes |
| [document-compare](skills/document-compare/SKILL.md) | Compare the document with proposals, proofs or code |

### 📐 Proof formalization in Lean

| Skill / command | Purpose |
|---|---|
| [paper-lean](skills/paper-lean/SKILL.md) | Formalize proofs with Lean and Mathlib |

### 🧮 Paper verification

| Skill / command | Purpose |
|---|---|
| — | [Planned](Work/Backlog/PaperVerification.md); no skill yet |

### 📔 Scientific journal

| Skill / command | Purpose |
|---|---|
| [paper-journal](skills/paper-journal/SKILL.md) | Keep an optional cited scientific journal |

### 🧬 Prompt provenance

| Skill / command | Purpose |
|---|---|
| [project-provenance](skills/project-provenance/SKILL.md) | Optionally record prompts behind generated work; retain revision history |

### 🗃️ Autolab

| Skill / command | Purpose |
|---|---|
| [backlog-add](skills/backlog-add/SKILL.md) | Record a work item |
| [backlog-refine](skills/backlog-refine/SKILL.md) | Refine its plan and tasks with you |
| [backlog-info](skills/backlog-info/SKILL.md) | Review the backlog with you |
| [backlog-board](skills/backlog-board/SKILL.md) | Show an editable web board |
| [backlog-run](skills/backlog-run/SKILL.md) | Run one task, then stop |
| [backlog-autolab](skills/backlog-autolab/SKILL.md) | Execute Ready tasks with background workers |
| [backlog-run-scheduled](commands/backlog-run-scheduled.md) | Run unattended for scheduled jobs |
| [backlog-review](skills/backlog-review/SKILL.md) | Check results against your acceptance criteria |

### 🤝 Document review and revision

| Skill / command | Purpose |
|---|---|
| [document-revise](skills/document-revise/SKILL.md) | Revise a generated document from your comments and edits |

### 🧭 Guided project tours

| Skill / command | Purpose |
|---|---|
| [project-tour](skills/project-tour/SKILL.md) | Give a guided project walkthrough |

## 📄 License

Code: [MIT](https://opensource.org/license/mit).
Ideas: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
