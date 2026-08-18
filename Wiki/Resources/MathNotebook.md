# MathNotebook

*[ LLM Generated ]*

Pavel Hajek, *MathNotebook* — `WolframInstitute/MathNotebook`, https://github.com/WolframInstitute/MathNotebook (**private**).
Paclet `WolframInstitute/MathNotebook`, **MIT**, `WolframVersion` 14.3+, `PrimaryContext` `WolframInstitute`MathNotebook``.

Harvested 2026-07-28 from the closed items `MathNotebookIntegration` and `PacletDocumentation` — see [Progress Harvest](../Concepts/ProgressHarvest.md).
Refreshed 2026-07-30 against `5f68f30` (**0.1.20** on `main`), which is also the installed version; clone and install now agree.
Sections marked *0.1.20* below were re-measured then and supersede the 0.1.16/0.1.17 readings.

**Read again 2026-08-18 at `b99cde6` (0.1.24 on `origin/main`).** Only the MaTeX layer moved since 0.1.20; the stylesheet, environment and bibliography readings below still hold. See § *MaTeX* at the end for what changed and what it means for this repo.

## Summary

A Wolfram paclet supplying AMS-style typeset document stylesheets, numbered theorem-family environments, and cross-referencing machinery for notebooks.
It is the styling and referencing half of `research-notebook`; [MarkdownToNotebook](MarkdownToNotebook.md) is the parsing half.

The clone at the project root is a **dev repo**, not the paclet: it follows the triple-nesting convention, so the paclet is at `MathNotebook/MathNotebook/` with `PacletInfo.wl`, `Kernel/` (`Package[]` format), `FrontEnd/`, `Assets/`, `Tests/`, and — since `PacletDocumentation` T4 — `Documentation/` carrying 21 generated symbol pages.
**Seven** stylesheets ship under `FrontEnd/StyleSheets/MathNotebook/`: the shared base `LaTeXBase.nb`, the five journal templates `AMSArticle.nb`, `ArXivArticle.nb`, `RevTeXAPS.nb`, `SpringerJournal.nb`, `ComplexSystems.nb`, and `PlainArticle.nb`.
A palette ships beside them at `FrontEnd/Palettes/MathNotebook.nb`.

The repo's own `CLAUDE.md` is the densest source of front-end knowledge in it and is worth reading before touching the stylesheets.

## PlainArticle — the sheet this project uses

`PlainArticle.nb` is **deliberately not a sixth template**: it exists to declare *fewer* styles.
It is `Default.nb`'s typography with the paper's *structure* added, and it is what `ImportLaTeXDocument` falls back to when the `\documentclass` names no journal with a template.
[research-notebook](../../skills/research-notebook/SKILL.md) sets it as `$MathNotebookStyleSheetName` in `scripts/mathnotebook_post.wl`.

**Bare `Default.nb` is not an alternative.** Under it a reference to a definition renders `2.0` — the section counter increments and the theorem counter never does — and that is invisible to the kernel, to a round trip, and to the resolved counter values.
`PlainArticle` is the minimum sheet that keeps numbering alive.

Read off **0.1.20**, it declares 24 named styles plus the parent cell `StyleData[StyleDefinitions -> "Default.nb"]`:

| group | styles |
|---|---|
| structural | `Notebook`, `Section`, `Subsection`, `Subsubsection`, `Abstract`, `Reference` |
| inheriting `StyleData["Text"]` | the twelve environments, `Proof`, `Date`, `Caption` |
| links | `Hyperlink` (← `Link`), `Citation` (← `Hyperlink`), `URL` (← `Hyperlink`) |

Deferred to `Default.nb` entirely at 0.1.20: exactly six styles — `Title`, `Text`, `Author`, and the three `DisplayFormula` styles — pinned as that list in `Tests/StyleSheets.wlt`.
Every explicit `FontSize` **and `FontFamily`** is dropped, and the `"Printout"` variants with them: `PlainArticle` has none where `AMSArticle` carries 26.

