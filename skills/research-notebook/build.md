# research-notebook: the build

Everything mechanical: which parser runs, what you may write in the source, the conversion call, the stylesheet, the references.
The writing rules are in [style.md](style.md); the authoring conventions in [SKILL.md](SKILL.md).

## Pipeline

The source of truth is `NotebooksLLM/<Topic>.md`.
Conversion is a **two-half pipeline**, both halves load-bearing: `WolframInstitute/MarkdownToNotebook` parses the Markdown, then `scripts/mathnotebook_post.wl` applies the environments, the numbering and the citations.
The generated `.nb` sits beside the source, gitignored.

The parser half is the **rich engine** documented in [new-notebook](../new-notebook/SKILL.md) *Conversion engine — built-in vs rich*: the pinned local clone, `Template: Default`, `"Evaluate" -> False`.
A research source always carries frontmatter and LaTeX math, so rich mode is always selected; the built-in importer is the fallback when the clone is absent, and it changes what you may write (§ *TeX in the sources*).
The backtick-escaping and init-cell-marking rules from `new-notebook` apply; `boxifyInputCells` and the heading shift do **not** — rich mode drops both.

**Never write `::: theorem` or `::: proof` divs.**
The converter's fenced-div environments exist only under `Template: Chapter`; under `Default` they are **silently dropped entirely** — no cells, no message.
Use the bold markers: `**Definition.**`, `**Theorem.**`, `**Proof.**`, `**Remark.**`, and `ConvertEnvironmentCells` strips the marker and applies the style.

A marker must match a style name exactly and end with a period.
`**Definition (Hodge).**` names no style and stays a `Text` cell — there are no named environments on this path.

## One cell per statement

**A statement is one cell.**
An environment body that runs past one cell breaks the block: the margin jumps from 130 pt to 66, and a LaTeX export emits bare prose outside the `\begin{definition}`.
The front end's fix is a continuation cell in the same style carrying `CellDingbat -> None` and `CounterIncrements -> { }` — and **Markdown cannot express that**, so no pass produces it.

So the rule is a writing rule, and it is the one [style.md](style.md) already asks for: one statement, one paragraph, one cell.
A definition needing two paragraphs is two definitions, or a definition and a `Remark`.

## TeX in the sources — engine-dependent

**Which rule applies depends on which parser ran.** Settle the engine first.

### Rich mode (the normal path)

`$…$` and `$$…$$` are the preferred form: the TeX parser produces real typeset boxes, `$…$` becomes a nested `InlineFormula`, `$$…$$` a `DisplayFormula`, and `=` survives.

Three losses, measured at the pinned SHA:

- **`\to` and `\mapsto` are silently dropped** — they become an empty string, so `$f : V(G) \to \mathbb{R}^3$` typesets with nothing between `V(G)` and `ℝ³`. Write `\rightarrow` / `\longrightarrow` / `\hookrightarrow`, or paste the Unicode (`$a ↦ b$` works). `\Rightarrow`, `\circ`, `\times`, `\subset`, `\in`, `\leq`, `\neq` are fine.
- **`\tag{…}` is not understood** — it renders literally. Numbering comes from `CellTags` (SKILL.md § *Referencing*).
- **A `wolfram` fence starting with `FormBox[…]` stays an `Input` cell** showing the literal source. That convention is built-in-only.

Measured at MathNotebook 0.1.24 (`origin/main` = `b99cde6`).

### Built-in fallback (no clone present)

The Markdown importer **silently drops `=` and `\to`** inside `$…$` (`$X + Y = Y + X$` imports as "X + Y Y + X").
Relations like ≤ ≥ ∼ ⊂ ∈ survive, which makes the failure easy to miss.

- In Text cells write **plain Unicode**: `X + Y = Y + X`, `d(u, v) ≤ k`, `f : V(G) → ℝ³`, `D₂∘D₁`, `ℤ₈ × ℤ₈`.
- For display math use a `wolfram` fence whose content starts with `FormBox[…]`.
- Never use `$…$` or `$$…$$` on this path.

