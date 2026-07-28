# MathNotebook

*[ LLM Generated ]*

Pavel Hajek, *MathNotebook* — `WolframInstitute/MathNotebook`, https://github.com/WolframInstitute/MathNotebook (**private**).
Paclet `WolframInstitute/MathNotebook`, version 0.1.11, **MIT**, `WolframVersion` 14.3+, `PrimaryContext` `WolframInstitute`MathNotebook``.

Harvested 2026-07-28 from the closed items `MathNotebookIntegration` and `PacletDocumentation` — see [Progress Harvest](../Concepts/ProgressHarvest.md).

## Summary

A Wolfram paclet supplying AMS-style typeset document stylesheets, numbered theorem-family environments, and cross-referencing machinery for notebooks.
It is the styling and referencing half of `research-notebook`; [MarkdownToNotebook](MarkdownToNotebook.md) is the parsing half.

The clone at the project root is a **dev repo**, not the paclet: it follows the triple-nesting convention, so the paclet is at `MathNotebook/MathNotebook/` with `PacletInfo.wl`, `Kernel/` (`Package[]` format), `FrontEnd/`, `Assets/`, `Tests/`, and — since `PacletDocumentation` T4 — `Documentation/` carrying 21 generated symbol pages.
Five stylesheets ship under `FrontEnd/StyleSheets/MathNotebook/`: `AMSArticle.nb`, `ArXivArticle.nb`, `LaTeXBase.nb`, `RevTeXAPS.nb`, `SpringerJournal.nb`.

The repo's own `CLAUDE.md` is the densest source of front-end knowledge in it and is worth reading before touching the stylesheets.

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

Two rules that look symmetric in the style options and are not:

- **All twelve environments share one counter**, amsthm-style. A Definition followed by a Theorem in section 1 numbers 1.1 then 1.2, not 1.1 and 1.1.
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

## Referencing: cross-references, no bibliography

`Referencing.wl` exports `InsertCitation`, `CopyCellReference`, `TagSelectedCell`, `LabelReferences`, `InsertEnvironment`, `GoBack`.
A citation to a numbered environment is a `CounterBox[counter, tag]` resolved at the cell tagged `tag`, with the target's style looked up at insert time and an unknown tag falling back to `[tag]`.

`Citation` is a character style inheriting from `Hyperlink`; `Reference` is a `Text`-derived paragraph style.
**Neither generates anything** — nothing collects, sorts, or numbers entries. There is no bibliography engine, so a References section has to be authored and kept in sync by the caller.

The paclet's existing rendering contract, which `scripts/mathnotebook_post.wl` reuses rather than reinventing:

```wolfram
referenceLabel[ tag ]   = "[" <> tag <> "]"
citationButton[ tag ]   = ButtonBox[ label, BaseStyle -> "Citation", ButtonData -> tag ]
referenceDingbat[ tags ]                       (* same label as the cell's CellDingbat *)
```

A long citation key overflows the `Reference` style's left margin — `[ollivier2009]` ran to the page edge while `[lin2011]` sat comfortably. Keep bib keys short.

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

Two rules the post-processor encodes:

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
Commit: e088d72

Private — clone over SSH with an account that has access (an https clone fails for credentials).
The clone sits at the project root, gitignored, alongside `MarkdownToNotebook/` and `PureMath/`.

```bash
git clone git@github.com:WolframInstitute/MathNotebook.git
```

## See also

- [MarkdownToNotebook](MarkdownToNotebook.md) — the parser half of the `research-notebook` pipeline
- [Paclet Documentation](../Concepts/PacletDocumentation.md) — the doc tree generated into this paclet, and the build/publish staging fix it forced
- [Progress Harvest](../Concepts/ProgressHarvest.md) — where this article came from
- `Work/Done/2026-07-27-MathNotebookIntegration.md` — the six sessions that established all of the above
