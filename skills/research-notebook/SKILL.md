---
name: research-notebook
description: >
  Build an LLM-generated "research notebook": a concise, mathematically
  precise, cloud-published Wolfram notebook that develops one topic as a
  research document — definitions, then the claims and conjectures the
  computations support, then the open questions, then the literature; with the
  symbol index and the initialization code placed below the document, out of
  the reader's way. Definitions and claims alike carry a folded, numbered
  Example: a real computation over a family of objects answered as a graphic —
  a histogram, a census plot, a parameter scan — never a decorative
  illustration. Converts the Markdown source with the rich MarkdownToNotebook
  parser, then applies the MathNotebook paclet environments (Definition, Claim,
  Conjecture, Question, ...) on the PlainArticle stylesheet, so statements
  translate directly to Lean and the page looks like a stock notebook.
  Visual-first: mostly pictures and plots, not numeric dumps. Generated one-way
  from a readable Markdown source the user edits directly; a per-cell
  fingerprint detects any edit made in the .nb instead, and regeneration stops
  rather than overwrite it. Use when the user says "research notebook",
  "notebook with conjectures", "research document on X", "write up the research
  on X", or the /research-notebook command.
---

# Research Notebook

A research notebook is a *mathematical research document*, not a demo and not an
exploration log:

| Skill | Produces |
|-------|----------|
| `new-notebook` | generic Markdown → `.nb` pipeline (this skill builds on it), and every per-function demonstration |
| `research-notebook` | definitions → claims and conjectures with folded evidence → open questions → literature, over an appendix of symbols and initialization |

## The governing rule — Critical

**Concise and clear. Simplicity of text and structure wins.**
The notebook exists to convey a small number of clear messages.
Every sentence either defines, states, or points at evidence.
No filler prose, no over-explanation, no code inside Text cells, no section that
exists only for symmetry.
If a paragraph does not add a mathematical fact, delete it.

This rule outranks every other instruction here.
Where a convention below would add structure the topic does not need, drop the
structure.

## When to use

- The user says "research notebook", "notebook with conjectures", "research
  document on X", "write up the research on X", or runs `/research-notebook`.
- A topic's computations have accumulated enough to be written up as a precise,
  citable document.

## Steps

1. Write or update the `NotebooksLLM/<Topic>.md` source in the canonical
   document order below, following *TeX in the sources* and *Prose style*.
2. If a generated `.nb` exists, run the drift check first
   ([fingerprint.md](fingerprint.md)); stop on any drift.
3. Convert (§ *The conversion call*), evaluate and embed outputs
   ([output-embedding.md](output-embedding.md)), stamp the fingerprint.
4. Publish and link (§ *Evaluate, publish, link*), then § *After publishing*.

Three read-on-demand siblings carry the deep mechanics — read only what the
current step needs:

- [fingerprint.md](fingerprint.md) — the drift-detection fingerprint: stamping,
  checking, and why no `.nb` → `.md` direction exists
- [mathnotebook.md](mathnotebook.md) — MathNotebook install, stylesheet
  embedding, verified environment mechanics
- [output-embedding.md](output-embedding.md) — evaluating Input cells and
  embedding Output cells headless

## Canonical document order — Critical

The document is a **paper with an appendix under it**.
The reader meets the mathematics and never has to scroll past machinery to do
it.

### The paper

1. **Head** — `[ LLM Generated ]` line, **Title**, **Author**, **Abstract**.
   The abstract is 2–4 sentences stating the main claims, written **last**,
   after the evidence is in. It is not a section-by-section roadmap; the reader
   can already see the sections.