### The expression-path traps do not reach this pipeline

The rich parser produces **presentation** boxes, not interpreted expressions.
Measured: `$K_k(G)$` and `$T_k(G)$` come out as `SubscriptBox[ StyleBox[ "K", "TI" ], … ]` with styled parens — no `TemplateBox`, and `G = (V, E)` keeps its `=` as a plain string.

That matters because the paclet's own LaTeX import goes through `texToBoxes`, which turns `K_k(G)` into `BesselK` and `T_k(G)` into `ChebyshevT` — the Bessel function and the Chebyshev polynomial, for a paper whose $K_k(G)$ is a set of cliques.
It **renders plausibly and means something else**, so no display test and no round trip catches it.
Read the paclet's `CLAUDE.md` warnings about that path as *its* path: on the Markdown pipeline the symbols stay presentation boxes and the trap cannot fire.

### MaTeX is an author action, not a build step — and that is a decision

MathNotebook renders typed LaTeX through MaTeX in both inline and display form (`ConvertToMaTeX`, `ConvertLaTeXToMaTeX`, and the reverse pair), covering `gather`, `multline`, `alignat` and `flalign`, and since `EditableMaTeX` T1 the picture rides in the front end's own `TeXAssistantTemplate` so the mathematics stays editable.
Every entry point takes a `NotebookObject` or a list of `CellObject`s, or falls back to the input notebook — **so all of it needs a front end and none of it runs on the headless build path.**

That is not merely a limitation to work around.
**MaTeX is a choice and not a default** (Pavel, 2026-08-01, MathNotebook `EditableMaTeX`): native typeset boxes are what a notebook holds and what a machine with no LaTeX installed can open, and MaTeX is what an author converts a *selection* to, from the palette.
The paclet's T3 says so of this skill by name — the generator needs no change, and it should not acquire one.
Offer the palette conversion as a step the author may take; never put it in the build.

### Inline mathematics sits loose, and no box surgery fixes it

Generated inline mathematics reads more spaced out than the same formula in LaTeX.
The cause is measured and it is not the box structure: the front end reads a letter followed by a parenthesised group as a **product** and sets a thin space, and a script glyph adds side bearing on top.
At 216 dpi in an `InlineFormula`, `𝒦(G)` measures 107 px as a nested `RowBox`, **107 as a bare string**, 107 under `AutoSpacing -> False`, and 112 in the shape this parser writes (`SpanMaxSize -> 1` parens, `"TI"` styling) — the loosest of them.

A string measuring the same as a `RowBox` is the whole finding: there is no box to fix.
So do not try, and do not flatten or restyle the parser's output chasing it.
The author's remedy is a palette MaTeX conversion on the selection they care about, which draws it tight; the cost is a document that needs LaTeX to render that selection.

## Frontmatter and the head

```markdown
---
notebook: Curvature
title: Ollivier curvature on graphs
model: Claude Opus 5 (claude-opus-5[1m])
date: 2026-08-18
operator: Pavel Hájek
freedom: Open exploration
prompt: asked whether the interior form sees anything about the boundary on trees, with no method or target statement named.
---
```

Rich mode consumes the frontmatter as metadata, so there is nothing to strip; the built-in importer does not, and leaves it as a literal Text cell above the Title.
Either way the keys are metadata — the `Default` template emits no `Author` cell, so `ResearchHeadCells` builds the whole head from them.

**The author is the model and nothing else**; the operator, the freedom level and the prompt summary ride in a `Date` cell under the date (style.md § *Authorship and the session footnote*).
`freedom` is one of `Directed`, `Guided`, `Open exploration` and prints **bold** — it is the first thing a reader of a machine-written paper needs.
`prompt` is one sentence summarising the instructions actually given, including what was left unspecified.
A missing `prompt` degrades to the label alone; a missing `freedom` degrades to the operator alone.

