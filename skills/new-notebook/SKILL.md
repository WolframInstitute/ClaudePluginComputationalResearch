---
name: new-notebook
description: >
  Create or modify Wolfram Notebooks (.nb) from structured Markdown content
  using the Wolfram MCP. This is the unified notebook skill — use it for
  creating new notebooks, editing existing ones, or converting NotebooksLLM/
  markdown sources into .nb files. Triggers on: "create notebook", "make a
  notebook", "notebook about X", "edit notebook", "update notebook",
  "put this in a notebook", "generate .nb". Also used by other skills
  (new-project, start-tour) when they produce notebooks.
---

## Hard Rules

- **NEVER** read a `.nb` file with the `Read` tool or load its raw content into the context window.
  To work with an existing notebook, export to Markdown first via `ExportString[Import[path], "Markdown"]` in the Wolfram MCP.
- **NEVER** use `Export[path, ...]` in MCP code — always `ExportString[...]` and write the result with the `Write` tool.

## Kernel execution (license-aware)

This skill runs entirely on the AgentTools MCP (`mcp__Wolfram__WriteNotebook`, `mcp__Wolfram__ReadNotebook`, `mcp__Wolfram__WolframLanguageEvaluator`) — one persistent kernel, no extra license seat.
The batch `Scripts/generate_notebooks.wls` / `Scripts/publish_notebooks.wls` helpers spawn a fresh `wolframscript` kernel and are a **license-gated fallback** for bulk runs only.
Before invoking them, confirm a seat is free via the MCP:

```wolfram
With[{free = $MaxLicenseProcesses - $LicenseProcesses}, free]
```

If `free <= 0`, generate notebooks one at a time through the MCP instead of calling the batch scripts.

# Wolfram Notebook Pipeline

**All skills that create or modify `.nb` files must use this skill's pipeline and conventions** — including math formatting, backtick escaping, and post-processing.

The core technique:

```
ExportString[ImportString[markdownString, {"Markdown", "Notebook"}], "NB"]
```

No temporary files are created.
The markdown lives as a string in the Wolfram kernel, gets imported as a Notebook expression, post-processed, then serialized back to a string via `ExportString`.
You then write that string to the target `.nb` file using the local `Write` tool.

## Where notebooks live — Critical

All LLM notebook artifacts live in `NotebooksLLM/`.
The plain `Notebooks/` folder is reserved for user-authored notebooks — **never read, write, or overwrite anything in `Notebooks/`.** Within `NotebooksLLM/` you may freely create and overwrite; you may not touch `Notebooks/`.

## Two-layer architecture (co-located)

Source and output live side by side in `NotebooksLLM/`:

```
NotebooksLLM/Name.md              ← tracked in git, source of truth
NotebooksLLM/Name_YYYY-MM-DD.nb   ← gitignored (NotebooksLLM/*.nb), generated from the .md
Notebooks/                        ← user-authored notebooks; LLM never touches these
```

The `.md` source is the durable, hand-editable artifact; the `.nb` is regenerated from it.
These are **not** wiki articles — they do not go in `Wiki/`.

The generated `.nb` filename carries the source's **first-creation date** as a `_YYYY-MM-DD` suffix.
The date is stamped once, when the notebook is first generated, and **preserved on every later regeneration** — `generate_notebooks.wls` reuses the earliest date already present in the folder and deletes any other-dated or legacy un-dated copy, so exactly one `.nb` survives per source.
The date lives only in the filename; **do not** put it inside the notebook (the `[LLM Generated]` subtitle stays undated).

### When to use the source layer

- Creating a notebook intended to persist across sessions → write `NotebooksLLM/Name.md` as the source, then generate the `.nb`
- Quick one-off exploration → generate `NotebooksLLM/Name_YYYY-MM-DD.nb` directly, skip the `.md` source

### Source format (NotebooksLLM/Name.md)

A structured Markdown file following the cell mapping rules below.
Example:

```markdown
# Title

## Setup
<!-- Package loads, initialization — becomes InitializationCells -->

## Topic A
<!-- Narrative text and code blocks -->

## Topic B
<!-- More narrative and code -->
```

Use fenced code blocks tagged `wolfram` for evaluatable Input cells.
Plain text becomes Text cells.

### Generating .nb from source

Read `NotebooksLLM/Name.md`, pass its content through the Wolfram MCP pipeline (below), write the result to `NotebooksLLM/Name_YYYY-MM-DD.nb`.
Use the first-creation date: if a `Name_*.nb` already exists, reuse its date and overwrite that file; otherwise use today's date.
The batch `generate_notebooks.wls` does this bookkeeping automatically.

Alternatively — **only as the license-gated fallback** (MCP unavailable and a seat free; see *Kernel execution* above) — run `Scripts/generate_notebooks.wls` to batch-convert all `.md` sources in `NotebooksLLM/`:

```bash
wolframscript -file Scripts/generate_notebooks.wls
```

To also publish to Wolfram Cloud:

```bash
wolframscript -file Scripts/publish_notebooks.wls
```

### Provenance (optional)

If the project has prompt tracking on (a `Prompt tracking: **on**` line in `CLAUDE.md` — see the [provenance](../provenance/SKILL.md) skill), record the originating prompt/intent for the notebook:

1. Write a leading `<!-- provenance: ... -->` comment at the top of the `NotebooksLLM/Name.md` source.
   `generate_notebooks.wls` strips it before import and injects it into the `.nb` as `Notebook[cells, TaggingRules -> {"Provenance" -> <|...|>}]`.
   Do **not** write `TaggingRules` yourself.
2. Append an entry to the `Wiki/Prompts.md` ledger.

When tracking is off (default), skip this — generate the notebook as usual.

## Which MCP tool to use

### With WolframPacletDevelopment profile (preferred)

If the official Wolfram MCP is running the `WolframPacletDevelopment` profile, use the native notebook tools:

- `mcp__Wolfram__WriteNotebook` — write notebook content directly
- `mcp__Wolfram__ReadNotebook` — read existing notebook content

These handle `.nb` files natively without the Markdown→ImportString workaround.

### Markdown pipeline (fallback)

If `WriteNotebook`/`ReadNotebook` are not available (older profile), use the **Markdown→notebook pipeline** via `mcp__Wolfram__WolframLanguageEvaluator`:

```wolfram
ExportString[ImportString[markdownString, {"Markdown", "Notebook"}], "NB"]
```

### Unofficial Wolfram MCP

When the unofficial MCP (`mcp__wolfram__`) is available, use its **LSP tools** (hover_info, find_definition, find_references, get_diagnostics, document_symbols) for code navigation.
Do not use its notebook-manipulation tools when the official MCP is available.

### Last resort

If no MCP is available, create a minimal `.nb` manually using the `Write` tool with raw NB format.
Warn the user.

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

For inline code, use a single `tick`.
For Wolfram package names containing context marks (e.g., `"Needs[\"MyPackage`\""]`), use:
```
"Needs[\"MyPackage" <> tick <> "\"]"
```

This is the single most important rule.
Without it, code blocks will not parse as Input cells.

## Why ExportString instead of Export

The Wolfram MCP kernel runs in a separate process with its own filesystem.
`Export[...]` writes to the kernel's filesystem, which is **not** the local filesystem.
Use `ExportString` to get the `.nb` content as a string, then use the `Write` tool to save locally.

## Pipeline

### Creating a new notebook

1. **Compose** well-structured Markdown following the mapping rules below
2. **Evaluate** via the Wolfram MCP: build string → `ImportString` → post-process → `ExportString`
3. **Write** the returned string to the target `.nb` file using the `Write` tool
4. **Verify** by checking file size or evaluating `Length[First[Import["/path/to/file.nb"]]]` via the official MCP

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

### `theorem-proof` template

For math-research projects (see [new-project](../new-project/SKILL.md) math-research type).
The full markdown skeleton is at `${CLAUDE_PLUGIN_ROOT}/skills/new-project/assets/notebook_theorem_proof_template.md` — copy it as the starting point, then specialize.

```
# <Theorem Name>
## Setup            ← package loads
## Definitions      ← terms used in the statement (linked to Wiki/Definitions/)
## Statement        ← precise theorem statement, numbered hypotheses
## Proof
###   Step 1        ← each major step is its own subsection
###   Step 2
###   Step N — Conclusion
## Corollaries      ← downstream results with brief proofs
## Examples         ← low-dimensional / finite verifications
## Non-examples     ← cases where a hypothesis fails (justifies hypotheses)
## References       ← Wiki/Theorems/ link + external refs
```

Notes:

- One `Subsection` per proof step (use `###`); within a step, alternate narrative text with `wolfram` code blocks that verify or illustrate.
- Hypotheses get numbered ItemNumbered cells so the proof can refer to them as "H1", "H2", etc.
- Use **display math** (`$$ ... $$`) for the theorem statement and key equations within the proof; **inline math** (`$ ... $`) for variables.
- The full `boxifyInputCells` + `markInitCells` post-processing applies as usual — do not skip them.

## Markdown-to-cell mapping

### Headings → Notebook Structure

The WL-15 markdown importer maps `#`→`Title`, `##`→`Chapter`, `###`→`Section`, `####`→`Subsection`.
That extra `Chapter` level is inconsistent with the rest of the corpus (which uses `Title`/`Section`/`Subsection`), so the post-processing **shifts every heading down one level** (`Chapter`→`Section`, `Section`→`Subsection`, `Subsection`→`Subsubsection`) immediately after `cells = First[nb]`.
The **final** styles a source author should expect:

| Markdown | Importer style | Final style (after shift) | Notebook Role |
|----------|----------------|---------------------------|---------------|
| `# Title` | `"Title"` | `"Title"` | Notebook title (use once, at top) |
| `## Section` | `"Chapter"` | `"Section"` | Major division |
| `### Subsection` | `"Section"` | `"Subsection"` | Subsection heading |
| `#### Subsubsection` | `"Subsection"` | `"Subsubsection"` | Subsubsection heading |

So author `##` headings render as `"Section"`, not `"Chapter"`.
A `**[LLM Generated]**` marker line in the source (the documented convention) is imported as a bold `"Text"` cell and normalized to a single `"Subtitle"` cell under the `"Title"` by the marker rules that run alongside the heading shift.

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

Common LaTeX commands that work: `\frac`, `\sum`, `\int`, `\partial`, `\mathbb`, `\mathcal`, `\alpha`–`\omega`, `\in`, `\subset`, `\to`, `\mapsto`, `\leq`, `\geq`, `\neq`, `\infty`, `\ldots`, `\cdots`, `\text`.

**Wolfram notation vs LaTeX in text cells:** - **Simple symbols** (Greek, relations, arrows): Wolfram `\[Alpha]`, `\[Element]` etc. work — they become Unicode. - **Structural math** (fractions, sub/superscripts): use LaTeX `$\frac{a}{b}$`, `$x_i$`. - **Blackboard bold**: use LaTeX `$\mathbb{R}$`.

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

### 2. Boxify Input/Code cells — Critical

`ImportString[md, {"Markdown", "Notebook"}]` produces `Cell[BoxData["raw string"], "Input"]` where the code is a single literal string inside `BoxData`.
The front end will display this, but **hover help, F1 lookup, autocomplete, and the suggestion bar will not work** — those features rely on a structural `RowBox` tree where each symbol name is a leaf string and function tokens (`FindPoint`) are adjacent to their argument bracket (`[`).

Boxify Input/Code cells via `ToBoxes[ToExpression[code, StandardForm, Defer]]` so the symbol structure is preserved — **except** cells that build graphics.

**Visualization guard — Critical.** Boxifying a cell whose code produces `Graphics` (`Plot`, `HighlightGraph`, `InfraSceneHighlight`, `ListLinePlot`, `GraphPlot`, charts, etc.) strands the cell with a `Map is not a Graphics primitive` error at front-end evaluation.
Leave those cells as plain-text `BoxData[content]` (same as the parse-failure fallback) and boxify everything else:

```wolfram
vizHeads = {"Graphics", "Plot", "HighlightGraph", "InfraSceneHighlight",
  "Chart", "Histogram", "Manipulate", "Animate", "ArrayPlot", "MatrixPlot",
  "DensityPlot", "ContourPlot", "RegionPlot", "GraphPlot", "Show[", "Graph["};
vizCellQ[content_String] := StringContainsQ[content, vizHeads];

boxifyInputCells[cellList_List] := cellList /. {
  Cell[BoxData[content_String], style:("Input"|"Code"), opts___] :>
    If[vizCellQ[content], Cell[BoxData[content], style, opts],
      With[{parsed = ToExpression[content, StandardForm, Defer]},
        If[parsed === $Failed,
          Cell[BoxData[content], style, opts],
          Cell[BoxData[ToBoxes[parsed]], style, opts]
        ]
      ]],
  Cell[content_String, style:("Input"|"Code"), opts___] :>
    If[vizCellQ[content], Cell[BoxData[content], style, opts],
      With[{parsed = ToExpression[content, StandardForm, Defer]},
        If[parsed === $Failed,
          Cell[BoxData[content], style, opts],
          Cell[BoxData[ToBoxes[parsed]], style, opts]
        ]
      ]]
};
```

`Defer` keeps the parsed expression unevaluated so `ToBoxes` produces the structural box tree without running the code.
Falls back to `BoxData[rawString]` if parsing fails (e.g. partial code) or if the cell is a visualization cell.

**Apply this AFTER `ImportString` and BEFORE `ExportString`** in every notebook pipeline.
Do not skip — without it, every Input cell ships broken.

### 3. Initialization cells

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

Uses `StringMatchQ` with wildcards to avoid false positives (e.g., "Indefinite Integrals" must NOT trigger).

### 4. LLM-generated subtitle — Critical

Every generated notebook is **explicitly marked as LLM-generated**: a `"Subtitle"` cell reading `[LLM Generated]` goes directly under the `"Title"` cell.
The marker text has **no inner spaces** — it matches the `**[LLM Generated]**` convention used in the markdown sources.

