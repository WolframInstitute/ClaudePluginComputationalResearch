---
name: research-notebook
description: >
  Write a mathematics paper as a Wolfram notebook. The document is an ordinary
  paper — introduction, then sections in the order the mathematics needs, each
  mixing definitions, examples, claims, proofs and remarks — not a fixed
  Definitions/Claims/Questions template, and with no symbol index. Every
  definition is followed by an Example: three to ten lines of plain code a
  reader can copy and change, answering with one bare graphic. Statements,
  equations and sections are numbered by the front end and cited by tag, never
  by a number typed into the source. Proofs are short and step by step, each
  step naming the definition or equation it uses. Converts a Markdown source
  with the MarkdownToNotebook parser, then applies the MathNotebook
  environments on the PlainArticle stylesheet, so statements translate directly
  to Lean and the page looks like a stock notebook. Generated one-way from the
  Markdown the user edits; a per-cell fingerprint stops the build rather than
  overwrite an edit made in the .nb. Use when the user says "research
  notebook", "notebook with conjectures", "research document on X", "write up
  the research on X", or the /research-notebook command.
---

# Research Notebook

A research notebook is **a mathematics paper that computes**.

The model is an `amsart` paper: numbered definitions and results, numbered
equations, cross-references by number, short proofs. The one thing a paper on
paper cannot do is run, so every definition here carries a worked Example.

| Skill | Produces |
|-------|----------|
| `new-notebook` | generic Markdown → `.nb` pipeline (this skill builds on it), and every per-function demonstration |
| `research-notebook` | a paper: definitions with examples, results with proofs, cross-referenced and numbered |

Use it when the user says "research notebook", "research document on X",
"notebook with conjectures", "write up the research on X", or runs
`/research-notebook`.

The reference for tone, structure and proof style is the author's own paper at
`~/Library/CloudStorage/OneDrive-Personal/Math/articles/FINISHED/hodgepaper/hodgepaper.tex`.
Read a section of it when the voice is unclear.

## The governing rule — Critical

**Mathematical content and structure. Nothing else.**

- If a fact can be an equation, make it an equation.
- One statement per sentence. Short sentences.
- Prose exists to connect equations, not to describe them.
- Delete any paragraph that adds no mathematical fact.
- Never write a number the front end can compute.

This rule outranks everything below. Where a convention here would add
structure the mathematics does not need, drop the structure.

## Steps

1. Write or update `NotebooksLLM/<Topic>.md` in paper order (§ *Structure*),
   following § *Language*, § *Definitions and Examples*, § *Referencing*.
2. If a generated `.nb` exists, run the drift check first
   ([fingerprint.md](fingerprint.md)); stop on any drift.
3. Convert (§ *The conversion call*), evaluate and embed outputs
   ([output-embedding.md](output-embedding.md)), stamp the fingerprint.
4. **Smoke test**: every Input cell evaluates through the Wolfram MCP
   (license-aware — see [new-notebook](../new-notebook/SKILL.md) *Kernel
   execution*) with **zero messages**.
5. **Deploy** to the Wolfram Cloud, public, stable object name
   `<Project>/<Topic>.nb` (matching `Scripts/publish_notebooks.wls`).
6. **Link from the repo README** in a `## 📓 Research Notebooks` section — a
   table `| Notebook | Description | Link |`, one row per notebook, the link
   anchored on "Wolfram Cloud". Create the section if missing; update the row
   in place if the notebook already has one.
7. Sync the open questions to the Wiki (or the journal, when on).
8. If prompt tracking is on (`Prompt tracking: **on**` in `CLAUDE.md` — see
   [provenance](../provenance/SKILL.md)), the provenance comment belongs in the
   `.md` **before** the build; append the ledger entry to `Wiki/Prompts.md`
   here.

Three read-on-demand siblings carry the deep mechanics — read only what the
current step needs:

- [fingerprint.md](fingerprint.md) — drift detection: stamping, checking, and
  why no `.nb` → `.md` direction exists
- [mathnotebook.md](mathnotebook.md) — MathNotebook install, stylesheet
  embedding, environment mechanics
- [output-embedding.md](output-embedding.md) — evaluating Input cells and
  embedding Output cells headless

## Language — Critical

Write in the language of mathematics papers. Nothing else.

**Banned — vocabulary imported from other fields.** It reads as jargon from
data engineering, journalism or software testing, and each has an exact
mathematical replacement:

| Do not write | Write |
|---|---|
| census, sweep, scan, battery, suite | "for all connected graphs with at most 8 vertices"; "as a function of $t$" |
| witness | example, counterexample |
| the bar, clears the bar | (delete — say what the example computes) |
| workhorse, pipeline, harvest, probe, drill down | (delete) |
| verdict, audit, smoke test, flag | (delete; in prose write "we verified") |
| marker, tag | label, number — `CellTags` only when talking about the build |