`ResearchHeadCells[ meta ]` emits, in order: `[ LLM Generated ]` (`Author`), `Title`, the model (`Author`), the date (`Date`), the footnote (`Date`).
A missing key drops its cell rather than printing an empty one.

**The source carries no `#` heading.**
The head is built from the frontmatter, so a Markdown H1 — the natural thing to write in a `.md` — ships a second `Title` cell under the first.
Sections start at `##`.

## The conversion call

Call the **pinned local clone**, never the deployed resource function: the deployed copy is unversioned (`ResourceObject[ url ][ "Version" ]` is `None`), so drift is undetectable.
Do not vendor the repo (~13 MB) and **never clone it silently**; if it is absent, take the built-in fallback and say so.
The pin and the recovery command are in `Wiki/Resources/MarkdownToNotebook.md`.

```wolfram
Module[ { nb, cells },

  Get[ "MarkdownToNotebook/MarkdownToNotebook.wl" ];              (* pinned clone, project root *)
  Get[ "${CLAUDE_PLUGIN_ROOT}/scripts/mathnotebook_post.wl" ];

  nb    = MarkdownToNotebook[ "NotebooksLLM/<Topic>.md", "Evaluate" -> False ];
  cells = First[ nb ];

  (* the converter stamps In[n]:= even under "Evaluate" -> False, and a 19-digit CellID on every cell *)
  cells = cells /. Cell[ c_, s_String, o___ ] :>
    Cell[ c, s, Sequence @@ DeleteCases[ { o }, ( CellLabel | CellID ) -> _ ] ];

  cells = Join[ ResearchHeadCells[ meta ], ReadCellTags[ cells ] ];
  cells = FoldExampleGroups[ cells ];                             (* after outputs are embedded *)

  MathNotebookDocument[ AssignCellIDs[ cells ], bibTags, CreateCellID -> True ]
]
```

All four generator passes live in `scripts/mathnotebook_post.wl` beside the passes they are ordered against.
The order is a real constraint:

- **`ReadCellTags` before `FoldExampleGroups`.** It walks the flat list, so a cell already inside a group is invisible to it. It strips every `{#Tag}` and attaches it as `CellTags`: a trailing tag to its own cell, a cell that is *only* a tag to the cell above (that is how a display equation is tagged).
- **`FoldExampleGroups` after the outputs are embedded** ([output-embedding.md](output-embedding.md)). It accepts either a bare `Input` followed by an `Output` or an already-grouped pair, and sets the group state to `{2}`. A **second** `Output` lands outside the group — the visible symptom of a violated one-Output-per-Input rule.
- **`AssignCellIDs` after the ids are stripped**, and it recurses into groups. `CreateCellID -> True` instructs the front end and does not stamp cells built in the kernel, while the drift fingerprint keys on `CellID`. Whether it runs on the cell list or on the notebook `MathNotebookDocument` returns is immaterial — measured 2026-08-20, the two orders give an identical notebook — and both are callable. `AppendProofQED` does not disturb this: it rewrites a proof cell's content and adds no cell.
- **`MathNotebookDocument` outermost.** It runs environments → proof QED → equation numbering → citations, in the one order that works (`AppendProofQED` matches the `"Proof"` style, so it has to follow `ConvertEnvironmentCells`, which is what applies it; and a citation to an equation must see the cell as `DisplayFormulaNumbered`), and owns `StyleDefinitions`. Pass notebook options through it rather than rebuilding the `Notebook`; with prompt tracking on, that includes `TaggingRules -> { "Provenance" -> prov }`, and the fingerprint stamp later merges its `"ResearchNotebook"` key alongside. `ReplacePart` is not needed here — unlike `new-notebook` — precisely because it rebuilds the notebook with the options given.

`CellTags` on a marker cell survive `ConvertEnvironmentCells`, which carries `opts___` through, so tagging before `MathNotebookDocument` is correct and tagging after would be too late for `ConvertCitations`.

