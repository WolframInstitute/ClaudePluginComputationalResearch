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
* 📝 Sets up LaTeX or Typst papers and edits them on request.
* 📐 Formalizes proofs in Lean.
* 🧮 **Paper verification** builds code and tests beside a mathematics paper and checks it statement by statement.
* 📔 Keeps a scientific journal of what was learned, if you want one.
* 🧬 Records the prompt behind everything it generates, if you want that.
* 🗃️ **Autolab** manages a backlog of work and works through it while you are away.
* 🤝 Shows you every deliverable, and revises it from the notes you write into it, keeping every version and remembering your corrections.
* 🧭 Gives a guided tour of the project.

## 📥 Installation

Runs on the [Wolfram Engine](https://www.wolfram.com/engine/), which is freely available; no notebook interface is needed.
Install the plugin in **Claude Code** (CLI or VS Code extension):

```bash
claude plugin marketplace add WolframInstitute/ClaudePluginMarketplace
claude plugin install computational-research@WolframInstitute
```

In the **Claude Desktop app**, install it from the marketplace GUI.
Then set up the servers; see *Autosetup* below.

## 🧩 Functionality

### ⚙️ Autosetup

A research tool should not cost a day of setup.
You choose the parts, and the plugin installs them and checks that they work.

| Server | Required | Purpose | Source |
|--------|----------|---------|--------|
| **Wolfram** (official) | yes | Evaluation, notebook I/O, docs search, tests | [Wolfram/AgentTools](https://resources.wolframcloud.com/PacletRepository/resources/Wolfram/AgentTools) |
| **arxiv-latex-mcp** | recommended | Download LaTeX source of arXiv papers | [takashiishida/arxiv-latex-mcp](https://github.com/takashiishida/arxiv-latex-mcp) |
| **arxiv** | recommended | Search and download arXiv papers | [blazickjp/arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server) |

Until the setup skill lands, install the official Wolfram server by hand, from a Wolfram session:

```wolfram
InstallMCPServer["ClaudeCode", "WolframLanguage"]
```

**🔑 License seats.** Every running kernel — each Wolfram MCP server, each open front end, each `wolframscript` call — takes one of your `$MaxLicenseProcesses` seats. The plugin is MCP-first and checks headroom before spawning a kernel; see the [kernel execution policy](CLAUDE.md#wolfram-kernel-execution-policy).

| Skill | What it does |
|---|---|
| **setup** | Ask what you want, then install and check it — in design, see [AutoSetup](Work/Backlog/AutoSetup.md) |
| [project-check-env](commands/project-check-env.md) | Check that the kernel and the servers respond, and how many license seats are free |

<details>
<summary>Notes</summary>

* Operation in Cowork mode and Chat mode has not been tested.
* On older Wolfram versions the legacy [Wolfram/MCPServer](https://resources.wolframcloud.com/PacletRepository/resources/Wolfram/MCPServer) paclet still works as a fallback.
* The unofficial [sw1sh/WolframMCP](https://github.com/sw1sh/WolframMCP) server is optional; it adds Wolfram Language LSP support, similar to [Serena](https://github.com/oraios/serena).
* Running both Wolfram MCP servers at once uses two license seats — `/computational-research:project-check-env` reports live headroom and flags this.

</details>

### 📁 Autoorganization

A project is a plain git repository that you can read without the plugin.
What the plugin writes and what you write never mix.

```
Project/
  Code/          the code, and notebooks about it
  Research/      papers, research notebooks, notes
  Wiki/          what the project knows
  Work/          what it is doing
  Resources/     what it has read
```

Every folder that holds documents has the same three places:

```
Research/
  GeodesicPools_260919.tex      a document in progress
  GeodesicPools_260919_2.tex    its next version
  Artifacts/                    what the plugin made once, on request
  Archive/                      earlier versions, moved aside
```

* **The folder itself** holds the documents in progress: the ones you write, and the ones you and the plugin write together, one numbered version per round.
* **`Artifacts/`** holds what the plugin made once: a notebook you asked for, a note on a conversation, an exploration. One dated name per artifact, and an index.
* **`Archive/`** holds what is superseded: earlier versions and older artifacts, moved there when you clean up. Nothing is deleted.

**The plugin never overwrites a file.**
It writes a new artifact, or the next version of a document beside the last one, and only when you ask.
Outside `Artifacts/` it writes only when you ask.
A request that does not say where it goes lands in `Artifacts/`, so nothing of yours is touched.
To keep working on an artifact, move it up into the folder; from then on it is a document in progress.
A project that already has a `Paper/` folder keeps using it; nothing is moved.
The convention is spelled out in [artifacts.md](skills/notebook-create/artifacts.md).

| Skill | What it does |
|---|---|
| [project-create](skills/project-create/SKILL.md) | Set up a new project — research, mathematics, or paclet development |
| [project-load](commands/project-load.md) | Summarize where the project stands and what to do next |
| [project-tour](skills/project-tour/SKILL.md) | Walk you through the project, topic by topic, with code to run |
| [project-provenance](skills/project-provenance/SKILL.md) | Record the prompt behind each generated file, off by default; and, always on, the provenance file of every revised document |

### 🤝 Revision

Nothing the plugin makes is final until you have read it.
You review in the document itself, not in the chat, and you may edit it there directly.
Any document works: a notebook, a LaTeX or Typst paper, a Markdown file, code.
This is how you and the plugin write one document together, round after round.

To revise a document with the AI:

1. **Ask for it.** The plugin writes version 1, `Note_260928.tex` or `Note_260928.nb`, and beside it `Note_260928.provenance.md`, which starts with your request.
   Say where it goes: a document you will keep working on belongs in the folder itself, `Research/` for a paper or a note, and a one-off in `Artifacts/`, which is also where a request that does not say goes.
2. **Write notes into it** wherever something should change: `<< make this example smaller >>`.
   A note can sit inside a sentence or run over several lines; in code it goes inside a comment, as in `(* << use a smaller graph >> *)`.
   Edit the text yourself wherever that is quicker.
3. **Ask for a revision** (`/document-revise Note_260928.nb`, or just "revise it").
   The plugin writes the next version beside the old one, with the next number: `Note_260928_2.nb`, then `_3`.
   It changes only what your notes ask, keeps every edit you made, and adds nothing you did not ask for.
   It never edits the version you wrote your notes in, so every round stays on record.
4. **Read the reply.** It lists each note with what was done.
   A note it could not act on stays in the new version, followed by `<< not done: … >>`.
5. **Repeat on the latest version** until you are satisfied.

The document remembers how you revised it.
Its provenance file records every note with the lines it was about, every edit you made by hand, and everything you said in the chat about the document.
From these it keeps a short list of rules, such as "example graphs have at most 10 vertices", and reads them before every round, so a correction you made once is not needed again.
The reply shows each new rule; to overrule one, edit or delete it in the file.
For a notebook, the notes point at lines of its Markdown source: each version of a generated notebook keeps its `.md` beside it.

Each round is committed to git: the text files and each notebook's `.md`, but not the generated notebooks.
When you are done, clean up the folder: earlier versions move into its `Archive/` subfolder, made if it is missing, and only the latest stays in view, with its provenance file.
Nothing is deleted.

| Skill | What it does |
|---|---|
| [document-revise](skills/document-revise/SKILL.md) | Show every deliverable and wait; on request, write the next version from your notes, remembering past rounds |
| [project-clean](commands/project-clean.md) | Move earlier versions into `Archive/` |

### 📚 Autoknowledge

What a project learns should outlast the session that learned it, so the wiki keeps it.

| Skill | What it does |
|---|---|
| [wiki-init](skills/wiki-init/SKILL.md) | Start a wiki in the project |
| [wiki-update](skills/wiki-update/SKILL.md) | Record what was learned after a piece of work |
| [wiki-check](skills/wiki-check/SKILL.md) | Find stale articles, gaps and broken links |

### 🔍 Autoresources

A source is useful only if you can find it again.
Each one is saved with a summary and the steps to get it back.

| Skill | What it does |
|---|---|
| [wiki-add-resource](skills/wiki-add-resource/SKILL.md) | Save a paper, repository or page, with how to get it back |
| [wiki-search-wolfram](skills/wiki-search-wolfram/SKILL.md) | Search the Wolfram documentation, Function Repository and Community |
| [wiki-search-math](skills/wiki-search-math/SKILL.md) | Search MathWorld, nLab, OEIS, DLMF and Wikipedia |
| [paper-cite](skills/paper-cite/SKILL.md) | Make a BibTeX entry from an arXiv ID or a DOI |

### 📦 Notebooks and paclets

Code is worth most when others can run it.
Notebooks explain it, and paclets ship it, with each exported function standing on its own.
Every project gets one house style for Wolfram code — spaced brackets, chained `With`, the body on its own line, no comments, colours that read in light and dark mode — and every generated notebook is a walkthrough in pictures, marked `[[ LLM Generated ]]` under its title.

| Skill | What it does |
|---|---|
| [notebook-create](skills/notebook-create/SKILL.md) | Build a Wolfram notebook from Markdown, or edit one |
| [paclet-build](skills/paclet-build/SKILL.md) | Build a paclet and install it locally |
| [paclet-docs](skills/paclet-docs/SKILL.md) | Write a reference page for every exported function |
| [paclet-publish](skills/paclet-publish/SKILL.md) | Build with documentation and publish to the Wolfram Cloud |

### 📝 Papers and mathematics

A result is settled only when its proof is complete.
The paper carries what is settled, and the journal keeps everything else, so nothing is lost.

| Skill | What it does |
|---|---|
| [paper-create](skills/paper-create/SKILL.md) | Add a LaTeX or Typst paper, then edit it on request |
| [paper-create-notebook](skills/paper-create-notebook/SKILL.md) | Write a mathematics paper as a notebook, with complete proofs |
| [paper-create-note](skills/paper-create-note/SKILL.md) | Turn a conversation into a dated note: claims, proofs, and the code behind them |
| [paper-journal](skills/paper-journal/SKILL.md) | Keep a cited journal of what was learned, and what a paper cannot carry; off by default |
| [paper-lean](skills/paper-lean/SKILL.md) | Formalize a proof in Lean with Mathlib |

### 🧮 Paper verification

A reader should know what a computer checked, and what they must still take on trust.
You bring a LaTeX paper; the plugin builds the code and tests beside it and reviews the paper one labeled statement at a time.
Each statement ends with an honest status: what was checked, and how far the check reaches.
Your paper is read, never written.
In design, see [PaperVerification](Work/Backlog/PaperVerification.md).

### 🗃️ Autolab

Long work goes wrong when one session carries too much.
So work is split into small tasks, each done in a fresh session, and agents may run them while you are away.

A **work item** is one Markdown file in `Work/`.
You write what you want, why, and how you will accept it; the plugin writes the technical plan and the tasks.
Its status is the folder it sits in, and it moves Backlog → Ready → Active → UnderReview → Done.
Every move is yours except one: the last task moves the item to UnderReview, where you check it against your acceptance criteria.

Each step of an item's life has its skill:

1. **File it** in the backlog, in a few sentences.
2. **Refine it** with the plugin, over as many sittings as it takes, until it is ready to run.
   You refine an item; you revise a document.
3. **Go through the backlog** now and then: what waits on you, what has gone stale, what to refine, merge or drop next.
4. **Run it**, one task per fresh session, yourself or by agents while you are away.
5. **Review it** when all tasks are done: the plugin walks you through your acceptance criteria and each task's test instructions, and you accept it or send it back with a new task.

| Skill | What it does |
|---|---|
| [backlog-add](skills/backlog-add/SKILL.md) | File an item in the backlog: what you want, why, and how you will accept it |
| [backlog-refine](skills/backlog-refine/SKILL.md) | Shape one backlog item with you until it is ready to run |
| [backlog-info](skills/backlog-info/SKILL.md) | Go through the whole backlog with you; items move only on your word |
| [backlog-board](skills/backlog-board/SKILL.md) | A board of all items that you can read and edit on your phone |
| [backlog-run](skills/backlog-run/SKILL.md) | Run the next task of an item, then stop |
| [backlog-autolab](skills/backlog-autolab/SKILL.md) | Work the backlog while you are away, one background worker per task that you can watch and message |
| [backlog-run-scheduled](commands/backlog-run-scheduled.md) | The same without a chat, for scheduled runs |
| [backlog-review](skills/backlog-review/SKILL.md) | Check a finished item with you: accept it, or send it back with a new task |

Agents pick only items you have moved to Ready, stop at any task marked for a human, and leave their results on a branch for you to review.

**Several sessions at once.**
Your own sessions, the agents, and a colleague's may work the same backlog.
An item is claimed by its branch: whoever works it does so on the item's own branch in its own worktree, and git lets a branch be checked out only once.
So two sessions never take the same item, and a checkout never sees another's half-done work.
The `Work/` folders stay the one list; the board and any outside kanban tool are views of it.
In design, see [ParallelSessions](Work/Backlog/ParallelSessions.md).
The file format is in [ItemFileFormat](Wiki/Concepts/ItemFileFormat.md); how the unattended runs work, and what they cost, is in [AutonomousPipeline](Wiki/Concepts/AutonomousPipeline.md).

## 📄 License

Code: [MIT](https://opensource.org/license/mit).
Ideas: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
