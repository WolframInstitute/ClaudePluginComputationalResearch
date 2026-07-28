---
name: research-notebook
description: >
  Build an LLM-generated "research notebook": a concise, mathematically precise,
  cloud-published Wolfram notebook that develops one topic as a research
  document in a fixed canonical order — the definitions first, then the theorems
  (with conjectures and their computed evidence subsumed there), then the
  symbols and functions used, then the relevant code calls — closing with
  enumerated further research questions and a cited literature section.
  Converts the Markdown source with the rich MarkdownToNotebook parser, then
  applies the MathNotebook paclet environments (Definition, Theorem, Conjecture,
  Question, ...) so statements translate directly to Lean. Visual-first: mostly
  pictures and plots, not numeric dumps. Generated one-way from a readable
  Markdown source the user edits directly; a per-cell fingerprint detects any
  edit made in the .nb instead, and regeneration stops rather than overwrite it.
  Use when the user says "research notebook", "notebook with conjectures",
  "research document on X", "write up the research on X", or the
  /research-notebook command.
---

# Research Notebook

A research notebook is a *mathematical research document*, not a demo and not an
exploration log:

| Skill | Produces |
|-------|----------|
| `new-notebook` | generic Markdown → `.nb` pipeline (this skill builds on it) |
| `research-notebook` | definitions → theorems + evidence → symbols/functions → code calls → open questions → literature |

**Style: lightweight and precise.** Every sentence either defines, states, or
points at code. No filler prose, no over-explanation, no code inside Text
cells. If a paragraph doesn't add a mathematical fact, delete it.

Three read-on-demand siblings carry the deep mechanics — read only what the
current step needs:

- [fingerprint.md](fingerprint.md) — the drift-detection fingerprint: stamping,
  checking, and why no `.nb` → `.md` direction exists
- [mathnotebook.md](mathnotebook.md) — MathNotebook install, stylesheet
  embedding, verified environment mechanics
- [output-embedding.md](output-embedding.md) — evaluating Input cells and
  embedding Output cells headless

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
See *MathNotebook environments and Lean-translatability* and *Citations and
References*.

**Never write `::: theorem` or `::: proof` divs in these sources.** The
converter's fenced-div environments exist only under `Template: Chapter`, which
would force the WolframBookTools stylesheet; under `Default` the divs are
**silently dropped entirely** — no cells, no message. Use the bold environment
markers instead.

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
user — transcribe it into the `.md` or discard it, never regenerate over it.
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

`author:` becomes an `Author` cell (an AMSArticle style) directly under the
Title; credit the human first and the model by name. The notebook opens with

1. `[ LLM Generated ]` — the **very first cell, above the Title**,
2. the `Title`,
3. the `Author`,
4. the `Abstract`.

AMSArticle declares no `Subtitle` style, so a `Subtitle` cell falls through to
`Default.nb` and loses the sheet's typography. Use the `Author` style for the
`[ LLM Generated ]` line.

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
`DisplayFormula` cells at level `{1}` in document order before calling
`MathNotebookDocument`. `NumberTaggedFormulas` promotes exactly the tagged ones.

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

## MathNotebook environments and Lean-translatability

Install, stylesheet embedding, and the verified marker mechanics are in
[mathnotebook.md](mathnotebook.md); what an author needs while writing the
source is here.

**Source convention → environment cells.** In the `.md` source, open a paragraph
with a bold marker. All **12** environments are available, sharing one counter:

| Class | Markers | Rendered |
|---|---|---|
| Plain | `**Theorem.**` `**Lemma.**` `**Proposition.**` `**Corollary.**` `**Conjecture.**` `**Claim.**` | bold label, **italic body** |
| Definition | `**Definition.**` `**Example.**` `**Construction.**` | bold label, roman body |
| Remark | `**Remark.**` `**Question.**` `**Observation.**` | italic label, roman body |

Numbering is the front end's to compute and **never yours to write**: do not put
a number in the source. Two counter facts to write against:

- **Theorem numbers are per-section**, `⟨section⟩.⟨n⟩`, shared across all 12
  environments — a Definition then a Theorem in section 1 are 1.1 and 1.2.