**Banned — adjectives asserting importance:** remarkable, powerful, elegant,
striking, cleanly, sharp, fragile, genuinely, cautionary, deep, beautiful.
State the fact. Write "the bound 2 cannot be lowered, since margin 1 fails" —
not "the margin is sharp".

**Use the standard phrases.** We define. Let $G$ be. Suppose that. Then. It
follows that. Conversely. One checks that. We verified for all. Notice that.
We ask whether. We say that $X$ is *reduced* if.

**Voice:** declarative "we". Italicise a term where it is defined
(`a *Hodge decomposition* of $(V, \mathrm{d})$ is …`) and never again.

**Commentary goes in a `Remark`**, not in loose prose between cells. A labelled
aside is easier to skip.

## Structure — an ordinary paper

**There is no fixed section order.** The document is organised the way the
mathematics is organised. Sections carry mathematical titles ("Hodge
decompositions", "Curvature on trees"), never structural ones ("Definitions",
"Claims", "Results").

What is required:

1. **Head** — `[ LLM Generated ]` line, `Title`, `Author`, `Abstract`.
   The abstract is 2–4 sentences stating the results, written last.
2. **Introduction** — what the notebook does, and the results. State each main
   result in the introduction as a numbered `Theorem` / `Claim` / `Conjecture`
   cell whose body says where it is proved ("this is [Prop:Extension]"),
   exactly as the model paper does. A reader who stops after the introduction
   knows every result.
3. **The body** — sections in the order the mathematics needs. Nothing is used
   before it is defined. Each section freely mixes `Definition`, `Example`,
   `Claim`, `Proof`, `Remark`, `Question`.
4. **References** last.
5. **Initialization** last of all, folded (§ *Initialization*).

What is **not** required, and is dropped unless the topic wants it:

- a Definitions section, a Claims section, a Questions section — statements sit
  where they are used;
- a Symbols index — removed from this skill; see § *Notation*;
- a Conventions section, unless there really is a standing convention, and then
  it is a `Remark` early on, as in the model paper;
- per-function demonstration sections — those are `new-notebook`'s.

Open questions may be collected in a final section when there are several, or
left as `Question` cells where they arise. Either is a paper.

## Notation

A definition defines a mathematical object; it does not name the function that
computes it. Bind the two in **one sentence after the definition**, or let the
Example do it by using the symbol:

> We compute the interior form with `GraphInteriorForm`.

That sentence is the whole notation apparatus. There is no symbol index.

## Definitions and Examples — Critical

**Every definition is followed by an Example.** That alternation —
`Definition`, `Example`, `Definition`, `Example` — is the rhythm of the
document, and nothing comes between a definition and its Example.

A `Claim` or `Conjecture` takes an Example when a picture helps; it is not
required to.

### What a Definition is