The list moved twice: 0.1.16 declared `Text` and `Link` and *not* `Reference`; 0.1.17 declared `Reference` and dropped those two; `BibliographyDisplay` T1 (`f46e7fe`) then made `Reference` inherit `StyleData["Text"]` — the sheet's own prose face — rather than deferring to `Default.nb`.

**One open defect on this sheet** (`EnvironmentBlocks` T3): `PlainArticle`'s `DisplayFormula` is left-flush where the four journal templates centre theirs, so an equation inside an environment body sits 64 pt left of the block's prose — on the very sheet an imported paper lands on.

Rendered end to end at 0.1.17 (2026-07-29), the sheet numbers correctly: `Definition 1.1` in section 1, then `Claim 2.1` / `Example 2.2` / `Remark 2.3` / `Question 2.4` sharing one per-section counter, a document-global `(1)` flush right, a citation resolving to a live `Definition 1.1`, and a bibliography tag staying `[ollivier09]`.
The look is `Default.nb`'s — including its orange section headings.

## The stylesheet: what AMSArticle declares

32 styles, of which **12 are numbered environments**, all carrying `CounterIncrements -> "Theorem"`:

| class | environments | body |
|---|---|---|
| Plain | `Theorem`, `Lemma`, `Proposition`, `Corollary`, `Conjecture`, `Claim` | **italic**, amsthm-style |
| Definition | `Definition`, `Example`, `Construction` | roman |
| Remark | `Remark`, `Question`, `Observation` | roman, plain-weight italic label |

Prose written for a `Theorem` cell is italicised whether the author expects it or not.

The remaining 20: `Notebook`, `Title`, `Author`, `Date`, `Abstract`, `Section`, `Subsection`, `Subsubsection`, `Text`, `Item`, `ItemNumbered`, `ItemParagraph`, `DisplayFormula`, `DisplayFormulaNumbered`, `DisplayFormulaEquationNumber`, `Proof`, `Hyperlink`, `Citation`, `URL`, `Reference`.

## How numbering works, and the two counter rules

Each environment sets

```wolfram
CellDingbat -> Cell[ TextData[ { env <> " ", CounterBox[ "Section" ], ".", CounterBox[ "Theorem" ], "." } ] ]
```

so **the visible label *is* the dingbat** — produced entirely by front-end `CounterBox`es with no kernel involvement, and renumbering itself when cells move.
The consequence for any post-processing is absolute: a `**Definition.**` marker must be **stripped**, never rewritten as text. The number is not yours to write.

**An environment is a multi-cell block** (*0.1.20*): a body continuing past one cell continues in a cell of the **same style** carrying `CellDingbat -> None` and `CounterIncrements -> {}` (`environmentContinuationCell`).
A generator that drops to a `Text` cell for prose after a display equation breaks the block twice — the margin falls from the body's 130 pt to `Text`'s 66, and a LaTeX export emits bare prose outside the `\begin{definition}`.
Wrapping in `CellGroupData` does not help; the margins are measured identical.

Two rules that look symmetric in the style options and are not:

- **All twelve environments share one counter**, amsthm-style. A Definition followed by a Theorem in section 1 numbers 1.1 then 1.2, not 1.1 and 1.1. This holds under six of the seven sheets; `ComplexSystems` deliberately gives each environment its own counter, which `Section` does not reset.
- **Theorem numbers are per-section `⟨section⟩.⟨n⟩`; equation numbers are document-global `(n)`.** `Section` carries `CounterAssignments -> {{"Subsection", 0}, {"Subsubsection", 0}, {"Theorem", 0}}` and the equation counter is *not* in that list. Verified by render: entering section 3 reset the theorem counter while the following equation continued to `(3)`.

The second is an *absence* in a list, which is exactly the kind of thing that reads as symmetric until it is rendered across three sections.
An author who assumes equations are numbered per-section will write wrong cross-references.

## Embed the stylesheet, never reference it

**A deployed notebook that references the sheet by name carries no style definitions at all.**
Measured by deploying both variants and reading each back with `CloudGet`:

| deployed variant | `StyleData` cells in the file | `StyleDefinitions` head | size |
|---|---:|---|---:|
| `FrontEnd`FileName[{"MathNotebook"}, "AMSArticle.nb"]` | **0** | `FrontEnd`FileName` | 2.9 kB |
| `Get[<absolute path>]` (embedded) | **57** | `Notebook` | 49.8 kB |

A reader without the paclet gets no `Theorem` counter, so every environment renders as unnumbered body text — and the labels vanish entirely, because the label *is* the `CellDingbat` the sheet supplies.
Embedding costs ~47 kB, which is nothing next to one rasterized plot.

The paclet's own `CLAUDE.md` reaches the same conclusion from a weaker premise — silent fallback to `Default.nb` in headless runs.
The stronger reason is unconditional: a referenced sheet is simply *not in the file*, so its resolution is a property of the reader's machine rather than of the document.
Numbering is dynamic (`CounterBox`es evaluated by the reader's front end), so it is correct in a deployed notebook **provided the definitions travel with it** — the two facts are the same fact.

Related warning from the paclet's `CLAUDE.md`, worth repeating because it is expensive: never stage a stylesheet into `$UserBaseDirectory/SystemFiles/FrontEnd/StyleSheets/` to make name resolution work. It wedges every subsequent front-end launch on the machine.

## Numbering can only be verified by rendering the whole notebook

Every obvious kernel-side route fails:

- `CurrentValue[cell, {CounterValue, "Theorem"}]` answers `$Failed` — a counter is not readable as a value.
- A single-cell `Rasterize` reads every `CounterBox` as 0 and every tagged one as `XXX`.
- Style names are no evidence: correct style names with a missing stylesheet look **identical** in the cell expression and blank on the page.

What works is `Export[file, notebookObject]` inside `UsingFrontEnd`, then reading the image.
Any regression test of numbering has to assert on the rendered image, not on style names.

One caveat on that render: the exported raster came out **dark** even though the sheet declares `LightDark -> Light` and `Background -> GrayLevel[1]` on `Notebook` — a headless raster follows the front end's own appearance, not the sheet. A light/dark check on a published artifact cannot be done from the raster alone.
Setting `Background -> White` **and** `LightDark -> "Light"` on the notebook being exported pins it; either alone fails, in opposite directions.

A second requirement when rendering a research notebook: **open every `CellGroupData` first**. A folded group rasterizes as its head cell alone, so the evidence under a claim is simply not in the image and its numbering cannot be read off it.

## Referencing and the bibliography — *0.1.20*

`Referencing.wl` exports `InsertCitation`, `InsertReference`, `SortBibliography`, `CopyCellReference`, `TagSelectedCell`, `LabelReferences`, `InsertEnvironment`, `GoBack`.
A citation to a numbered environment is a `CounterBox[counter, tag]` resolved at the cell tagged `tag`, with the target's style looked up at insert time and an unknown tag falling back to `[tag]`.

**There is now a bibliography engine**, added across `ImportDisplayDefects`, `PaletteAndViewUX` and `BibliographyDisplay` (0.1.17 → 0.1.20).
It parses BibTeX (`bibliographyDatabase` and friends in `Document.wl`, brace-depth field splitting, TeX accents decoded), formats an entry by riffling fields in a fixed order (no bibliography style is emulated), sorts by `"FirstUse"` / `"Key"` / `"Entry"` / `"Uncited"` (`SortBibliography`), audits never-cited entries and dangling citations, and labels every `Reference` cell through `LabelReferences`.

Three things it still does not do, which is why `research-notebook` keeps building its References section itself:

- **It is reachable only from `ImportLaTeXDocument`.** There is no exported "import this `.bib` into this notebook" entry point.
- **Nothing numbers.** A label is always `[key]` — `referenceLabel[tag] = "[" <> tag <> "]"` — and the citation buttons render `[key]` to match, so writing `[1] [2] [3]` by hand breaks the pairing.
- **`InsertReference` creates an empty cell.** Only the LaTeX import route generates entry text.

Since `b3f5dc4`, `LabelReferences` sets options per cell rather than rewriting the notebook, so `CellObject`s and `CellID`s survive a refresh.

The paclet's existing rendering contract, which `scripts/mathnotebook_post.wl` reuses rather than reinventing:

```wolfram
referenceLabel[ tag ]   = "[" <> tag <> "]"
citationButton[ tag ]   = ButtonBox[ label, BaseStyle -> "Citation", ButtonData -> tag ]
referenceDingbat[ tags ]                       (* same label as the cell's CellDingbat *)
```

**The `Reference` gutter was widened twice and is now uniform** — `CellMargins -> {{205, 10}, {3, 3}}` with `ParagraphIndent -> -24` in **all seven** sheets, pinned by `Tests/StyleSheets.wlt`.
It was 90 pt under AMS at 0.1.16, moved to 185 by `ImportDisplayDefects` T1, then to 205 by `BibliographyDisplay` T1 because the widest specimen key measures 190 pt at the plain sheet's Source Sans Pro 15 against 173 at AMS's Palatino 13.
That leaves ~15 pt of clearance at 26 characters, so the short-key rule survives in weaker form: **keep bib keys under about 25 characters**, beyond which the label is still clipped at the window edge.

A `Reference` cell needs **both** `CellTags -> key` and the `[key]` dingbat (`CellDingbat -> Cell[TextData["[key]"]]` plus `ParagraphIndent -> 0`); commit `a658678` fixed shipped samples that carried neither and printed unlabelled into the empty gutter.
Two further shapes the front end will not resolve: a citation in `BoxData` renders in the code face rather than the prose face (it must be inline `TextData`), and a compound `\cite` must be one button per key with literal separators — a single button carrying several keys navigates nowhere.
The suppressed "References" heading needs `CounterIncrements -> {}`, `CellDingbat -> None` **and** `TaggingRules -> <|"MathNotebook" -> <|"Suppressed" -> "True"|>|>`; with only the first it prints as a numbered section.

## Install and publish

Not on the Paclet Repository, and cannot be: the source repo is private.
`PacletFindRemote["WolframInstitute/MathNotebook"]` returns `{}`.

```wolfram
PacletInstall[ "https://www.wolframcloud.com/obj/hajek_pavel/MathNotebook.paclet", ForceVersionInstall -> True ]
(* or, once a copy is installed *)
UpdateMathNotebook[ ]
```

Publishing uses the repo's own `Scripts/PublishPaclet.wls`.
Historically its fixed staging list would have dropped `Documentation/`; that was fixed (guarded by `DirectoryQ`) during `PacletDocumentation` T5, along with the deeper defect in this plugin — see [Paclet Documentation](../Concepts/PacletDocumentation.md#the-fixed-staging-list-was-the-real-defect).

Documentation is deployed publicly at
`https://www.wolframcloud.com/obj/hajek_pavel/MathNotebook/Documentation/index.html`.

## Use in this project

`scripts/mathnotebook_post.wl` is the post-processing half of [research-notebook](../../skills/research-notebook/SKILL.md).
It exports `$MathNotebookEnvironmentStyles` (all 12), `$MathNotebookStyleSheetName`, `ConvertEnvironmentCells`, `MathNotebookStyleSheet[]`, `NumberTaggedFormulas`, `ConvertCitations`, `CitationTargets`, `ReferenceCells`, `BibTeXReferences`, and `MathNotebookDocument[cells]`, which wraps converted cells with the **embedded** sheet.

**`MathNotebookDocument` owns the pass order** — environments → equation numbering → citations — rather than the skill documenting it.
Each pass passed its own test in isolation while the composition was wrong: the citation pass found no target for an equation tag whose cell had not yet become `DisplayFormulaNumbered`, and failed *silently*, leaving the citation as literal text, which reads as an authoring mistake rather than a pipeline one.
An order that fails silently should not be the caller's responsibility.

**Every pass walks into `CellGroupData`, and none of them did until 2026-07-29.**
All four — `ConvertEnvironmentCells`, `NumberTaggedFormulas`, `ConvertCitations` and `CitationTargets` — operated at level `{1}`, so anything inside a fold was skipped **silently**: a `**Example.**` marker stayed a `Text` cell with its marker still spelled out in the prose, a tagged equation never became `DisplayFormulaNumbered`, and a `[tag]` never became a button.
Nothing detected it while the document order put no content inside a group; the restructured `research-notebook`, which folds every claim's evidence under an `Example`, put the whole evidence half of the document there at once.
The fix is one shared walker, `mapCellList[ f, cells ]`, recursing through groups and preserving each group's `Open`/`Closed` state, plus `documentCells` for the target scan.
Verified two levels deep: `Example`, a numbered equation, and a `Remark` nested inside a second group all convert, and both folds stay `Closed`.

Three rules the post-processor encodes:

- **A tagged equation is a numbered equation.** A `DisplayFormula` cell carrying `CellTags` is promoted to `DisplayFormulaNumbered`. An equation gets a number exactly when something can cite it, which needs no new Markdown syntax — `CellTags` is also what `CounterBox[counter, tag]` resolves against.
- **The tag list guards `ConvertCitations` against false positives.** `[tag]` is ordinary prose and collides with Markdown link syntax, so only keys present in the bibliography are converted. Verified: real citations converted, an existing Markdown hyperlink untouched, a bare `[unknown]` left as plain text.

Citations are style-aware, reproducing the paclet's own `$referenceLabelSpec`: a target listed in the spec renders as `CounterBox`es — `(1)` for an equation, `Definition 2.3` for an environment, `Section 4` for a section — while a `Reference` target keeps the bare `[tag]`.

**`Import[file, "BibTeX"]` does not exist** — `"BibTeX"` is not in `$ImportFormats` — so `BibTeXReferences` is a hand-written parser: entries split on `@type{…\n}`, key taken as the text before the first comma, fields matched as `key = {value}`, `key = "value"`, or a bare numeric `key = 2011`. The bare-numeric rule exists because the first version silently dropped the year of a Crossref entry written `year = 2011,` with no braces.

A WL trap found writing that parser, and recorded in the paclet's `CLAUDE.md` for its own `Document.wl`: the alternation

```wolfram
( "{" ~~ value : Shortest[ ___ ] ~~ "}" | "\"" ~~ value : Shortest[ ___ ] ~~ "\"" )
```

**silently fails.** WL ignores restrictions on a pattern variable that is not its first occurrence, so every field parsed as empty while the keys parsed fine — the association looked structurally correct and was blank. One rule per delimiter form is the fix.

## Recover

Clone: git@github.com:WolframInstitute/MathNotebook.git
Target: MathNotebook
Commit: 5f68f30

Private — clone over SSH with an account that has access (an https clone fails for credentials).
The clone sits at the project root, gitignored, alongside `MarkdownToNotebook/` and `PureMath/`.

```bash
git clone git@github.com:WolframInstitute/MathNotebook.git
```

## See also

## MaTeX — *0.1.24*, and a decision that binds this repo

The paclet renders typed LaTeX through MaTeX in inline and display form — `ConvertToMaTeX`, `ConvertFromMaTeX`, `ConvertLaTeXToMaTeX`, `ConvertMaTeXToLaTeX`, plus `InstallMaTeX` and `OpenMaTeXPreferences`.
`gather`, `multline`, `alignat` and `flalign` are covered, starred and not.
Since `EditableMaTeX` T1 the picture rides in the front end's own `TeXAssistantTemplate` — the box Ctrl+4 makes — which carries the TeX in an `"input"` slot, so the mathematics is editable in place rather than only recoverable from a palette button.
The box is display-transparent (measured {183, 40} px and 1083 ink either way) and survives a save with all four slots intact; only `"state" -> "Boxes"` may be written from the kernel.

**Every entry point takes a `NotebookObject` or a list of `CellObject`s, so the whole layer needs a front end** and none of it is reachable from the plugin's headless build.

That is a decision and not just a limit.
**MaTeX is a choice and not a default** (Pavel, 2026-08-01): native typeset boxes are what a notebook holds and what a machine without LaTeX can open, and MaTeX is what an author converts a selection *to*, from the palette.
The item's T3 names the plugin's `research-notebook` skill and says the generator needs no change.

Two measured facts the generator has to live with:

- **Inline mathematics sits loose, and no box surgery fixes it.** The front end reads a letter followed by a parenthesised group as a product and sets a thin space; a script glyph adds side bearing. `𝒦(G)` at 216 dpi measures 107 px as a nested `RowBox`, **107 as a bare string**, 107 under `AutoSpacing -> False`, and 112 in the shape the MarkdownToNotebook parser writes. The remedy is the author's palette conversion, not a different box.
- **The expression-path traps do not reach the Markdown pipeline.** `texToBoxes["K_k(G)"]` answers `BesselK` and `["T_k(G)"]` answers `ChebyshevT` — plausible-looking and wrong — but that is the paclet's LaTeX-import path. Measured 2026-08-18: the rich parser leaves both as presentation boxes with no `TemplateBox`, and `G = (V, E)` keeps its `=`.

### The canonical clone, and the divergence that made it necessary

**The source of truth is the author's Dropbox working copy** — `~/Library/CloudStorage/Dropbox-WolframInstitute/Pavel Hajek/WolframInstituteShared/Pavel Hajek/MathNotebook` — where edits are made and from which pushes go. The in-project `MathNotebook/` clone is a read-only reference for audits, gitignored, pulled before it is read. Recorded in the plugin's `CLAUDE.md` § *MathNotebook — the canonical clone*.

That direction was written down because the two silently diverged (2026-08-18): the Dropbox copy sat one commit ahead on `EditableMaTeX` T1 and one behind, the in-project copy at `origin/main` with 0.1.24's inline/multiline MaTeX, and **neither held the other's HEAD**. Both lines were MaTeX work on the same four files, so a stale read of either would have described a paclet that existed nowhere.

**The merge, and what "best of both" meant.** The two sides were complementary rather than competing: 0.1.24 added *coverage* (inline islands, the generalized `$displayDelimiters` with its math-mode inner environment, `ensureMaTeX` adding mathtools for `multlined`), while T1 changed *representation* (the picture wrapped in the front end's `TeXAssistantTemplate`, the box's `"input"` slot outranking the `"SourceTeX"` rule, an edit invalidating `"LaTeXSource"`). Only `MaTeX.wl` conflicted, both hunks pure add/add.

One integration no textual merge would have made: **`inlineMaTeXCell` had to wrap its island in `maTeXBox` too**, since 0.1.24 wrote that builder before the box existed — otherwise display formulas were editable and inline islands silently were not. It composes cleanly the other way as well: `maTeXBoxTeX` was written deliberately narrow because "a `Text` cell may hold several inline assistant boxes", which was hypothetical when T1 was written and is the ordinary case once islands are wrapped — each island is its own `Cell`, so `storedSourceTeX` reads it per island and an edited island exports its edit.

The merged tree stays at **0.1.24**: `EditableMaTeX` is still Active with T2–T4 open, so the version bump is a release decision and not the merge's to make. Installed 0.1.24 and this working tree therefore differ by T1 — the clone/install disagreement this article has flagged before.

## Related

- [MarkdownToNotebook](MarkdownToNotebook.md) — the parser half of the `research-notebook` pipeline
- [Paclet Documentation](../Concepts/PacletDocumentation.md) — the doc tree generated into this paclet, and the build/publish staging fix it forced
- [Progress Harvest](../Concepts/ProgressHarvest.md) — where this article came from
- [Folded cell groups](../Concepts/FoldedCellGroups.md) — the `{2}` group state a generated notebook uses to hide code under these stylesheets
- `Work/Done/2026-07-27-MathNotebookIntegration.md` — the six sessions that established all of the above