- **Equation numbers are document-global**, `(n)`; `Section` does not reset them.

Note that the Plain class italicises the body, which is the amsthm convention but
surprises authors who write a long `Theorem` cell.

**Write every Definition, Theorem, and Conjecture so it translates directly to a
Lean statement**: explicit hypotheses, explicit quantifiers, quantification over
finite/decidable objects wherever possible ("for every connected graph G with
|V| ≤ n ..."), no appeals to pictures inside statements. Open questions and
proved conjectures feed the [lean](../lean/SKILL.md) skill for formalization.

## Canonical document order — Critical

The generated document develops its topic in this fixed order — the four core
blocks are user-mandated and not negotiable:

1. **Head**: `[ LLM Generated ]` line, **Title**, **Author**, then a 2–4
   sentence **Abstract** stating the main claims — written **last**, after the
   evidence is in.
2. **Initialization** (folded, init cells): paclet loads, MathNotebook load,
   `SeedRandom`, a reproducibility line (paclet version, git commit, date),
   and the example-object constructions **copied verbatim from the project's
   example module**, so the notebook is self-contained.
3. **Definitions** — the list of definitions: `Definition` cells, precise,
   Lean-translatable. When a metric construction is set-valued by default, name
   the set-valued object as the primitive and the single-valued case by a
   predicate — decide by **closure** under the theory's operations, verify the
   closure computationally, and state the convention in a `Remark` whose
   Example is that computation (a worked case:
   [Wiki/Concepts/DisplacementNaming.md](../../Wiki/Concepts/DisplacementNaming.md)).
4. **Theorems** — the list of theorems, with conjectures and their evidence
   subsumed here: each statement a numbered `Theorem` / `Conjecture` cell
   followed by a folded **Example** subsection (titled `### Example`, never
   "Evidence") — a systematic check over the project's example battery whose
   verdict is rendered **as a graphic** (see *Visual-first*).
   Each conjecture carries a status marker: `verified up to n = ...` / `open` /
   `proved in [ref]`. A conjecture that fails the battery is **demoted to a
   Question** and the minimal counterexample found is kept, as a picture.
   State how the defined notions relate — the implication lattice as a display
   formula, each independence backed by a **counterexample and a census**, not
   an assertion. Never assert an implication you have not checked: enumerate
   over small objects (full enumeration on a small object beats sampling on a
   large one), and expect some proposed claims to be false — finding the
   exception is the result.
5. **Symbols and functions used** — a flat index of every symbol the notebook
   uses, grouped by role (constructions / operations / invariants and
   predicates / visualisation), each a literal symbol name, an em dash, and at
   most a dozen words. This is the reader's index; it is not the demonstrations.
6. **The relevant code calls** — one Section per function, titled by the
   **literal symbol name** (e.g. `GraphInteriorForm`); Subsections titled by the
   literal option/method form (e.g. `"Method" -> "3DFiber"`). Short Text cell,
   then code, then picture. Follow `wi:sw-example` house style when present.
7. **Further research questions** — an enumerated list (`ItemNumbered`), each
   referencing the theorems/definitions it concerns by number; proof
   strategies for the conjectures live here.
8. **Literature** — every claim that isn't ours gets a citation tag `[tag]`
   (MathNotebook `Citation` style); the final References section lists the
   entries, produced by the [cite](../cite/SKILL.md) skill and kept in sync
   with `Paper/references.bib` when the project has one. See *Citations and
   References* below for the mechanism.

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

Keep bib keys **short** — a long key overflows the `Reference` style's left
margin and runs off the page.

## Prose style — Critical

Write like a mathematics thesis, not like a product announcement.

- **Declarative "we" voice**: "We define…", "We prove…", "We ask whether…".
- **The abstract is a roadmap**, one short paragraph per section, in order:
  "In the Definitions section, we define… In the Theorems section, we prove…".
  Write it last.
- **No selling.** Banned: "exact structural facts", "the strongest", "cleanly",
  "sharp", "fragile", "cautionary", "genuinely", "remarkable", "powerful",
  "elegant", and any adjective asserting the work's importance. State the fact
  and let the reader judge. Say "the bound 2 cannot be lowered, since margin 1
  fails" — not "the margin is sharp".
- **Name the operation, not its mechanism**, once the mechanism is in the
  definition: "sum", "inverse" — not "bisector sum", "metric inverse".
- **One fact per sentence**, with the qualifier attached: "verified on the 8×8
  honeycomb patch" rather than "verified".

## Visual-first — Critical

The notebook is **mostly pictures and plots**. Never end an Example or
demonstration cell with a bare number, boolean list, or textual table:

- verdicts over the example battery → `ArrayPlot`/heatmap grid or a row of
  highlighted graphs, pastel colors;
- counterexamples → the object drawn with the violating substructure
  highlighted;
- quantitative claims → a plot, not a list of values.

A small symbolic result (a single boolean, a short set) may stand alone only
when that value *is* the point.

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
  converter's `"Default.nb"` with the *embedded* AMSArticle sheet, which is what
  makes the notebook readable in the cloud. Pass notebook options through it
  rather than rebuilding the `Notebook` yourself — with prompt tracking on, that
  includes `TaggingRules -> { "Provenance" -> prov }` built from the source's
  provenance comment (stripped from the `.md` string before conversion); the
  fingerprint stamp later merges its `"ResearchNotebook"` key alongside it.
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

- [ ] `.md` source in `NotebooksLLM/`, readable enough to edit while reading the `.nb`; the user told which file to edit.
- [ ] `CellID`s assigned by the generator; fingerprint computed **after** the export/re-import round-trip and stored in `TaggingRules` by **merging** into the option (`stampTaggingRule`) — a `"Provenance"` key may already sit there.
- [ ] Drift checked before every regeneration; any user edit in the `.nb` stops the build and goes to the user, never overwritten.
- [ ] Converted with the rich engine at the pinned clone (`Template: Default`, `"Evaluate" -> False`), `CellLabel` stripped; built-in fallback only if the clone is absent, and said out loud.
- [ ] No `::: theorem` / `::: proof` divs in the source — silently dropped under `Default`.
- [ ] `author:` rendered as an Author cell (the `Default` template emits none); frontmatter stripped only on the built-in fallback path.
- [ ] `[ LLM Generated ]` line above Title / Author / Abstract — note AMSArticle declares no `Subtitle` style, so that line falls through to `Default.nb`; use `Author` to keep the sheet's typography.
- [ ] Rich mode: `$…$` / `$$…$$` used freely, but no `\to` or `\mapsto` (silently empty) and no `\tag{…}`. Built-in fallback: plain Unicode in Text, `FormBox` fences for display math.
- [ ] Equation `CellTags` attached after conversion, in document order, before `MathNotebookDocument`.
- [ ] Weight-bearing tables written as a `Grid` in a `wolfram` fence — pipe tables render unstyled under both sheets.
- [ ] MathNotebook stylesheet **embedded** (not referenced) + environments; markers converted by `ConvertEnvironmentCells`; equation tags promoted by `NumberTaggedFormulas`; citations by `ConvertCitations`, in that order.
- [ ] Section order: Head, Initialization, Definitions, Theorems, Symbols and functions used, Code calls, Further research questions, Literature.
- [ ] Definitions and theorems Lean-translatable (explicit hypotheses and quantifiers); set-valued naming decided by closure, convention stated in a Remark.
- [ ] Theorems section: every conjecture has an `### Example` subsection rendered as a graphic and a status marker; failures demoted to Questions with counterexample pictures; implication lattice stated with counterexample + census per independence.
- [ ] Symbols-and-functions index lists every symbol used, grouped by role, one line each.
- [ ] Code-call sections titled by literal function/option code; no code in Text cells.
- [ ] Enumerated further research questions referencing theorems by number.
- [ ] Literature section built with `BibTeXReferences` + `ReferenceCells` from `Paper/references.bib`; bib keys short.
- [ ] Initialization folded: seeds, reproducibility line, example-module constructions.
- [ ] Prose in thesis voice; abstract a section-by-section roadmap, written last; no selling adjectives.
- [ ] Zero-message evaluation; Output cells embedded (graphics live, not rasterized); `ExportString` result checked with `StringQ` and the file re-imported.
- [ ] Deployed public; README `Research Notebooks` table updated.