- One object per definition. Explicit hypotheses, explicit quantifiers,
  quantification over decidable objects where possible ("for every connected
  graph $G$ with $|V(G)| \le n$"). No appeal to a picture inside the statement.
- Written so it translates directly to a Lean statement — this feeds the
  [lean](../lean/SKILL.md) skill.
- Numbered by the front end. Never type the number.

### What an Example is

**The smallest computation that shows the object.**

- **Three to ten lines of code**, readable top to bottom, that a reader can
  copy into a fresh notebook and change one argument in.
- It builds what it needs in a line, or uses an object from Initialization.
- It answers with **one bare graphic**. A single number is allowed only when
  that number is the point.
- **One instance is fine.** That is what an example is. Where the behaviour
  over a family is the point, plot the family — still in a few lines,
  `Table[ … ]` then `ListPlot`.
- Choose the smallest object in which the phenomenon appears. Not the triangle
  when the triangle is degenerate.

### No decoration — Critical

The `Example` cell already said what this is. The graphic carries no
`PlotLabel`, no legend, no frame, no `Style`, no `Labeled`, no annotation
restating the definition, and no color option beyond a pastel default. Anything
deletable without losing information is deleted.

Good:

```wolfram
graph = GridGraph[ { 4, 4 } ];
HighlightGraph[ graph, FindShortestPath[ graph, 1, 16 ] ]
```

```wolfram
curvatures = Table[ OllivierCurvature[ CycleGraph[ n ], 1, 2 ], { n, 3, 12 } ];
ListPlot[ curvatures, Joined -> True ]
```

Bad — variables, options and labels that carry no mathematics:

```wolfram
Module[ { g, path, styled },
  g = GridGraph[ { 4, 4 }, VertexSize -> Medium, GraphLayout -> "SpringEmbedding" ];
  path = FindShortestPath[ g, 1, 16 ];
  styled = HighlightGraph[ g, path, GraphHighlightStyle -> "Thick" ];
  Labeled[ styled, Style[ "Shortest path in the 4×4 grid", Bold, 14 ], Top ] ]
```

### Folded code, unfolded graphic — Critical

**The fold hides the code, never the result.** A reader scrolling the document
meets statements and pictures; the code is one click away and never in the way.
That is why an Example's code must be short — it is read by someone who chose
to open it.

The mechanism is the group state `{2}` — a closed group displaying its
**second** cell:

```wolfram
Cell[ CellGroupData[ {
  Cell[ codeString,             "Input"  ],
  Cell[ BoxData[ outputBoxes ], "Output" ] }, {2} ] ]
```

`Open` shows both, `Closed` shows the `Input` — backwards. `{n}` is the third
state: closed, displaying cell `n`.

Three consequences:

- **One Output per Input.** A closed group displays a single cell. Split the
  computation.
- **Nothing else is needed** — no `CellOpen -> False`, no
  `CellGrouping -> Manual`. Both were tried and are worse.
- **An `Input` cell must carry real code** — a code `String` or genuine boxes.
  `ToBoxes` applied to a code *string* ships a cell displaying the quoted
  string; the failure is silent and visible only on screen.

The `Example` environment cell is a **sibling above** the group, not its head.
It numbers on the shared counter, so it is citable as `Example 2.2`. An
`### Example` subsection is wrong on all three counts.

## Statements

| Environment | Use for |
|---|---|
| `Definition` | every term the notebook uses |
| `Claim` | **the default.** A statement we assert and have checked computationally |
| `Conjecture` | a statement we believe and have not settled |
| `Theorem` | something big, with a proof or a citation to one |
| `Lemma` | a step toward a `Theorem`, stated immediately before it |
| `Proposition`, `Corollary` | a minor proved result; a consequence of the statement above |
| `Example` | the computation under a definition or a claim |
| `Remark`, `Observation` | a convention, a caveat, an aside |
| `Question` | an open question |
| `Construction` | a construction the notebook reuses |
| `Proof` | a proof (§ *Proofs*) — unnumbered, not citable |

`Claim` is the default. Computational evidence proves nothing, so `Theorem` is
the exception. A `Lemma` with no theorem after it is a mislabelled `Claim`.

**A claim states its own range of verification**, in the statement, with the
numbers in it:

> **Claim.** Every connected graph $G$ with $|V(G)| \le 8$ satisfies
> $\kappa(G) \ge -1$. Verified by enumeration.

A `Conjecture` carries the same: `verified up to n = 9`, `open`, or
`proved in [Lambrechts2007]`. A conjecture that fails becomes a `Question`, and
the smallest counterexample is kept and drawn.

**Never assert an implication you have not checked.** Enumerate over small
objects; full enumeration on a small object beats sampling on a large one. Some
proposed statements will be false, and finding the counterexample is the result.

**An environment is a multi-cell block, and a `Text` cell breaks it.** A body
continuing past one cell — a paragraph after a display equation — continues in
a cell of the **same style** with `CellDingbat -> None` and
`CounterIncrements -> { }`. Drop to `Text` and the block breaks twice: the
margin jumps from 130 pt to 66, and a LaTeX export emits bare prose outside the
`\begin{definition}`. `CellGroupData` does not help.

## Proofs

Give a proof when there is one, and write it the way the model paper writes one.

- Open the cell with `**Proof.**`.
- **Step by step, one step per sentence**, in the order a reader checks them.
- **Every step names what it uses**: "by [Def:Hodge]", "by [Eq:Cyclic]", "by
  [Lem:HodgeType]". A step that uses nothing stated is a step the reader cannot
  check.
- Display the algebra. A computation running over three equalities is a
  display, not a sentence.
- No sentence carrying two steps of reasoning. Split it.
- No sketches, and no "one easily sees" standing in for a real step. Where a
  step is genuinely routine, write "One checks that" and give the one-line
  display.
- Where a step is computational, say what was computed and put the code in the
  Example after the proof.
- A proof needing more than about ten steps does not belong here. State the
  result as a `Claim` with a citation.

The shape to copy, from `Lemma 3.9` of the model paper:

> **Proof.** Because $V$ is non-negatively graded and the pairing
> $V^k \times V^{n-k} \rightarrow \mathbb{K}$ is nondegenerate, $V^k = 0$ for
> $k \notin [0,n]$. Given $v \in V^n$ we have $\mathrm{d}v \in V^{n+1} = 0$,
> hence $\mathrm{d}f(v) = f(\mathrm{d}v) = 0$. Therefore
> $$ \varepsilon'(f(v)) = \varepsilon'_*([f(v)]) = \varepsilon_*([v]) = \varepsilon(v), $$
> so $f$ preserves the chain-level orientation. If $f(v_1) = 0$ for some
> $v_1 \in V^k$, then
> $\langle v_1, v_2 \rangle = \varepsilon'(f(v_1) f(v_2)) = 0$ for all
> $v_2 \in V^{n-k}$, so nondegeneracy gives $v_1 = 0$.

`Proof` is a style declared by `PlainArticle`, and `**Proof.**` converts like
any other marker: it is in `$MathNotebookMarkerStyles` but not in
`$MathNotebookEnvironmentStyles` (`scripts/mathnotebook_post.wl`), so it takes
no number and cannot be cited. The style inherits from `Text` and supplies the
italic `Proof.` dingbat itself; it supplies no QED mark, and none is typed.

## Referencing — Critical

**Every number in the document is computed by the front end.** A number typed
into the source is a bug: a second source of truth, stale the moment a cell
moves.

Four things carry numbers, and all four are cited the same way — a bracketed
tag in the prose:

| Target | Source | Cited as | Renders |
|---|---|---|---|
| display equation | `$$…$$` with a tag | `[Eq:Cyclic]` | `(3)` |
| statement | environment cell with a tag | `[Def:Hodge]` | `Definition 2.1` |
| section | heading with a tag | `[Sec:Trees]` | `Section 4` |
| bibliography entry | `Paper/references.bib` key | `[Lambrechts2007]` | `[Lambrechts2007]` |

**The rendered form already contains the word.** Write `by [Def:Hodge]`, which
renders "by Definition 2.1" — never `by Definition [Def:Hodge]`.

### Writing a tag in the source

A tag is `{#Tag}`. It sits

- at the **end of the first paragraph** of the statement or heading it names;
- on the **line after** the display equation it names.

```markdown
## Hodge decompositions {#Sec:Hodge}

**Definition.** A *Hodge decomposition* of $(V, \mathrm{d}, \langle-,-\rangle)$
is a direct sum $V = \mathcal{H} \oplus \operatorname{im}\mathrm{d} \oplus C$
with $C \perp C \oplus \mathcal{H}$. {#Def:Hodge}

The pairing satisfies

$$ \langle \mathrm{d}v_1, v_2 \rangle = (-1)^{\deg v_1 + 1} \langle v_1, \mathrm{d}v_2 \rangle $$
{#Eq:Cyclic}

for all $v_1, v_2 \in V$, so a decomposition as in [Def:Hodge] is determined by
[Eq:Cyclic].
```

The generator strips every `{#Tag}` and attaches it as `CellTags` — for an
equation, to the `DisplayFormula` cell above it (§ *The conversion call*).
`ConvertCitations` then turns each `[Tag]` in prose into a button resolving to
the target's number.

**Number an equation exactly when something cites it**, and tag a statement
exactly when something cites it. `NumberTaggedFormulas` promotes only tagged
formulas to `DisplayFormulaNumbered`; an untagged display equation prints
without a number, which is right.

**Prefix the tags** — `Def:`, `Eq:`, `Lem:`, `Prop:`, `Sec:`, `Ex:` — as the
model paper does. It keeps them apart from bib keys, which carry no prefix.

Two shapes the front end will not resolve:

- **A citation must be inline `TextData`, never `BoxData`** —
  `Cell[ BoxData[ button ], "Text" ]` renders in the code face.
- **A compound citation is one button per key**, with literal separators
  between them; one button carrying several keys navigates nowhere.

## Graphics

The notebook is mostly pictures. Never end a cell with a bare number, a boolean
list, or a textual table:

- a quantity over a family → a plot;
- behaviour against a parameter → a curve;
- results over many objects → `ArrayPlot` or a row of highlighted graphs, in
  pastel colors;
- a counterexample → the object drawn with the violating part highlighted.

A short symbolic result may stand alone when that value is the point.

Every graphic is bare (§ *No decoration*).

## Initialization

Last in the document, folded: paclet loads,
``Needs[ "WolframInstitute`MathNotebook`" ]``, `SeedRandom`, a reproducibility
line (paclet version, git commit, date), and the example objects the Examples
use, copied verbatim from the project's example module so the notebook is
self-contained. Add one Text cell noting that the stylesheet can be swapped from
the MathNotebook palette (§ *The stylesheet*).

**Initialization can sit at the bottom because the outputs are embedded.**
Nothing above it needs evaluating to be read. An `InitializationCell` evaluates
on open wherever it sits, so a reader who does want to compute is served too.

## TeX in the sources — engine-dependent — Critical

**Which rule applies depends on which parser ran.** Settle the engine first
(§ *Pipeline*).

### Rich mode (the normal path)

`$…$` and `$$…$$` are the preferred form: the TeX parser produces real typeset
boxes, `$…$` becomes a nested `InlineFormula`, `$$…$$` a `DisplayFormula`, and
`=` survives.

Three losses, measured at the pinned SHA:

- **`\to` and `\mapsto` are silently dropped** — they become an empty string, so
  `$f : V(G) \to \mathbb{R}^3$` typesets with nothing between `V(G)` and `ℝ³`.
  Write `\rightarrow` / `\longrightarrow` / `\hookrightarrow`, or paste the
  Unicode (`$a ↦ b$` works). `\Rightarrow`, `\circ`, `\times`, `\subset`,
  `\in`, `\leq`, `\neq` are fine.
- **`\tag{…}` is not understood** — it renders literally. Numbering comes from
  `CellTags` (§ *Referencing*).
- **A `wolfram` fence starting with `FormBox[…]` stays an `Input` cell**
  showing the literal source. That convention is built-in-only.

### Built-in fallback (no clone present)

The Markdown importer **silently drops `=` and `\to`** inside `$…$`
(`$X + Y = Y + X$` imports as "X + Y Y + X"). Relations like ≤ ≥ ∼ ⊂ ∈
survive, which makes the failure easy to miss.

- In Text cells write **plain Unicode**: `X + Y = Y + X`, `d(u, v) ≤ k`,
  `f : V(G) → ℝ³`, `D₂∘D₁`, `ℤ₈ × ℤ₈`.
- For display math use a `wolfram` fence whose content starts with `FormBox[…]`.
- Never use `$…$` or `$$…$$` on this path.

## Pipeline — Critical

The source of truth is `NotebooksLLM/<Topic>.md`.
Conversion is a **two-half pipeline**, both halves load-bearing:
`WolframInstitute/MarkdownToNotebook` parses the Markdown, then
`scripts/mathnotebook_post.wl` applies the environments, the numbering and the
citations. The generated `.nb` sits beside the source, gitignored.

The parser half is the **rich engine** documented in
[new-notebook](../new-notebook/SKILL.md) *Conversion engine — built-in vs rich*:
the pinned local clone, `Template: Default`, `"Evaluate" -> False`. A research
source always carries frontmatter and LaTeX math, so rich mode is always
selected; the built-in importer is the fallback when the clone is absent, and it
changes what you may write (§ *TeX in the sources*).
The backtick-escaping and init-cell-marking rules from `new-notebook` apply;
`boxifyInputCells` and the heading shift do **not** — rich mode drops both.

**Never write `::: theorem` or `::: proof` divs.** The converter's fenced-div
environments exist only under `Template: Chapter`; under `Default` they are
**silently dropped entirely** — no cells, no message. Use the bold markers:
`**Definition.**`, `**Claim.**`, `**Proof.**`, `**Remark.**`, and
`ConvertEnvironmentCells` strips the marker and applies the style.

### Frontmatter and the head

```markdown
---
notebook: Curvature
title: Ollivier curvature on graphs
author: Pavel Hajek, Claude <model name>
---
```

Rich mode consumes the frontmatter as metadata, so there is nothing to strip;
the built-in importer does not, and leaves it as a literal Text cell above the
Title. Either way the keys are metadata — the `Default` template emits no
`Author` cell, so the generator inserts one from `author:`. Credit the human
first and the model by name.

The notebook opens with `[ LLM Generated ]` (the very first cell, `Author`
style), then `Title`, `Author`, `Abstract`.

### Generation is one-way; the fingerprint guards the .nb

**The `.md` → `.nb` direction is the only transfer** — there is no reverse
direction in either engine ([fingerprint.md](fingerprint.md) § *Why there is no
reverse direction*).

So: **the user reads the `.nb` and edits the `.md`.** That is only honest if the
`.md` is readable, which is a live constraint on how you write it and a further
reason rich mode matters. Say this to the user the first time a notebook is
generated: point at the `.md`, and say the `.nb` is a build product.

**Never assume they obeyed.** The build stamps a per-cell fingerprint and every
regeneration checks it first; if any cell was added, deleted or edited in the
`.nb`, **the build stops** and the drift goes to the user — the
[revise](../revise/SKILL.md) loop: transcribe into the `.md` or discard, never
regenerate over it. Procedure in [fingerprint.md](fingerprint.md).

## The conversion call

Call the **pinned local clone**, never the deployed resource function: the
deployed copy is unversioned (`ResourceObject[ url ][ "Version" ]` is `None`),
so drift is undetectable. Do not vendor the repo (~13 MB) and **never clone it
silently**; if it is absent, take the built-in fallback and say so. The pin and
the recovery command are in `Wiki/Resources/MarkdownToNotebook.md`.

```wolfram
Module[ { wl, nb, cells },

  wl = "MarkdownToNotebook/MarkdownToNotebook.wl";   (* pinned clone, project root *)

  Get[ wl ];
  nb    = MarkdownToNotebook[ "NotebooksLLM/<Topic>.md", "Evaluate" -> False ];
  cells = First[ nb ];

  (* the converter stamps In[n]:= even under "Evaluate" -> False *)
  cells = cells /. Cell[ c_, s_String, o___ ] :>
    Cell[ c, s, Sequence @@ DeleteCases[ { o }, CellLabel -> _ ] ];

  cells = researchHead[ cells ];   (* Author cell from frontmatter, [ LLM Generated ] line *)
  cells = readTags[ cells ];       (* strip every {#Tag}, attach it as CellTags *)
  cells = foldExamples[ cells ];   (* each Input/Output pair into CellGroupData[ { … }, {2} ] *)
  cells = withCellIDs[ cells ];    (* CreateCellID does not stamp built cells *)

  MathNotebookDocument[ cells, bibTags, CreateCellID -> True ]
]
```

`readTags` is the one pass this skill owns. Walking the flat cell list, for a
cell whose content is a `String` or a `TextData`:

- a trailing `{#Tag}` in any cell — a marker cell, a heading, a paragraph →
  strip it and add `CellTags -> "Tag"` to that cell;
- a cell whose whole content is `{#Tag}` → delete the cell and add
  `CellTags -> "Tag"` to the `DisplayFormula` cell **above** it.

`CellTags` on a marker cell survive `ConvertEnvironmentCells`, which carries
`opts___` through — so tagging before `MathNotebookDocument` is correct, and
tagging after would be too late for `ConvertCitations`.

**Tag before you fold.** `readTags` walks at level `{1}`, so it must run
*before* `foldExamples` builds the `CellGroupData`; a cell already inside a
group is invisible to it. `withCellIDs` runs after and must recurse into groups.
The passes inside `MathNotebookDocument` recurse on their own (`mapCellList`);
this ordering is the generator's constraint, not theirs.

Check the round trip once per source: if any `{#Tag}` survives into the `.nb` as
visible text, the converter mangled it — fall back to an ordered list of tags
applied to the `DisplayFormula` and environment cells in document order, and say
so.

Then write the notebook, re-import it, and stamp the fingerprint — see
[fingerprint.md](fingerprint.md) for why the fingerprint must come from the
round-tripped cells.

Four things this shape gets right:

- **No heading shift and no `boxifyInputCells`** — `##` is already `"Section"`
  and the boxes arrive structural. Both `new-notebook` workarounds must be off.
- **`MathNotebookDocument` last**, and it owns `StyleDefinitions`: it replaces
  the converter's `"Default.nb"` with the *embedded* sheet named by
  `$MathNotebookStyleSheetName`, which this skill sets to `PlainArticle.nb`.
  Pass notebook options through it rather than rebuilding the `Notebook` — with
  prompt tracking on, that includes `TaggingRules -> { "Provenance" -> prov }`;
  the fingerprint stamp later merges its `"ResearchNotebook"` key alongside.
- **`ReplacePart` is not needed here** (unlike `new-notebook`) precisely because
  `MathNotebookDocument` rebuilds the notebook with the options given.
- `ensureParser[ ]` installs `Wolfram/Parser` on first call, so a fresh machine
  does network I/O and, on failure, degrades silently to
  `ImportString[ …, "TeX" ]` with worse math fidelity. Probe
  `PacletFind[ "Wolfram/Parser" ]` and surface the degradation.

## The stylesheet — Critical

**Embed `PlainArticle.nb`.** It is `Default.nb`'s typography with the paper's
structure added: 25 style cells against `AMSArticle`'s 34, every explicit
`FontSize` and `FontFamily` dropped, and six styles left to `Default.nb` —
`Title`, `Text`, `Author` and the three `DisplayFormula` styles. What it does
declare is what the document needs to be a document: the twelve environments,
`Proof`, `Caption`, `Date`, `Reference`, `Hyperlink`/`Citation`/`URL`, and for
the sectioning levels and `Abstract` only the number or word that prints.

The result reads as a stock Wolfram notebook — no color change, no font change,
numbering and labels intact.

**Plain `Default.nb` is not an alternative.** Under it a reference to a
definition renders **`2.0`** — the section counter increments and the theorem
counter never does. `PlainArticle` is the minimum sheet that keeps numbering
alive.

Install and mechanics: [mathnotebook.md](mathnotebook.md).

Numbering facts to write against:

- **Statement numbers are per-section**, `⟨section⟩.⟨n⟩`, shared across all
  twelve environments — a Claim then its Example in section 3 are 3.1 and 3.2.
  `ComplexSystems` alone gives each environment its own counter.
- **Equation numbers are document-global**, `(n)`; `Section` does not reset them.
- The Plain class (`Theorem`, `Lemma`, `Proposition`, `Corollary`,
  `Conjecture`, `Claim`) **italicises the body** — the amsthm convention. The
  Definition class is roman.
- **One open defect:** `PlainArticle`'s `DisplayFormula` is left-flush where the
  journal templates centre theirs, so an equation inside an environment body
  sits 64 pt left of the block's prose (MathNotebook `EnvironmentBlocks` T3,
  open at 0.1.20).