The marker can arrive two ways: (a) written into the markdown source as `**[LLM Generated]**`, which `ImportString` renders as a bold `"Text"` cell, or (b) injected here.
To avoid shipping both, **first normalize** any bold-Text marker to a `"Subtitle"` cell immediately after `cells = First[nb]` (see the heading and marker rules in the complete call below), **then** call `addLLMSubtitle`, which dedupes and places exactly one marker under the `"Title"`.
Insert it after `markInitCells` and before `ExportString`:

```wolfram
addLLMSubtitle[cellList_List] := Module[
  {cells = DeleteCases[cellList, Cell["[LLM Generated]", "Subtitle", ___]], pos},
  pos = FirstPosition[cells, Cell[_, "Title", ___], Missing[], {1}];
  If[MissingQ[pos],
    Prepend[cells, Cell["[LLM Generated]", "Subtitle"]],
    Insert[cells, Cell["[LLM Generated]", "Subtitle"], pos[[1]] + 1]]
];
```

Never ship an LLM-generated `.nb` without this marker (paclet code is exempt; notebooks are not).

## The complete Wolfram MCP call

```wolfram
Module[{md, nb, cells, markInitCells, boxifyInputCells, addLLMSubtitle, vizCellQ, vizHeads, tick, fence},

  tick = FromCharacterCode[96];
  fence = StringJoin[tick, tick, tick];

  vizHeads = {"Graphics", "Plot", "HighlightGraph", "InfraSceneHighlight",
    "Chart", "Histogram", "Manipulate", "Animate", "ArrayPlot", "MatrixPlot",
    "DensityPlot", "ContourPlot", "RegionPlot", "GraphPlot", "Show[", "Graph["};
  vizCellQ[content_String] := StringContainsQ[content, vizHeads];

  boxifyInputCells[cellList_List] := cellList /. {
    Cell[BoxData[content_String], style:("Input"|"Code"), opts___] :>
      If[vizCellQ[content], Cell[BoxData[content], style, opts],
        With[{parsed = ToExpression[content, StandardForm, Defer]},
          If[parsed === $Failed,
            Cell[BoxData[content], style, opts],
            Cell[BoxData[ToBoxes[parsed]], style, opts]
          ]
        ]],
    Cell[content_String, style:("Input"|"Code"), opts___] :>
      If[vizCellQ[content], Cell[BoxData[content], style, opts],
        With[{parsed = ToExpression[content, StandardForm, Defer]},
          If[parsed === $Failed,
            Cell[BoxData[content], style, opts],
            Cell[BoxData[ToBoxes[parsed]], style, opts]
          ]
        ]]
  };

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

  addLLMSubtitle[cellList_List] := Module[
    {cells = DeleteCases[cellList, Cell["[LLM Generated]", "Subtitle", ___]], pos},
    pos = FirstPosition[cells, Cell[_, "Title", ___], Missing[], {1}];
    If[MissingQ[pos],
      Prepend[cells, Cell["[LLM Generated]", "Subtitle"]],
      Insert[cells, Cell["[LLM Generated]", "Subtitle"], pos[[1]] + 1]]
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
  cells = cells /. {
    Cell[c_, "Chapter", o___] :> Cell[c, "Section", o],
    Cell[c_, "Section", o___] :> Cell[c, "Subsection", o],
    Cell[c_, "Subsection", o___] :> Cell[c, "Subsubsection", o]
  };
  cells = cells /. {
    Cell[TextData[{StyleBox["[LLM Generated]", ___]}], _String, o___] :> Cell["[LLM Generated]", "Subtitle", o],
    Cell[TextData[StyleBox["[LLM Generated]", ___]], _String, o___] :> Cell["[LLM Generated]", "Subtitle", o],
    Cell["[LLM Generated]" | "[ LLM Generated ]", _String, o___] :> Cell["[LLM Generated]", "Subtitle", o]
  };
  cells = cells /. Cell[content_, "Program", opts___] :> Cell[content, "CodeText", opts];
  cells = boxifyInputCells[cells];
  cells = markInitCells[cells];
  cells = addLLMSubtitle[cells];
  ExportString[Notebook[cells], "NB"]
]
```

## After the MCP call

1. Write the returned string to the target file via the `Write` tool
2. **Verify** by checking file size or evaluating `Length[First[Import["/path/to/file.nb"]]]` via the official MCP

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

The `.md` source name is undated; the generated `.nb` appends the first-creation date (`_YYYY-MM-DD`, preserved across regenerations — see *Two-layer architecture*).

- Single-topic notebooks: `TopicName.md` / `TopicName_YYYY-MM-DD.nb`
- Paper analysis: `Author_Year.md`
- Chains/multi-topic: descriptive name (`UniversalityGraph.md`)
