---
name: modify-notebook
description: >
  Modify an existing Wolfram Notebook (.nb) by exporting it to Markdown, making
  changes, and re-importing via the create-notebook pipeline. Use this skill
  whenever the user asks to edit, update, change, add to, append to, or fix an
  existing .nb file. Never read a .nb file directly — always go through Markdown.
---

## Hard Rule

**NEVER** read a `.nb` file with the `Read` tool or load its raw content into the
context window. Both Wolfram MCP servers run local kernels with filesystem access —
always use `ExportString[Import[path], "Markdown"]` to get editable Markdown.

## Pipeline

### Step 1 — Export .nb → Markdown string

Run in the **official MCP** (`mcp__Wolfram__WolframLanguageEvaluator`) if available,
otherwise the **unofficial MCP** (`mcp__wolfram__evaluate`):

```wolfram
ExportString[Import["/absolute/path/to/file.nb"], "Markdown"]
```

This returns the notebook content as a Markdown string. The raw `.nb` format never
enters the context window.

Alternatively, the unofficial MCP exposes `mcp__wolfram__export_notebook` which does
the same thing — use it if the Wolfram code approach fails.

### Step 2 — Make changes in Markdown

Work with the Markdown string. Common operations:

- **Add a section**: insert a `## Section Name` heading and content
- **Edit text**: find and replace the relevant paragraph
- **Add a code block**: insert `` ```wolfram `` ... `` ``` `` at the right position
- **Remove content**: delete the relevant lines

Keep all the conventions from the `create-notebook` skill (backtick escaping, LaTeX
math, cell mapping).

### Step 3 — Re-import via the create-notebook pipeline

Run the full `ImportString` → post-process → `ExportString` pipeline exactly as
described in the `create-notebook` skill:

```wolfram
Module[{md, nb, cells, markInitCells, tick, fence},
  (* ... same pipeline as create-notebook ... *)
  md = "... modified markdown ...";
  nb = ImportString[md, {"Markdown", "Notebook"}];
  cells = First[nb];
  cells = cells /. Cell[content_, "Program", opts___] :> Cell[content, "CodeText", opts];
  cells = markInitCells[cells];
  ExportString[Notebook[cells], "NB"]
]
```

Use the **official MCP** first (fallback: unofficial). Same priority as create-notebook.

### Step 4 — Write back

```
Write tool → original .nb path → content from ExportString result
```

This overwrites the file. If the user might want to keep the original, note that and
ask before overwriting — or write to a new numbered file (e.g. `Topic2.nb`).

### Step 5 — Verify

Call `mcp__wolfram__list_cells` on the written file and confirm the cell count matches
the expected structure. In VM/Cowork mode this may fail — check file size instead.

## When to rebuild vs. when to patch

- **Short notebook** (< ~30 cells): rebuild entirely from Markdown. Simpler and avoids
  merging issues.
- **Long notebook**: export → patch the relevant section in the Markdown string →
  re-import. Keep surrounding sections intact.

## Appending to a notebook

The simplest way to append new content without touching existing sections:

1. Export to Markdown (Step 1)
2. Append the new Markdown sections at the end of the string
3. Re-import the full combined Markdown (Step 3)
4. Write back (Step 4)

Do **not** try to manipulate the raw `.nb` cell list by hand — always go through
the Markdown round-trip.