### Swapping the sheet is the reader's move, not the build's

The MathNotebook palette's **Apply stylesheet** menu offers `AMSArticle`,
`ArXivArticle`, `RevTeXAPS`, `SpringerJournal`, `ComplexSystems` and Default.
Mention this in Initialization; do not do it in the build. Two reasons the build
always ships `PlainArticle` embedded:

- **A palette swap sets the sheet by name**, replacing the embedded definitions
  with a path into a paclet layer on the author's disk. A cloud reader without
  the paclet then gets **zero** style definitions — no counters, and no labels
  either, because the label *is* the `CellDingbat` the sheet supplies.
- **By-name resolution is not measured to work here.** The paclet's own record
  (`BasicFunctionality` T4) has all six sheets falling back to `Default.nb` for
  a locally installed copy — Title 45 where the embedded `Get` gives 26 —
  before a menu reset, after `ResetMenusPacket`, and with the front end freshly
  launched. It worked for a cloud-installed copy. Treat the swap as a documented
  author action, not a verified one.

Use `Author` for the `[ LLM Generated ]` line. `Subtitle` resolves under
`PlainArticle` but `AMSArticle` declares no `Subtitle`, so a line written in it
loses its typography on a swap. `Author` survives every swap.

## References

MathNotebook's bibliography engine is reachable only from
`ImportLaTeXDocument`, so on the Markdown path the References section is the
generator's to build. `scripts/mathnotebook_post.wl` does it:

- `BibTeXReferences[ file ]` parses a `.bib` into `<| tag -> formatted |>`.
  There is no `Import[ …, "BibTeX" ]` in Wolfram, so this is a small hand
  parser; it handles the shapes `cite` emits — braced fields, quoted fields, and
  the bare numeric `year = 2011` that Crossref returns — and links
  `doi` → `doi.org`, else `eprint` → `arxiv.org`, else `url`.
- `ReferenceCells[ entries ]` emits `Reference` cells tagged with the key and
  labelled `[tag]` in the margin.
- `ConvertCitations[ cells, bibTags ]` turns `[tag]` in prose into a button
  (§ *Referencing*). Only tags that exist are converted — the cells' `CellTags`
  plus the bib keys passed in; ordinary bracketed prose and Markdown links are
  left alone.

Keep bib keys **under about 25 characters**: the `Reference` gutter is 205 pt
with `ParagraphIndent -> -24` in all seven sheets, sized against a 26-character
key with 15 pt clearance.

A `Reference` cell needs **both** `CellTags -> key` and the `[key]` dingbat
(`CellDingbat -> Cell[TextData["[key]"]]`, `ParagraphIndent -> 0`), or it prints
unlabelled and indented into an empty gutter. `ReferenceCells` writes both;
`LabelReferences[ ]` repairs a notebook that lacks them, in place, without
disturbing `CellID`s.