**Why the converter's `CellID`s are stripped rather than kept.**
`MarkdownToNotebook` stamps every cell with a 19-digit `CellID`, and `AssignCellIDs` skips a cell that already has one — so with them kept, nothing is renumbered.
Then `Export[ …, "NB" ]` drops a 19-digit id and keeps a small one (measured 2026-08-20: `CellID -> 7` survives the round trip, `CellID -> 1234567890123456789` is gone from the file body), and the fingerprint keys on `CellID`.
The first build under this pipeline therefore shipped 8 fingerprinted cells out of 71 — only the head and output cells the generator had stamped itself — with no error anywhere.
Stripping restores the generator's small sequential ids, which survive, and gives full coverage.

Check the round trip once per source: if any `{#Tag}` survives into the `.nb` as visible text, the converter mangled it — fall back to an ordered list of tags applied to the `DisplayFormula` and environment cells in document order, and say so.

`ensureParser[ ]` installs `Wolfram/Parser` on first call, so a fresh machine does network I/O and, on failure, degrades silently to `ImportString[ …, "TeX" ]` with worse math fidelity.
Probe `PacletFind[ "Wolfram/Parser" ]` and surface the degradation.

Then write the notebook, re-import it, and stamp the fingerprint — see [fingerprint.md](fingerprint.md) for why the fingerprint must come from the round-tripped cells.

## The stylesheet

**Embed `PlainArticle.nb`.**
It is `Default.nb`'s typography with the paper's structure added: 26 style cells against `AMSArticle`'s 35, every explicit `FontSize` and `FontFamily` dropped, and six styles left to `Default.nb` — `Title`, `Text`, `Author` and the three `DisplayFormula` styles.
The result reads as a stock Wolfram notebook: no colour change, no font change, numbering and labels intact.
Install and mechanics: [mathnotebook.md](mathnotebook.md).

**The QED square is a character, not cell furniture.**
Every MathNotebook sheet used to carry it as the `Proof` style's right-hand `CellFrameLabels`, and the front end centres a frame label vertically against the whole cell — so on a five-line proof the □ sat beside line three, and only a one-line proof looked right (found on the T4 read of `EquidistanceOddGirth`, 2026-08-20).
The sheets now declare a `QED` character style, and `AppendProofQED` writes `StyleBox[ "\[EmptySquare]", "QED" ]` at the end of each `Proof` cell's last paragraph — where a reader looks for it.
That is the paclet's own convention: `Resources/ComplexSystems.nb` declares the same style and the journal's author templates use it exactly this way, as do Wolfram's `Article/JournalArticle.nb` and `PublicationDefault.nb`.
The pass is idempotent — a cell whose content already ends in the square is left alone — so a rebuild does not double it.

**A proof split across cells gets its □ at the end of the first cell.**
`AppendProofQED` matches the `"Proof"` style, and a proof whose middle holds a display equation converts to a `Proof` cell, a `DisplayFormula` and a trailing `Text` cell — the square then closes the first paragraph instead of the proof.
Keeping a proof in one cell is already the rule (§ *One cell per statement*); this is a second reason for it, and the trailing cell needs the `Proof` style if a proof must be split.

**Plain `Default.nb` is not an alternative.**
Under it a reference to a definition renders **`2.0`** — the section counter increments and the theorem counter never does.
`PlainArticle` is the minimum sheet that keeps numbering alive.

Numbering facts to write against:

- **Statement numbers are per-section**, `⟨section⟩.⟨n⟩`, shared across all twelve environments — a theorem then its Example in section 3 are 3.1 and 3.2. `ComplexSystems` alone gives each environment its own counter.
- **Equation numbers are document-global**, `(n)`; `Section` does not reset them.
- The Plain class (`Theorem`, `Lemma`, `Proposition`, `Corollary`, `Conjecture`, `Claim`) **italicises the body** — the amsthm convention. The Definition class is roman.
- **One open defect:** `PlainArticle`'s `DisplayFormula` is left-flush where the journal templates centre theirs, so an equation inside an environment body sits 64 pt left of the block's prose. It is open by decision, not oversight — changing it is a typography change to the one sheet that deliberately holds none, and it is Pavel's call (MathNotebook `EnvironmentBlocks` T3).

