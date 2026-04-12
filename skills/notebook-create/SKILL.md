---
name: notebook-create
description: >
  Create or modify Wolfram Notebooks (.nb) from structured Markdown content
  using the Wolfram MCP. This is the unified notebook skill — use it for
  creating new notebooks, editing existing ones, or converting Wiki/Notebooks/
  markdown sources into .nb files. Triggers on: "create notebook", "make a
  notebook", "notebook about X", "edit notebook", "update notebook",
  "put this in a notebook", "generate .nb". Also used by other skills
  (project-init, tour-start) when they produce notebooks.
---

## Hard Rules

- **NEVER** read a `.nb` file with the `Read` tool or load its raw content into the
  context window. To work with an existing notebook, export to Markdown first
  via `ExportString[Import[path], "Markdown"]` in the Wolfram MCP.
- **NEVER** use `Export[path, ...]` in MCP code — always `ExportString[...]` and write
  the result with the `Write` tool.

# Wolfram Notebook Pipeline

**All skills that create or modify `.nb` files must use this skill's pipeline and
conventions** — including math formatting, backtick escaping, and post-processing.

The core technique:

```
ExportString[ImportString[markdownString, {"Markdown", "Notebook"}], "NB"]
```

No temporary files are created. The markdown lives as a string in the Wolfram kernel,
gets imported as a Notebook expression, post-processed, then serialized back to a
string via `ExportString`. You then write that string to the target `.nb` file using
the local `Write` tool.

## Two-layer architecture

Notebook sources are Markdown files in `Wiki/Notebooks/`. They get converted to `.nb`
files in `Notebooks/` (gitignored).

```
Wiki/Notebooks/Name.md   ← tracked in git, source of truth
Notebooks/Name.nb        ← gitignored, generated from source
```

### When to use the source layer

- Creating a notebook intended to persist across sessions → write `Wiki/Notebooks/Name.md`
  as the source, then generate `.nb`
- Quick one-off exploration → generate `.nb` directly, skip the wiki source

### Source format (Wiki/Notebooks/Name.md)

A structured Markdown file following the cell mapping rules below. Example:

```markdown
# Title

## Setup
<!-- Package loads, initialization — becomes InitializationCells -->

## Topic A
<!-- Narrative text and code blocks -->

## Topic B
<!-- More narrative and code -->
```

Use fenced code blocks tagged `wolfram` for evaluatable Input cells. Plain text
becomes Text cells.

### Generating .nb from source

Read `Wiki/Notebooks/Name.md`, pass its content through the Wolfram MCP pipeline
(below), write the result to `Notebooks/Name.nb`.

Alternatively, run `Scripts/generate_notebooks.wls` to batch-convert
all wiki notebook sources:

```bash
wolframscript -file Scripts/generate_notebooks.wls
```

To also publish to Wolfram Cloud:

```bash
wolframscript -file Scripts/publish_notebooks.wls
```

### Registering a notebook

After creating a notebook with a wiki source:

1. Add entry to `Wiki/Index.md` under Notebooks
2. Append to `Wiki/Log.md`

## Which MCP tool to use

### With WolframPacletDevelopment profile (preferred)

If the official Wolfram MCP is running the `WolframPacletDevelopment` profile,
use the native notebook tools:

- `mcp__Wolfram__WriteNotebook` — write notebook content directly
- `mcp__Wolfram__ReadNotebook` — read existing notebook content

These handle `.nb` files natively without the Markdown→ImportString workaround.

### Markdown pipeline (fallback)

If `WriteNotebook`/`ReadNotebook` are not available (older profile), use the
**Markdown→notebook pipeline** via `mcp__Wolfram__WolframLanguageEvaluator`:

```wolfram
ExportString[ImportString[markdownString, {"Markdown", "Notebook"}], "NB"]
```

### Unofficial Wolfram MCP

When the unofficial MCP (`mcp__wolfram__`) is available, use its **LSP tools**
(hover_info, find_definition, find_references, get_diagnostics,
document_symbols) for code navigation. Do not use its notebook-manipulation
tools when the official MCP is available.

### Last resort

If no MCP is available, create a minimal `.nb` manually using the `Write` tool
with raw NB format. Warn the user.

To check availability: evaluate `1+1` with the official MCP.

## Backtick escaping — Critical

The Wolfram MCP interprets raw backtick characters as Wolfram context marks.
Triple-backtick fences in markdown strings get corrupted if written as literal characters.

**Always construct backticks via `FromCharacterCode`:**

```
tick = FromCharacterCode[96];
fence = StringJoin[tick, tick, tick];
```

Then use `fence` when building the markdown string:

```
md = "# Title\n\n" <> fence <> "wolfram\nPlot[Sin[x],{x,0,2Pi}]\n" <> fence <> "\n\n";
```