2. **Definitions** — `Definition` cells: precise, Lean-translatable, and
   carrying **no implementation detail**. A definition states what the object
   is; it does not name the symbol that computes it. That binding lives in the
   Symbols appendix, which points back here.
   A definition **may carry a folded `Example`** of its own, on the same terms
   as a claim's (§ *Examples*): it measures the defined object over a family and
   plots what it found. Give one to any definition whose object has behaviour
   worth measuring; omit it where the honest content would be a single drawn
   instance. The section reads as a clean list of definitions either way,
   because the computation is folded underneath.
   When a metric construction is set-valued by default, name the set-valued
   object as the primitive and the single-valued case by a predicate — decide by
   **closure** under the theory's operations, verify the closure computationally,
   and state the convention in a `Remark` (a worked case:
   [Wiki/Concepts/DisplacementNaming.md](../../Wiki/Concepts/DisplacementNaming.md)).
3. **Claims and conjectures** — the results. Each statement is one environment
   cell chosen by § *Which environment*, followed immediately by a **folded
   `Example` cell group** holding the computation and its graphic — the evidence,
   held to the bar in § *Examples*. Here the Example is the point of the claim,
   so a claim whose Example cannot clear that bar is a claim that has not been
   checked: say so with a status marker rather than shipping a decorative
   picture.
   Each conjecture carries a status marker: `verified up to n = ...` / `open` /
   `proved in [ref]`. A conjecture that fails its battery is **demoted to a
   `Question`** in section 4 and the minimal counterexample is kept, as a
   picture.
   State how the defined notions relate — the implication lattice as a display
   formula, each independence backed by a **counterexample and a census**, not
   an assertion. Never assert an implication you have not checked: enumerate
   over small objects (full enumeration on a small object beats sampling on a
   large one), and expect some proposed claims to be false — finding the
   exception is the result.
4. **Questions** — `Question` cells, one per open question, each referencing
   the definitions and claims it concerns by number. Proof strategies for the
   conjectures live here. This is the **only** place open questions live:
   a conjecture demoted from section 3 moves here rather than staying put.
5. **References** — every claim that isn't ours carries a citation tag `[tag]`;
   this section lists the entries. See § *Citations and References*.

### Below the paper

6. **Symbols** — a flat index of every symbol the notebook uses, grouped by role
   (constructions / operations / invariants and predicates / visualisation).
   One line each: the literal symbol name, an em dash, a short description, and
   a back-reference by number to the definition it realizes —
   `GraphInteriorForm — the interior form of Definition 2.3.`
   Those numbers are `CounterBox`es resolved by the front end, so they follow
   the cells if anything moves.
   This is a reference, never read linearly; that is exactly why it sits here
   and disturbs nobody.
7. **Initialization** — folded init cells: paclet loads, MathNotebook load,
   `SeedRandom`, a reproducibility line (paclet version, git commit, date), and
   the example-object constructions **copied verbatim from the project's example
   module**, so the notebook is self-contained.
   Add one Text cell noting that the stylesheet can be swapped from the
   MathNotebook palette (§ *The stylesheet*).

**Initialization can sit at the bottom because the outputs are embedded.**
Nothing above it needs evaluating to be read — the shipped notebook already
carries its results. An `InitializationCell` evaluates on open regardless of
where it sits, so a reader who does want to compute is served too.

### What this document does *not* contain

**No per-function demonstration sections.** A section per symbol, titled by the
literal code, showing options and methods, is a `new-notebook` deliverable. This
skill produces the mathematics; the symbol index is the only trace of the code
in it.

## Which environment — Critical

All **12** MathNotebook environments are available and share one counter.
Choosing among them is a claim about the *status* of a statement, so choose
honestly:

| Environment | Use for |
|---|---|
| `Definition` | vocabulary — every term the notebook uses |
| `Claim` | **the default.** A statement we assert and have checked computationally |
| `Conjecture` | a statement we believe and have not settled |
| `Theorem` | reserved for something **big**, and only with a proof or a citation to one |
| `Lemma` | only a step toward a `Theorem`, stated immediately before it |
| `Proposition`, `Corollary` | as in a paper: a minor proved result; a consequence of the statement above |
| `Example` | the folded computational evidence under a claim or conjecture |
| `Remark`, `Observation` | commentary — a convention, a caveat, an aside. Use these freely rather than loose prose |
| `Question` | an open question |
| `Construction` | a construction the notebook reuses |

