# research-notebook: MathNotebook install and environment mechanics

The paclet half of the two-half pipeline.
The authoring conventions (marker table, counters, statement precision) are in [SKILL.md](SKILL.md); this sibling carries the install, the stylesheet-embedding rationale, and the verified mechanics.

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

## Which sheet: `PlainArticle`

Seven sheets ship under `FrontEnd/StyleSheets/MathNotebook/`: `LaTeXBase.nb` (the shared base), the five journal templates `AMSArticle`, `ArXivArticle`, `RevTeXAPS`, `SpringerJournal`, `ComplexSystems`, and `PlainArticle`.

**This skill uses `PlainArticle.nb`** — set as `$MathNotebookStyleSheetName` in `scripts/mathnotebook_post.wl`.
It is deliberately *not* a sixth template: it exists to declare **fewer** styles, and it is `Default.nb`'s typography with the paper's structure added.
25 style names against `AMSArticle`'s 34, every explicit `FontSize` dropped along with the `"Printout"` variants, and `Title`, `Text`, `Author`, `Reference` and the three `DisplayFormula` styles left to `Default.nb`.

The rule that decides its contents, from the paclet's own `CLAUDE.md`: a style `Default.nb` has no notion of comes across whole (the twelve environments, `Proof`, `Caption`, `Date`, `Hyperlink`/`Citation`/`URL`); a style `Default.nb` *does* declare contributes only the number or the word the document prints (the three sectioning levels, `Abstract`); six get nothing at all.

**Bare `Default.nb` is not an option.** Under it a reference to a definition renders `2.0` — the section counter increments and the theorem counter never does — and that is invisible to the kernel, to a round trip, and even to the resolved counter values.
`PlainArticle` is the minimum sheet that keeps numbering alive.

Counted in the shipped `Default.nb` (`$InstallationDirectory/SystemFiles/FrontEnd/StyleSheets/Default.nb`): it declares `Author`, `Reference`, `Title`, `Subtitle`, `Abstract`, `DisplayFormulaNumbered` and `ItemNumbered`, so nothing the pipeline uses is left undeclared. It does not declare `Caption`, which is why `PlainArticle` carries that one.
Note the caveat from the paclet's `CLAUDE.md`: a scan of `Default.nb` cannot answer "does this style exist" in the negative — `Hyperlink` and `Link` resolve without being in the file — so this count is evidence a style *is* declared, not that an absent one is unavailable.

Two consequences of the deferral worth knowing while authoring:

- `Subtitle` resolves (from `Default.nb`) under `PlainArticle` but **not** under `AMSArticle`, which declares no such style. Use `Author` for the `[ LLM Generated ]` line — the one style that survives a swap to any sheet.
- `Reference` comes from `Default.nb`, whose left margin differs from `AMSArticle`'s. Keep bib keys short and the label fits under both.

## Embed the stylesheet — never reference it by name

A notebook deployed with `StyleDefinitions -> FrontEnd`FileName[ { "MathNotebook" }, "PlainArticle.nb" ]` travels with **zero** style definitions: the option is only a path into a paclet layer on the author's disk, so a cloud reader falls back to `Default.nb`, where the environments lose both their numbers and their labels.
Embed instead — the cost is about 47 kB:

```wolfram
Get[ "${CLAUDE_PLUGIN_ROOT}/scripts/mathnotebook_post.wl" ]
MathNotebookDocument[ cells, bibTags ]
```

`MathNotebookDocument` runs the whole post-processing pipeline in the one order that works — environments, then equation numbering, then citations — and wraps the result with the embedded sheet.
Citations must come last, because a reference to an equation has to see the cell as `DisplayFormulaNumbered`.

## Marker mechanics

`ConvertEnvironmentCells` strips the bold marker and applies the style; a bold marker naming no environment is left as a `Text` cell.
The markers it recognises are `$MathNotebookMarkerStyles` — the twelve numbered environments plus `Proof`, which is a `PlainArticle` style that takes no number and cannot be cited, so it is deliberately absent from `$MathNotebookEnvironmentStyles` and from the reference-label spec.
Both spellings are handled — a parsed bold run and a literal `**Definition.**` string.

**The bold markers survive rich-mode conversion unchanged**, and that is what makes the two-half pipeline work: MarkdownToNotebook emits a bold run as `StyleBox[ "Definition.", FontWeight -> "Bold" ]` as the first element of the cell's `TextData`, which is exactly the shape `markerSplit` matches.
Verified end to end — `**Definition.**` / `**Remark.**` / `**Conjecture.**` came out as `Definition 1.1` / `Remark 1.2` / `Conjecture 2.1` with the correct label and body styling.

Numbering comes from the stylesheet as a `CellDingbat` of `CounterBox`es, so it is the front end's to compute and **never yours to write**: do not put a number in the source.

## Displayed math

In rich mode `$$…$$` becomes the `DisplayFormula` cell (see SKILL.md § *TeX in the sources*); on the built-in fallback a `wolfram` fence starting with `FormBox[…]` does.
MathNotebook defines no separate equation environment.
Give the cell `CellTags` and `NumberTaggedFormulas` promotes it to `DisplayFormulaNumbered`, which draws `(n)` flush right — an equation is numbered exactly when something can cite it.

## Tables are the one cosmetic loss

The converter's `2ColumnTableMod` / `TableText` / `ModInfo` styles are defined in neither `Default.nb` nor any MathNotebook sheet, so a Markdown pipe table renders as plain monospace text with no rules and no header emphasis.
Prefer a `Grid` in a `wolfram` fence when a table carries weight; keep pipe tables for throwaway comparisons.