The References heading is a suppressed `Section` cell needing
`CounterIncrements -> { }`, `CellDingbat -> None` **and**
`TaggingRules -> <| "MathNotebook" -> <| "Suppressed" -> "True" |> |>`; with only
the first it prints as a numbered section.

## Tables

The converter's `2ColumnTableMod` / `TableText` / `ModInfo` styles are declared
in no sheet, so a Markdown pipe table renders as plain monospace with no rules.
Write a weight-bearing table as a `Grid` in a `wolfram` fence; keep pipe tables
for throwaway comparisons.

## Checklist

**The mathematics**

- [ ] Reads as a paper: mathematical section titles, sections in the order the mathematics needs, nothing used before it is defined.
- [ ] Introduction states every result as a numbered statement saying where it is proved.
- [ ] Abstract 2–4 sentences of results, written last.
- [ ] No Definitions / Claims / Questions template sections, no Symbols index, no per-function demonstration sections.
- [ ] Every sentence states a mathematical fact; facts that can be equations are equations; one statement per sentence.
- [ ] Mathematics-paper language: none of census, sweep, battery, witness, bar, workhorse, verdict, audit, harvest; no selling adjectives.
- [ ] Commentary in a `Remark` or `Observation`, not loose prose.
- [ ] Definitions Lean-translatable: explicit hypotheses and quantifiers, no appeal to pictures, one object each; the computing symbol named in one sentence after, not inside.
- [ ] `Claim` is the default; `Theorem` only for something big and proved or cited; `Lemma` only immediately before a `Theorem`.
- [ ] Every claim and conjecture states its own range of verification, with the numbers in it; a failed conjecture becomes a `Question` with the smallest counterexample drawn.
- [ ] Proofs step by step, one step per sentence, every step naming the definition, equation or result it uses; algebra displayed; no sketches; about ten steps maximum.

