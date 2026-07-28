# research-notebook: MathNotebook install and environment mechanics

The paclet half of the two-half pipeline.
The authoring conventions (marker table, counters, Lean-translatability) are in [SKILL.md](SKILL.md); this sibling carries the install, the stylesheet-embedding rationale, and the verified mechanics.

## Install

The paclet is **not** on the Paclet Repository — its source repo is private, so `PacletInstall[ "WolframInstitute/MathNotebook" ]` resolves to nothing.
Install from the cloud build:

```wolfram
PacletInstall[ "https://www.wolframcloud.com/obj/hajek_pavel/MathNotebook.paclet",
  ForceVersionInstall -> True ]
Needs[ "WolframInstitute`MathNotebook`" ]
```

Once a copy is installed, `UpdateMathNotebook[ ]` upgrades it in place.
The paclet is MIT, needs Wolfram 14.3+, and its `PrimaryContext` is `WolframInstitute`MathNotebook``.

## Embed the stylesheet — never reference it by name

A notebook deployed with `StyleDefinitions -> FrontEnd`FileName[ { "MathNotebook" }, "AMSArticle.nb" ]` travels with **zero** style definitions: the option is only a path into a paclet layer on the author's disk, so a cloud reader falls back to `Default.nb`, where the environments lose both their numbers and their labels.
Embed instead — the cost is about 47 kB:

```wolfram
Get[ "${CLAUDE_PLUGIN_ROOT}/scripts/mathnotebook_post.wl" ]
MathNotebookDocument[ cells, bibTags ]
```

`MathNotebookDocument` runs the whole post-processing pipeline in the one order that works — environments, then equation numbering, then citations — and wraps the result with the embedded sheet.
Citations must come last, because a reference to an equation has to see the cell as `DisplayFormulaNumbered`.

## Marker mechanics

`ConvertEnvironmentCells` strips the bold marker and applies the style; a bold marker naming no environment is left as a `Text` cell.
Both spellings are handled — a parsed bold run and a literal `**Definition.**` string.

**The bold markers survive rich-mode conversion unchanged**, and that is what makes the two-half pipeline work: MarkdownToNotebook emits a bold run as `StyleBox[ "Definition.", FontWeight -> "Bold" ]` as the first element of the cell's `TextData`, which is exactly the shape `markerSplit` matches.
Verified end to end — `**Definition.**` / `**Remark.**` / `**Conjecture.**` came out as `Definition 1.1` / `Remark 1.2` / `Conjecture 2.1` with the correct label and body styling.

Numbering comes from the stylesheet as a `CellDingbat` of `CounterBox`es, so it is the front end's to compute and **never yours to write**: do not put a number in the source.

## Displayed math

In rich mode `$$…$$` becomes the `DisplayFormula` cell (see SKILL.md § *TeX in the sources*); on the built-in fallback a `wolfram` fence starting with `FormBox[…]` does.
MathNotebook defines no separate equation environment.
Give the cell `CellTags` and `NumberTaggedFormulas` promotes it to `DisplayFormulaNumbered`, which draws `(n)` flush right — an equation is numbered exactly when something can cite it.

## Tables are the one cosmetic loss

The converter's `2ColumnTableMod` / `TableText` / `ModInfo` styles are defined in neither `Default.nb` nor `AMSArticle.nb`, so a Markdown pipe table renders as plain monospace text with no rules and no header emphasis.
Prefer a `Grid` in a `wolfram` fence when a table carries weight; keep pipe tables for throwaway comparisons.