### Swapping the sheet is the reader's move, not the build's

The MathNotebook palette's **Apply stylesheet** menu offers `AMSArticle`, `ArXivArticle`, `RevTeXAPS`, `SpringerJournal`, `ComplexSystems` and Default.
Mention this in Initialization; do not do it in the build.
Two reasons the build always ships `PlainArticle` embedded:

- **A palette swap sets the sheet by name**, replacing the embedded definitions with a path into a paclet layer on the author's disk. A cloud reader without the paclet then gets **zero** style definitions — no counters, and no labels either, because the label *is* the `CellDingbat` the sheet supplies.
- **By-name resolution is not measured to work here.** The paclet's own record (`BasicFunctionality` T4) has all six sheets falling back to `Default.nb` for a locally installed copy — Title 45 where the embedded `Get` gives 26 — before a menu reset, after `ResetMenusPacket`, and with the front end freshly launched. It worked for a cloud-installed copy. Treat the swap as a documented author action, not a verified one.

Use `Author` for the `[ LLM Generated ]` line and for the model.
`Subtitle` resolves under `PlainArticle` but `AMSArticle` declares no `Subtitle`, so a line written in it loses its typography on a swap.
`Author` and `Date` survive every swap.

## References

MathNotebook's bibliography engine is reachable only from `ImportLaTeXDocument`, so on the Markdown path the References section is the generator's to build.
`scripts/mathnotebook_post.wl` does it:

- `BibTeXReferences[ file ]` parses a `.bib` into `<| tag -> formatted |>`. There is no `Import[ …, "BibTeX" ]` in Wolfram, so this is a small hand parser; it handles the shapes `cite` emits — braced fields, quoted fields, and the bare numeric `year = 2011` — and links `doi` → `doi.org`, else `eprint` → `arxiv.org`, else `url`. A braced value closes at the `}` that ends the *field*, so brace-protected capitalisation (`title = {A {Hodge} theory}`) survives, and the guarding braces are deleted from what prints.
- `ReferenceCells[ entries ]` emits `Reference` cells tagged with the key and labelled `[tag]` in the margin.
- `ConvertCitations[ cells, bibTags ]` turns `[tag]` in prose into a button (SKILL.md § *Referencing*). Only tags that exist are converted — the cells' `CellTags` plus the bib keys passed in; ordinary bracketed prose and Markdown links are left alone.

Keep bib keys **under about 25 characters**: the `Reference` gutter is 205 pt with `ParagraphIndent -> -24` in all seven sheets, sized against a 26-character key with 15 pt clearance.

A `Reference` cell needs **both** `CellTags -> key` and the `[key]` dingbat, or it prints unlabelled and indented into an empty gutter.
`ReferenceCells` writes both.
The paclet's `LabelReferences` repairs a notebook that lacks them, in place, without disturbing `CellID`s — but it takes a `NotebookObject` or falls back to the input notebook, so **it needs a front end and is not available to the build**; it is the author's repair for an already-open notebook.

The References heading is a suppressed `Section` cell needing `CounterIncrements -> { }`, `CellDingbat -> None` **and** `TaggingRules -> <| "MathNotebook" -> <| "Suppressed" -> "True" |> |>`; with only the first it prints the *previous* section's number.

## Tables

The converter's `2ColumnTableMod` / `TableText` / `ModInfo` styles are declared in no sheet, so a Markdown pipe table renders as plain monospace with no rules.
Write a weight-bearing table as a `Grid` in a `wolfram` fence; keep pipe tables for throwaway comparisons.
Most tables belong in *Ruliology* anyway (style.md).