**Examples**

- [ ] Every definition is followed by an `Example` **environment cell**, with nothing between them.
- [ ] Example code is 3–10 readable lines a reader can copy and change one argument in; it builds what it needs in a line or uses an Initialization object.
- [ ] One bare graphic per Example: no `PlotLabel`, legend, frame, `Style`, `Labeled`, or restating annotation; a `Caption` cell only where the picture is otherwise unreadable.
- [ ] The object is the smallest one in which the phenomenon appears.
- [ ] **Code folded, graphic not**: `Cell[CellGroupData[{Input, Output}, {2}]]` — never `Closed`, never `Open`. One Output per Input. `Input` cells carry real code, not `ToBoxes` of a string.

**Numbering and references**

- [ ] No number typed into the source anywhere.
- [ ] Tags written `{#Tag}` at the end of the statement or heading, or on the line after the display equation; prefixed `Def:`, `Eq:`, `Lem:`, `Sec:`.
- [ ] Cited as a bare `[Tag]` — never `Definition [Def:X]`, since the rendered form already carries the word.
- [ ] An equation is numbered exactly when it is cited; a statement is tagged exactly when it is cited.
- [ ] `readTags` runs **before** `foldExamples` and before `MathNotebookDocument`; `withCellIDs` recurses into groups; no `{#Tag}` survives into the `.nb` as visible text.
- [ ] Citations inline `TextData`, one button per key; references built with `BibTeXReferences` + `ReferenceCells`; bib keys under ~25 characters; every `Reference` cell carries `CellTags` **and** its `[key]` dingbat; References heading suppressed with all three options.