**`Claim` is the workhorse.** An LLM-generated notebook of computational
evidence proves almost nothing, so `Theorem` is the exception and not the
default. A `Lemma` with no theorem after it is a `Claim` that has been
mislabelled.

Numbering is the front end's to compute and **never yours to write**: do not put
a number in the source. Two counter facts to write against:

- **Numbers are per-section**, `⟨section⟩.⟨n⟩`, shared across all 12
  environments — a Claim then its Example in section 3 are 3.1 and 3.2.
- **Equation numbers are document-global**, `(n)`; `Section` does not reset them.

The Plain class (`Theorem`, `Lemma`, `Proposition`, `Corollary`, `Conjecture`,
`Claim`) **italicises the body**, which is the amsthm convention but surprises
authors who write a long cell. The Definition class is roman.

**Write every Definition, Claim and Conjecture so it translates directly to a
Lean statement**: explicit hypotheses, explicit quantifiers, quantification over
finite/decidable objects wherever possible ("for every connected graph G with
|V| ≤ n ..."), no appeals to pictures inside statements. Open questions and
settled conjectures feed the [lean](../lean/SKILL.md) skill.

## Examples — Critical

An `Example` belongs under a `Definition` as much as under a `Claim` or
`Conjecture`: under a definition it shows what the object *does*, under a claim
it is the evidence.

### An Example is a computation, not an illustration

**The bar: an Example must compute something whose answer was not obvious
before it ran, and show that answer as a graphic.** At minimum a histogram.

Concretely, an Example clears the bar when both hold:

- It runs over a **family** of objects — a census, a scan, a parameter sweep —
  not over one object. One instance drawn is an illustration.
- Its graphic carries a **distribution, a comparison, or a scan**: a histogram
  of an invariant over all graphs of a size; an `ArrayPlot` of verdicts over the
  example battery; a curve against a parameter; a grid of the cases that failed.

It does **not** clear the bar when it is a picture of the object just defined
with the relevant part coloured in, a restatement of the definition in code, or
a graphic chosen because the section looked bare.

**An Example that cannot clear the bar is omitted, not padded.** The governing
rule applies here with full force: a manufactured Example is worse than no
Example, because it costs the reader an unfold and returns nothing. Where a
single picture genuinely *is* the point — a minimal counterexample, say — put it
in a `Remark`, which promises less.

### Mechanically: an environment cell heading a folded group

The Example is an `Example` **environment cell** heading a
`CellGroupData[ { ... }, Closed ]` group — not an `### Example` subsection.

Three reasons: it numbers on the shared counter, so it is citable
(`Example 2.2`); it sits at the same structural level as the definition or claim
it serves rather than opening a new heading; and it removes the collision
between a subsection named "Example" and the environment of the same name.

Every post-processing pass walks into these groups, so markers, tagged equations
and citations inside a fold all convert — that recursion is load-bearing and was
added for this structure (`mapCellList` in `scripts/mathnotebook_post.wl`).

## The stylesheet — Critical

**Embed `PlainArticle.nb`.**
It is `Default.nb`'s typography with the paper's *structure* added: it declares
25 styles against `AMSArticle`'s 34, drops **every explicit `FontSize`** and the
`"Printout"` variants with them, and leaves `Title`, `Text`, `Author`,
`Reference` and the three `DisplayFormula` styles to `Default.nb`. What it does
declare is what the document needs to be a document — the twelve environments,
`Proof`, `Caption`, `Date`, `Hyperlink`/`Citation`/`URL`, and for the three
sectioning levels and `Abstract` only the number or the word that prints.

The result reads as a stock Wolfram notebook: no colour change, no font change,
numbering and labels intact.

**Plain `Default.nb` is not an alternative.** Under it a reference to a
definition renders **`2.0`** — the section counter increments and the theorem
counter never does. `PlainArticle` is the *minimum* sheet that keeps numbering
alive, which is why it exists.

Nothing the pipeline uses falls off the end: `Default.nb` declares `Author`,
`Reference`, `Title`, `Subtitle`, `Abstract`, `DisplayFormulaNumbered` and
`ItemNumbered`. It does not declare `Caption`, which is why `PlainArticle`
carries that one across.

### Swapping the sheet is the reader's move, not the build's

The MathNotebook palette's **Apply stylesheet** menu offers all six sheets plus
Default, so an author can retypeset the document as `AMSArticle`,
`ArXivArticle`, `RevTeXAPS`, `SpringerJournal` or `ComplexSystems` on their own
machine. Mention this in the Initialization section; do not do it in the build.

Two reasons the build always ships `PlainArticle` embedded:

- **A palette swap sets the sheet by name**, which replaces the embedded
  definitions with a path into a paclet layer on the author's disk. A cloud
  reader without the paclet then gets **zero** style definitions — no counters,
  and no labels either, because the label *is* the `CellDingbat` the sheet
  supplies.
- **By-name resolution is not currently measured to work here.** The paclet's
  own record (`BasicFunctionality` T4) has all six sheets falling back to
  `Default.nb` for a locally installed copy — Title 45 where the embedded `Get`
  gives 26 — before a menu reset, after `ResetMenusPacket` in the same session,
  and with the front end freshly launched. It worked for a cloud-installed copy.
  Treat the palette swap as a documented author action, not a verified one.

For the `[ LLM Generated ]` line use the `Author` style. `PlainArticle` leaves
`Subtitle` to `Default.nb`, which does declare it, so `Subtitle` would work here
— but `AMSArticle` declares no `Subtitle`, so a line written in it loses its
typography the moment the author swaps sheets. `Author` is the one style that
survives every swap.

## Pipeline — Critical

The source of truth is `NotebooksLLM/<Topic>.md`.
Conversion is a **two-half pipeline**, and both halves are load-bearing:
`WolframInstitute/MarkdownToNotebook` parses the Markdown, then
`scripts/mathnotebook_post.wl` applies the environments, the numbering, and the
citations.
The generated `.nb` sits beside the source, gitignored, dated on first creation.

The parser half is the **rich engine** documented in
[new-notebook](../new-notebook/SKILL.md) *Conversion engine — built-in vs rich*:
the pinned local clone, `Template: Default`, `"Evaluate" -> False`.
A research source always carries frontmatter and LaTeX math, so that skill's
selection rule always picks rich mode here — but the built-in importer remains
the fallback when the clone is absent, and the fallback **changes what you may
write in the source** (see *TeX in the sources — engine-dependent*).
The backtick-escaping and init-cell-marking rules from `new-notebook` still
apply; `boxifyInputCells` and the heading shift do **not** — rich mode drops
both.

The post-processing half is unchanged and still mandatory: MarkdownToNotebook
supplies **no** environments on the `Default` path, no anchors, no
cross-references, and no bibliography.

**Never write `::: theorem` or `::: proof` divs in these sources.** The
converter's fenced-div environments exist only under `Template: Chapter`, which
would force the WolframBookTools stylesheet; under `Default` the divs are
**silently dropped entirely** — no cells, no message. Use the bold environment
markers instead: open a paragraph with `**Definition.**`, `**Claim.**`,
`**Conjecture.**`, `**Question.**`, `**Remark.**`, and `ConvertEnvironmentCells`
strips the marker and applies the style.

### Generation is one-way; the fingerprint guards the .nb

**The `.md` → `.nb` direction is the only transfer.** There is no `.nb` → `.md`
transfer at all, in either engine — the measured evidence is in
[fingerprint.md](fingerprint.md) § *Why there is no reverse direction*.

So the working arrangement is: **the user reads the `.nb` and edits the `.md`.**
That is only honest if the `.md` is genuinely readable, which is a live
constraint on how you write it and a further reason rich mode matters — readable
`$…$` LaTeX in the source instead of the built-in path's plain-Unicode and
`FormBox` fences. Tell the user this explicitly the first time a notebook is
generated: point at the `.md` as the file to edit, and say the `.nb` is a build
product.

**But never assume the user obeyed that.** The build stamps a per-cell
fingerprint, and every regeneration checks it first; if any cell was added,
deleted, or edited in the `.nb`, **the build stops** and the drift goes to the
user — the [revise](../revise/SKILL.md) loop: transcribe it into the `.md` or
discard it, never regenerate over it.
The stamping and comparison procedure, with its two load-bearing details, is in
[fingerprint.md](fingerprint.md).

## Source frontmatter and the notebook head

The `.md` carries YAML frontmatter.
**Rich mode consumes it as metadata**, so there is nothing to strip — that is one
of the reasons this skill uses the rich engine.
The built-in importer does **not** understand it: on the fallback path, left in
place it renders as a literal Text cell reading `notebook: X title: Y` above the
Title, so strip it before `ImportString` there.
Either way the keys are metadata, not content — the `Default` template emits no
`Author` cell, so the generator inserts it from the frontmatter itself:

```markdown
---
notebook: Curvature
title: Ollivier curvature on graphs
author: Pavel Hajek, Claude <model name>
---
```

`author:` becomes an `Author` cell directly under the Title; credit the human
first and the model by name. The notebook opens with

1. `[ LLM Generated ]` — the **very first cell, above the Title**, in the
   `Author` style,
2. the `Title`,
3. the `Author`,
4. the `Abstract`.

## TeX in the sources — engine-dependent — Critical

**Which rule applies depends on which parser ran.** This is the one place where
the fallback changes what you may write, so settle the engine first.

### Rich mode (the normal path)

`$…$` and `$$…$$` are the **preferred** form: the TeX parser produces real
typeset boxes, `$…$` becomes a nested `InlineFormula` cell, and `$$…$$` becomes a
`DisplayFormula`. `=` survives, which is the built-in importer's worst defect.

Three losses remain, all measured at the pinned SHA:

- **`\to` and `\mapsto` are silently dropped** — they become an empty string, so
  `$f : V(G) \to \mathbb{R}^3$` typesets with nothing between `V(G)` and `ℝ³`.
  Write `\rightarrow` / `\longrightarrow` / `\hookrightarrow`, or paste the
  Unicode character straight into the math (`$a ↦ b$` works). `\Rightarrow`,
  `\circ`, `\times`, `\subset`, `\in`, `\leq`, `\neq` are all fine.
- **`\tag{…}` is not understood** — it renders literally as `(tag)` inside the
  formula. Numbering comes from `CellTags`, never from the TeX.
- **A `wolfram` fence starting with `FormBox[…]` stays an `Input` cell** showing
  the literal `FormBox` source. That convention is built-in-only; in rich mode
  use `$$…$$`.

Since `$$…$$` arrives with no `CellTags`, **the generator attaches them after
conversion**: keep an ordered list of tags while authoring, one entry per `$$`
block (`None` for an equation nothing cites), then apply it to the
`DisplayFormula` cells in document order before calling `MathNotebookDocument`.
`NumberTaggedFormulas` promotes exactly the tagged ones.

**Tag before you fold.** `tagFormulas` walks a flat cell list at level `{1}`, so
it must run *before* `foldExamples` builds the `CellGroupData` — an equation
already inside a group is invisible to it. `withCellIDs` runs after and must
therefore recurse into groups. The post-processing passes inside
`MathNotebookDocument` recurse on their own (`mapCellList`); this ordering
constraint is the generator's, not theirs.

### Built-in fallback (no clone present)

The Markdown importer **silently drops `=` and `\to`** inside inline `$…$` math
(`$X + Y = Y + X$` imports as "X + Y Y + X"). Relations like ≤ ≥ ∼ ⊂ ∈ survive,
which makes the failure easy to miss.

- In Text cells write **plain Unicode**: `X + Y = Y + X`, `d(u, v) ≤ k`,
  `f : V(G) → ℝ³`, `D₂∘D₁`, `ℤ₈ × ℤ₈`.
- For displayed equations use a `wolfram` fence whose content starts with
  `FormBox[…]`; post-processing turns it into a `DisplayFormula` cell with native
  typeset boxes.
- Never use `$…$` or `$$…$$` on this path.

## Citations and References

MathNotebook has cross-reference machinery but **no bibliography engine** —
nothing collects, sorts, or numbers entries, so the References section is the
generator's to build. `scripts/mathnotebook_post.wl` does it:

- `BibTeXReferences[ file ]` parses a `.bib` into `<| tag -> formatted string |>`.
  There is no `Import[ …, "BibTeX" ]` in Wolfram, so this is a small hand parser;
  it handles the shapes `cite` emits — braced fields, quoted fields, and the bare
  numeric `year = 2011` that Crossref returns — and links `doi` → `doi.org`,
  else `eprint` → `arxiv.org`, else `url`.
- `ReferenceCells[ entries ]` emits `Reference` cells tagged with the key and
  labelled `[tag]` in the margin.
- `ConvertCitations[ cells, bibTags ]` turns a literal `[tag]` in prose into a
  `Citation` button. A citation whose target is a numbered cell renders as **its
  number** — `(1)` for an equation, `Definition 2.3` for an environment,
  `Section 4` for a section — resolved by the front end, so it follows the target
  when cells move. A bibliography citation stays `[tag]`.

Only tags that actually exist are converted: the tags of cells in the notebook,
plus the bibliography keys passed in. Ordinary bracketed prose and Markdown links
are left alone.

Keep bib keys **short**. Under `AMSArticle` a long key overflows the `Reference`
style's left margin; under `PlainArticle` the style comes from `Default.nb`,
where the margin is different again — short keys are correct under both.

## Prose style — Critical

Write like a mathematics thesis, not like a product announcement. § *The
governing rule* comes first; these are its specifics.

- **Declarative "we" voice**: "We define…", "We claim…", "We ask whether…".
- **No selling.** Banned: "exact structural facts", "the strongest", "cleanly",
  "sharp", "fragile", "cautionary", "genuinely", "remarkable", "powerful",
  "elegant", and any adjective asserting the work's importance. State the fact
  and let the reader judge. Say "the bound 2 cannot be lowered, since margin 1
  fails" — not "the margin is sharp".
- **Name the operation, not its mechanism**, once the mechanism is in the
  definition: "sum", "inverse" — not "bisector sum", "metric inverse".
- **One fact per sentence**, with the qualifier attached: "verified on the 8×8
  honeycomb patch" rather than "verified".
- **Commentary goes in a `Remark` or `Observation`**, not in loose prose between
  cells. A labelled aside is easier to skip than an unlabelled one.

## Visual-first — Critical

The notebook is **mostly pictures and plots**. Never end a cell with a bare
number, boolean list, or textual table:

- distributions of an invariant over a family → a histogram;
- verdicts over the example battery → `ArrayPlot`/heatmap grid or a row of
  highlighted graphs, pastel colors;
- behaviour against a parameter → a curve, not a list of values;
- counterexamples → the object drawn with the violating substructure
  highlighted.

A small symbolic result (a single boolean, a short set) may stand alone only
when that value *is* the point.

This is the *floor* for any output cell. § *Examples* sets a higher bar for the
folded groups specifically: there the graphic must also answer something that
was not obvious before the computation ran.

## Evaluate, publish, link

1. **Smoke test**: evaluate every Input cell through the Wolfram MCP
   (license-aware — see [new-notebook](../new-notebook/SKILL.md) *Kernel
   execution*); the build must finish with **zero messages**.
2. **Embed outputs**: the generator evaluates every Input cell and attaches its
   Output cells, so the shipped notebook carries real results — procedure and
   traps in [output-embedding.md](output-embedding.md).
3. **Deploy** to the Wolfram Cloud, public, stable object name
   `<Project>/<Topic>.nb` (matching `Scripts/publish_notebooks.wls`).
4. **Link from the repo README** in a `## 📓 Research Notebooks` section — a
   table `| Notebook | Description | Link |`, one row per notebook, the link
   anchored on "Wolfram Cloud". Create the section if missing; update the row
   in place if the notebook already has one.

## The conversion call

Call the **pinned local clone**, never the deployed resource function: the
deployed copy lives on a personal `obj/nikm/` cloud path and is unversioned
(`ResourceObject[ url ][ "Version" ]` is `None`), so drift is undetectable. Do
**not** vendor the repo either — it is ~13 MB — and **never clone it silently**;
if it is absent, take the built-in fallback and say so.
See `Wiki/Resources/MarkdownToNotebook.md` for the pin and the recovery command.

```wolfram
Module[ { wl, nb, cells },

  wl = "MarkdownToNotebook/MarkdownToNotebook.wl";   (* pinned clone, project root *)

  Get[ wl ];
  nb    = MarkdownToNotebook[ "NotebooksLLM/<Topic>.md", "Evaluate" -> False ];
  cells = First[ nb ];

  (* the converter stamps In[n]:= even under "Evaluate" -> False *)
  cells = cells /. Cell[ c_, s_String, o___ ] :>
    Cell[ c, s, Sequence @@ DeleteCases[ { o }, CellLabel -> _ ] ];

  (* Author cell from the frontmatter, [ LLM Generated ] line, equation CellTags *)
  cells = researchHead[ cells ];
  cells = tagFormulas[ cells, eqTags ];
  cells = foldExamples[ cells ];  (* each Example cell heads a Closed group *)
  cells = withCellIDs[ cells ];   (* CreateCellID does not stamp built cells *)

  MathNotebookDocument[ cells, bibTags, CreateCellID -> True ]
]
```

Then write the notebook, re-import it, and stamp the fingerprint — see
[fingerprint.md](fingerprint.md) for why the fingerprint must come from the
round-tripped cells rather than from `cells` above.

Four things this shape gets right, each learned the hard way:

- **No heading shift and no `boxifyInputCells`** — `##` is already `"Section"`,
  and the boxes arrive structural. Both `new-notebook` workarounds must be off.
- **`MathNotebookDocument` last**, and it owns `StyleDefinitions`: it replaces the
  converter's `"Default.nb"` with the *embedded* sheet named by
  `$MathNotebookStyleSheetName` in `scripts/mathnotebook_post.wl`, which this
  skill sets to `PlainArticle.nb`. Pass notebook options through it rather than
  rebuilding the `Notebook` yourself — with prompt tracking on, that includes
  `TaggingRules -> { "Provenance" -> prov }` built from the source's provenance
  comment (stripped from the `.md` string before conversion); the fingerprint
  stamp later merges its `"ResearchNotebook"` key alongside it.
- **`ReplacePart` is not needed here** (unlike `new-notebook`) precisely because
  `MathNotebookDocument` rebuilds the notebook with the options you hand it.
- `ensureParser[ ]` installs `Wolfram/Parser` on first call, so a fresh machine
  does network I/O and, on failure, degrades silently to
  `ImportString[ …, "TeX" ]` with worse math fidelity. Probe
  `PacletFind[ "Wolfram/Parser" ]` and surface the degradation instead of
  swallowing it.

## After publishing

- Sync the open questions to the Wiki (or the journal, when it is on) so they
  outlive the notebook.
- If prompt tracking is on (`Prompt tracking: **on**` in `CLAUDE.md` — see
  [provenance](../provenance/SKILL.md)), the provenance comment belongs in the
  `.md` source **before** the build (so the `.nb` carries the `"Provenance"`
  `TaggingRules` key next to the fingerprint — see *The conversion call*);
  append the ledger entry to `Wiki/Prompts.md` here.

## Checklist

- [ ] Concise: every sentence defines, states, or points at evidence; no section kept for symmetry.
- [ ] `.md` source in `NotebooksLLM/`, readable enough to edit while reading the `.nb`; the user told which file to edit.
- [ ] `CellID`s assigned by the generator; fingerprint computed **after** the export/re-import round-trip and stored in `TaggingRules` by **merging** into the option (`stampTaggingRule`) — a `"Provenance"` key may already sit there.
- [ ] Drift checked before every regeneration; any user edit in the `.nb` stops the build and goes to the user, never overwritten.
- [ ] Converted with the rich engine at the pinned clone (`Template: Default`, `"Evaluate" -> False`), `CellLabel` stripped; built-in fallback only if the clone is absent, and said out loud.
- [ ] No `::: theorem` / `::: proof` divs in the source — silently dropped under `Default`.
- [ ] `PlainArticle.nb` **embedded** (not referenced); palette swap documented in Initialization, never done in the build.
- [ ] `author:` rendered as an Author cell; `[ LLM Generated ]` line above Title / Author / Abstract, in the `Author` style so it survives a sheet swap.
- [ ] Rich mode: `$…$` / `$$…$$` used freely, but no `\to` or `\mapsto` (silently empty) and no `\tag{…}`. Built-in fallback: plain Unicode in Text, `FormBox` fences for display math.
- [ ] Weight-bearing tables written as a `Grid` in a `wolfram` fence — pipe tables render unstyled under every sheet.
- [ ] Environments converted by `ConvertEnvironmentCells`; equation tags promoted by `NumberTaggedFormulas`; citations by `ConvertCitations`, in that order.
- [ ] Section order: Head, Definitions, Claims and conjectures, Questions, References, Symbols, Initialization.
- [ ] `Claim` is the default; `Theorem` only for something big and proved or cited; `Lemma` only immediately before a `Theorem`; commentary in `Remark` / `Observation`.
- [ ] Definitions carry no implementation detail and name no symbol; Lean-translatable, with explicit hypotheses and quantifiers; set-valued naming decided by closure, convention stated in a `Remark`.
- [ ] Every claim and conjecture followed by a folded `Example` **environment cell group** — not an `### Example` subsection; conjectures carry a status marker; failures demoted to `Question`s with counterexample pictures; implication lattice stated with counterexample + census per independence.
- [ ] Definitions carry a folded `Example` wherever the object has behaviour worth measuring; omitted, not padded, where it would only illustrate.
- [ ] **Every `Example` clears the bar**: computes over a *family*, answers something not obvious before it ran, and shows it as a histogram, census plot, parameter scan or comparison — never a single instance drawn with a part coloured in, never a restatement of the definition in code. A single telling picture goes in a `Remark` instead.
- [ ] Equation `CellTags` attached after conversion, in document order, **before** `foldExamples`; `withCellIDs` recurses into groups; all before `MathNotebookDocument`.
- [ ] Open questions live only in the Questions section, as `Question` cells, referencing definitions and claims by number.
- [ ] Symbols index below the paper: every symbol used, grouped by role, one line each, back-referencing its definition by number.
- [ ] Initialization last and folded: seeds, reproducibility line, example-module constructions, stylesheet-swap note.
- [ ] No per-function demonstration sections — those belong to `new-notebook`.
- [ ] References built with `BibTeXReferences` + `ReferenceCells` from `Paper/references.bib`; bib keys short.
- [ ] Prose in thesis voice; abstract 2–4 sentences of claims, written last; no selling adjectives.
- [ ] Zero-message evaluation; Output cells embedded (graphics live, not rasterized); `ExportString` result checked with `StringQ` and the file re-imported.
- [ ] Deployed public; README `Research Notebooks` table updated.

## Integration with other skills

- `new-notebook` supplies the base pipeline conventions (backtick escaping, init-cell marking, engine selection) and owns every per-function demonstration notebook; this skill layers the rich engine + MathNotebook post-processing on top.
- `cite` produces the bibliography entries; `lean` consumes the Lean-translatable statements; `provenance` stamps the `"Provenance"` key when its toggle is on.
- `update-wiki` / `journal` receive the open questions after publishing.

## When NOT to use

- A demo, tour, or exploration notebook, or a per-function walkthrough — that is `new-notebook` (or `start-tour`).
- The user edited the generated `.nb` and the drift is unresolved — the build stays stopped until they decide.