For inline code, use a single `tick`. For Wolfram package names containing context
marks (e.g., `"Needs[\"MyPackage`\""]`), use:
```
"Needs[\"MyPackage" <> tick <> "\"]"
```

This is the single most important rule. Without it, code blocks will not parse as
Input cells.

## Why ExportString instead of Export

The Wolfram MCP kernel runs in a separate process with its own filesystem. `Export[...]`
writes to the kernel's filesystem, which is **not** the local filesystem. Use
`ExportString` to get the `.nb` content as a string, then use the `Write` tool to
save locally.

## Pipeline

### Creating a new notebook

1. **Compose** well-structured Markdown following the mapping rules below
2. **Evaluate** via the Wolfram MCP: build string → `ImportString` → post-process → `ExportString`
3. **Write** the returned string to the target `.nb` file using the `Write` tool
4. **Verify** by checking file size or evaluating
   `Length[First[Import["/path/to/file.nb"]]]` via the official MCP

### Modifying an existing notebook

1. **Export** → `ExportString[Import["/path/to/file.nb"], "Markdown"]` via the official Wolfram MCP
2. **Edit** the Markdown string (find/replace, append, restructure)
3. **Re-import** through the full pipeline: `ImportString` → post-process → `ExportString`
4. **Write** back to the original path (or a new file if the user wants to keep the original)
5. **Verify** cell count

**Short notebooks** (< ~30 cells): rebuild entirely from Markdown.
**Long notebooks**: export → patch the relevant section → re-import.

**Appending to a notebook**: export → append new Markdown sections at the end → re-import the full combined string.

Do **not** manipulate raw `.nb` cell lists by hand — always go through the Markdown round-trip.

## Claude Desktop / VM mode

When running inside a VM (Claude Desktop Projects or sandboxed environment):

- Confirm that a shared folder exists and is accessible
- The `ExportString` + `Write` pipeline works on mounted filesystems
- Cell count verification via `Import` may fail — check file size instead

## Named templates

When the user doesn't specify a structure, infer from context or ask:

### `research` template
```
# <Title>
## Setup        ← package loads (become InitializationCells)
## Exploration  ← initial computations and visualizations
## Results      ← key findings and summaries
## Discussion   ← interpretation, conjectures, next steps
```

### `paper-analysis` template
```
# <Title>
## Paper Metadata   ← full title, authors, year, arXiv ID
## Summary          ← 3–4 sentence abstract in own words
## Key Definitions  ← brief explanations of terms
## Key Results      ← one sentence per theorem/result
## Relevance        ← connection to current project
## Code             ← reproduce or verify key computations
```

### `computation` template
```
# <Title>
## Setup          ← package loads and configuration
## Algorithm      ← pseudocode or description (CodeText cells)
## Implementation ← actual Wolfram Language code
## Tests          ← verification against known cases
## Visualization  ← plots and graphics
```

## Markdown-to-cell mapping

### Headings → Notebook Structure

| Markdown | Cell Style | Notebook Role |
|----------|-----------|---------------|
| `# Title` | `"Title"` | Notebook title (use once, at top) |
| `## Chapter` | `"Chapter"` | Major division |
| `### Section` | `"Section"` | Section heading |
| `#### Subsection` | `"Subsection"` | Subsection heading |
| `##### Subsubsection` | `"Subsubsection"` | Subsubsection heading |

### Text and Formatting

| Markdown | Result |
|----------|--------|
| Plain paragraph | `Cell["...", "Text"]` |
| `**bold**` | `StyleBox["...", FontWeight->Bold]` |
| `*italic*` | `StyleBox["...", FontSlant->Italic]` |
| inline code (single backtick) | `Cell["...", "InlineCode"]` within TextData |
| `[text](url)` | Clickable hyperlink (ButtonBox) |
| `> blockquote` | Text cell with left border frame |

### Lists

| Markdown | Cell Style |
|----------|-----------|
| `- item` | `"Item"` |
| `  - subitem` (2-space indent) | `"Subitem"` |
| `1. first` | `"ItemNumbered"` |

### Math (LaTeX)

| Markdown | Result |
|----------|--------|
| `$...$` | Inline math — `InlineMath` within TextData |
| `$$...$$` | Display math — `DisplayFormula` cell |

**Use math liberally.** Definitions, theorems, formulas, variable references → LaTeX.

**Escaping in Wolfram strings:** double all backslashes in LaTeX math:

```wolfram
md = "The curvature $\\kappa(x,y)$ is defined as\n\n$$\\kappa(x,y) = 1 - \\frac{W_1(\\mu_x, \\mu_y)}{d(x,y)}$$\n\n";
```

Common LaTeX commands that work: `\frac`, `\sum`, `\int`, `\partial`,
`\mathbb`, `\mathcal`, `\alpha`–`\omega`, `\in`, `\subset`, `\to`, `\mapsto`,
`\leq`, `\geq`, `\neq`, `\infty`, `\ldots`, `\cdots`, `\text`.

**Wolfram notation vs LaTeX in text cells:**
- **Simple symbols** (Greek, relations, arrows): Wolfram `\[Alpha]`, `\[Element]`
  etc. work — they become Unicode.
- **Structural math** (fractions, sub/superscripts): use LaTeX `$\frac{a}{b}$`, `$x_i$`.
- **Blackboard bold**: use LaTeX `$\mathbb{R}$`.