**Build**

- [ ] `.md` source in `NotebooksLLM/`, readable enough to edit while reading the `.nb`; the user told which file to edit.
- [ ] Drift checked before every regeneration; any user edit in the `.nb` stops the build and goes to the user.
- [ ] Rich engine at the pinned clone (`Template: Default`, `"Evaluate" -> False`), `CellLabel` stripped; built-in fallback only if the clone is absent, and said out loud.
- [ ] No `::: theorem` / `::: proof` divs — silently dropped under `Default`.
- [ ] Rich mode: no `\to` or `\mapsto` (silently empty), no `\tag{…}`. Built-in fallback: plain Unicode in Text, `FormBox` fences for display math.
- [ ] Multi-cell environment bodies continue in the **same style** with `CellDingbat -> None` and `CounterIncrements -> { }` — never a `Text` cell.
- [ ] Weight-bearing tables as a `Grid` in a `wolfram` fence.
- [ ] `PlainArticle.nb` **embedded**, not referenced; palette swap documented in Initialization, never done in the build.
- [ ] `author:` rendered as an Author cell; `[ LLM Generated ]` line above Title / Author / Abstract, in `Author` style.
- [ ] Initialization last and folded: paclet loads, seed, reproducibility line, example objects, stylesheet-swap note.
- [ ] `CellID`s assigned by the generator; fingerprint computed **after** the export/re-import round trip and **merged** into `TaggingRules` (`stampTaggingRule`) — a `"Provenance"` key may already be there.
- [ ] Zero-message evaluation; Output cells embedded (graphics live, not rasterized); `ExportString` result checked with `StringQ` and the file re-imported.
- [ ] Deployed public; README `Research Notebooks` table updated.

## Integration with other skills

- `new-notebook` supplies the base pipeline conventions (backtick escaping, init-cell marking, engine selection) and owns every per-function demonstration notebook; this skill layers the rich engine + MathNotebook post-processing on top.
- `cite` produces the bibliography entries; `lean` consumes the Lean-translatable statements; `provenance` stamps the `"Provenance"` key when its toggle is on.
- `update-wiki` / `journal` receive the open questions after publishing.

## When NOT to use

- A demo, tour, or exploration notebook, or a per-function walkthrough — that is `new-notebook` (or `start-tour`).
- The user edited the generated `.nb` and the drift is unresolved — the build stays stopped until they decide.