### Code blocks

| Markdown fence tag | Cell Style | Purpose |
|----------|-----------|---------|
| `wolfram` | `"Input"` | Evaluatable Wolfram code |
| (no tag) | `"Program"` → post-processed to `"CodeText"` | Display-only code |

### Tables

Standard Markdown tables become interactive Tabular/TableView cells.

## Post-processing

After `ImportString`, apply these transformations before `ExportString`:

### 1. Rename `"Program"` → `"CodeText"`

```wolfram
cells /. Cell[content_, "Program", opts___] :> Cell[content, "CodeText", opts]
```

### 2. Initialization cells

Mark Input cells under "Setup"/"Initialization"/"Dependencies"/"Preamble" headings:

```wolfram
markInitCells[cellList_List] := Module[{inSetup = False, result = {}},
  Do[Which[
    MatchQ[c, Cell[t_String, "Chapter"|"Section"|"Subsection", ___] /;
      StringMatchQ[t, ("*Setup*"|"*Initialization*"|"*Preamble*"|"*Dependencies*"),
        IgnoreCase -> True]],
      inSetup = True; AppendTo[result, c],
    MatchQ[c, Cell[_, "Title"|"Chapter"|"Section"|"Subsection"|"Subsubsection", ___]],
      inSetup = False; AppendTo[result, c],
    inSetup && MatchQ[c, Cell[_, "Input", ___]],
      AppendTo[result, Append[c, InitializationCell -> True]],
    True, AppendTo[result, c]
  ], {c, cellList}];
  result
];
```

Uses `StringMatchQ` with wildcards to avoid false positives (e.g., "Indefinite Integrals"
must NOT trigger).

## The complete Wolfram MCP call

```wolfram
Module[{md, nb, cells, markInitCells, tick, fence},

  tick = FromCharacterCode[96];
  fence = StringJoin[tick, tick, tick];

  markInitCells[cellList_List] := Module[{inSetup = False, result = {}},
    Do[Which[
      MatchQ[c, Cell[t_String, "Chapter"|"Section"|"Subsection", ___] /;
        StringMatchQ[t, ("*Setup*"|"*Initialization*"|"*Preamble*"|"*Dependencies*"),
          IgnoreCase -> True]],
        inSetup = True; AppendTo[result, c],
      MatchQ[c, Cell[_, "Title"|"Chapter"|"Section"|"Subsection"|"Subsubsection", ___]],
        inSetup = False; AppendTo[result, c],
      inSetup && MatchQ[c, Cell[_, "Input", ___]],
        AppendTo[result, Append[c, InitializationCell -> True]],
      True, AppendTo[result, c]
    ], {c, cellList}];
    result
  ];

  md = StringJoin[
    "# My Notebook Title\n\n",
    "Introductory text.\n\n",
    "## Setup\n\n",
    fence, "wolfram\nNeeds[\"Pkg", tick, "\"]\n", fence, "\n\n",
    "## Analysis\n\n",
    "Explanatory text.\n\n",
    fence, "wolfram\nPlot[Sin[x], {x, 0, 2 Pi}]\n", fence, "\n"
  ];

  nb = ImportString[md, {"Markdown", "Notebook"}];
  cells = First[nb];
  cells = cells /. Cell[content_, "Program", opts___] :> Cell[content, "CodeText", opts];
  cells = markInitCells[cells];
  ExportString[Notebook[cells], "NB"]
]
```

## After the MCP call

1. Write the returned string to the target file via the `Write` tool
2. **Verify** by checking file size or evaluating
   `Length[First[Import["/path/to/file.nb"]]]` via the official MCP

## String construction rules

Always build markdown with `StringJoin` using `fence` and `tick` variables.
Never write literal backtick characters.

**Escaping rules** (markdown inside a Wolfram Language string):

- `\` → `\\`
- `"` → `\"`
- Newlines: `\n`
- Backticks: NEVER literal — always use `tick` / `fence` variables
- Wolfram context marks: use `tick` variable

## Long notebook pattern

For notebooks with > ~30 cells, build per-section chunks:

```wolfram
section1 = StringJoin["## Section 1\n\n", "Text.\n\n", fence, "wolfram\n...\n", fence, "\n\n"];
section2 = StringJoin["## Section 2\n\n", "Text.\n\n", fence, "wolfram\n...\n", fence, "\n\n"];
md = StringJoin["# Title\n\n", section1, section2];
```

## Content best practices

- One `# Title` at the top — only once
- `## Setup` for package loads and configuration (becomes initialization cells)
- One logical operation per `wolfram` code block
- Narrative Text paragraphs between code blocks
- Bullet lists for enumerated points
- Tables for structured comparisons
- Untagged fences for pseudocode or expected output (become CodeText)
- Bold for key terms
- Inline math for variables and short formulas
- Display math for definitions and important equations

## Naming conventions

- Single-topic notebooks: `TopicName.md` / `TopicName.nb`
- Paper analysis: `Author_Year.md`
- Chains/multi-topic: descriptive name (`UniversalityGraph.md`)
