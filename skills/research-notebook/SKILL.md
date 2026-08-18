---
name: research-notebook
description: >
  Write a mathematics paper as a Wolfram notebook, optimised for a human who
  wants to check it. Sections run in the order the mathematics needs, and the
  body carries only settled statements — proved here in full, or cited to a
  source that was read. Experiments (enumeration ranges, sweeps, distributions,
  timings) are gathered near the end rather than in the development; hedged
  claims, heuristics and failed attempts go to the journal, never the paper. Each
  result is stated at the generality its proof actually reaches. Proofs are
  complete prose with no gaps and no step left to the reader, never abbreviated
  to fit and never shattered into a chain of tiny lemmas. One example per result,
  not one per definition, answering with a geometry illustration or one small
  algebraic value. Statements, equations and
  sections are numbered by the front end and cited by tag, never by a number
  typed into the source. The author is the model plus the date, with the
  operator, a one-sentence summary of the instructions, and — set in bold — how
  much freedom the model had (Directed, Guided, or Open exploration) in a
  footnote. Converts a Markdown source
  with the MarkdownToNotebook parser, then applies the MathNotebook environments
  on the PlainArticle stylesheet, so statements translate directly to Lean and
  the page looks like a stock notebook. Generated one-way from the Markdown the
  user edits; a per-cell fingerprint stops the build rather than overwrite an
  edit made in the .nb. Use when the user says "research notebook", "notebook
  with conjectures", "research document on X", "write up the research on X", or
  the /research-notebook command.
---

# Research Notebook

A research notebook is **a mathematics paper that computes**.

The model is an `amsart` paper: numbered definitions and results, numbered equations, cross-references by number, complete proofs.
The one thing a paper on paper cannot do is run, so the results that need a picture get one.

**The reader is a human checking the mathematics.**
That is the whole design constraint, and [style.md](style.md) is where it turns into rules.

| Skill | Produces |
|-------|----------|
| `new-notebook` | generic Markdown → `.nb` pipeline (this skill builds on it), and every per-function demonstration |
| `research-notebook` | a paper: settled results with complete proofs, experiments quarantined, everything numbered by the front end |

The reference for tone, structure and proof style is the author's own paper at
`~/Library/CloudStorage/OneDrive-Personal/Math/articles/FINISHED/hodgepaper/hodgepaper.tex`.
Read a section of it when the voice is unclear.

## Read these

[style.md](style.md) is **not optional** — it carries the tier rules, the length budgets and the proof rules, and it is shared with [scaffold-paper](../scaffold-paper/SKILL.md) so a paper reads the same whether it ships as `.nb`, LaTeX or Typst.

The other four are read on demand, only what the current step needs:

- [build.md](build.md) — the pipeline, what you may write in the source, the conversion call, the stylesheet, the references
- [fingerprint.md](fingerprint.md) — drift detection: stamping, checking, and why no `.nb` → `.md` direction exists
- [mathnotebook.md](mathnotebook.md) — MathNotebook install, stylesheet embedding, environment mechanics
- [output-embedding.md](output-embedding.md) — evaluating Input cells and embedding Output cells headless

## Steps

1. Write or update `NotebooksLLM/<Topic>.md` in paper order (§ *Structure*), following [style.md](style.md) throughout.
2. **Sort by tier before writing a line of it** ([style.md](style.md) § *The four tiers*). What is settled goes in the body; experiments to *Ruliology*; everything else to the [journal](../journal/SKILL.md), with one line saying why.
3. If a generated `.nb` exists, run the drift check first ([fingerprint.md](fingerprint.md)); stop on any drift.
4. Convert ([build.md](build.md)), evaluate and embed outputs ([output-embedding.md](output-embedding.md)), stamp the fingerprint.
5. **Smoke test**: every Input cell evaluates through the Wolfram MCP (license-aware — see [new-notebook](../new-notebook/SKILL.md) *Kernel execution*) with **zero messages**.
6. **Deploy** to the Wolfram Cloud, public, stable object name `<Project>/<Topic>.nb` (matching `scripts/publish_notebooks.wls`).
7. **Link from the repo README** in a `## 📓 Research Notebooks` section — a table `| Notebook | Description | Link |`, one row per notebook, the link anchored on "Wolfram Cloud". Create the section if missing; update the row in place if the notebook already has one.
8. Hand the open questions and everything cut in step 2 to the journal (or the Wiki when the journal is off).
9. If prompt tracking is on (`Prompt tracking: **on**` in `CLAUDE.md` — see [provenance](../provenance/SKILL.md)), the provenance comment belongs in the `.md` **before** the build; append the ledger entry to `Wiki/Prompts.md` here.

## Structure — an ordinary paper

**There is no fixed section order, and no section list to satisfy.**
The document is organised the way the mathematics is organised.
Sections carry mathematical titles ("Hodge decompositions", "Curvature on trees"), never structural ones ("Definitions", "Claims", "Results"), and a section exists because there is mathematics in it.

Three things a paper does need:

- a **head** — `[ LLM Generated ]`, `Title`, the model as `Author`, the date, the footnote naming the operator with the **bold freedom level** and a one-sentence prompt summary ([style.md](style.md) § *Authorship*), and an `Abstract`;
- an **introduction** that states the results, each as a numbered statement whose body says where it is proved ("this is [Prop:Extension]"), so a reader who stops there knows what the paper claims;
- the **references**, and after them `Initialization`, folded (§ *Initialization*).

Between the introduction and the references, the shape follows the mathematics.
The usual shape is sections mixing `Definition`, `Theorem`, `Lemma`, `Proof`, `Example` and `Remark`, with nothing used before it is proved, the experiments gathered near the end ([style.md](style.md) § *Ruliology*) and a short conclusion on what is open.
Every part of that is a default, not a requirement: no experiments means no such section, and a paper that ends on its last proof needs no conclusion.

What to avoid, unless the topic really wants it:

- a Definitions section, a Claims section, a Questions section — statements sit where they are used;
- a Symbols index — there is none; see [style.md](style.md) § *Notation*;
- a Conventions section, unless there really is a standing convention, and then it is a `Remark` early on;
- per-function demonstration sections — those are `new-notebook`'s.

## Statements

| Environment | Use for |
|---|---|
| `Definition` | every term the notebook uses |
| `Theorem` | a main result, proved here in full or cited |
| `Lemma` | a step toward a `Theorem`, stated immediately before it |
| `Proposition`, `Corollary` | a proved result; a consequence of the statement above |
| `Construction` | a construction the notebook reuses |
| `Example` | the computation under a result |
| `Conjecture` | a central open statement — few of them, each saying what would settle it |
| `Remark`, `Observation` | a convention, a caveat, an aside |
| `Question` | an open question |
| `Proof` | a proof — unnumbered, not citable |

**`Theorem` is the default for a result, and it has to earn it.**
A statement enters the body only when it is proved here in full or cited to a source that was read.
`Claim` is available and is deliberately *not* in the list above: a computationally-verified-but-unproved statement is not body content, and "verified by enumeration up to $n = 8$" is not a proof.
It goes to the journal, or — when the paper is about it — into the body as a `Conjecture` whose evidence sits in *Ruliology*.

A `Lemma` with no theorem after it is misfiled.
A conjecture that fails becomes a `Question`, and the smallest counterexample is kept and drawn.

**Never assert an implication you have not checked.**
Some proposed statements will be false, and finding the counterexample is the result.

Definitions are written precisely: explicit hypotheses, explicit quantifiers, quantification over decidable objects where possible, no appeal to a picture inside the statement, one object each.
That precision is what makes a later formalisation possible, but **formalising is never undertaken unasked** — the [lean](../lean/SKILL.md) skill runs only on an explicit request.

Every statement names its own hypotheses, so it can be lifted out of the document and still mean the same thing ([style.md](style.md) § *Results*).
State each result at the generality the proof actually reaches — a general theorem is the goal, and the only rule is that generality is never bought with a gap.

**One statement, one cell** ([build.md](build.md) § *One cell per statement*).

## Referencing

**Every number in the document is computed by the front end.**
A number typed into the source is a bug: a second source of truth, stale the moment a cell moves.

Four things carry numbers, and all four are cited the same way — a bracketed tag in the prose:

| Target | Source | Cited as | Renders |
|---|---|---|---|
| display equation | `$$…$$` with a tag | `[Eq:Cyclic]` | `(3)` |
| statement | environment cell with a tag | `[Def:Hodge]` | `Definition 2.1` |
| section | heading with a tag | `[Sec:Trees]` | `Section 4` |
| bibliography entry | `Paper/references.bib` key | `[Lambrechts2007]` | `[Lambrechts2007]` |

**The rendered form already contains the word.**
Write `by [Def:Hodge]`, which renders "by Definition 2.1" — never `by Definition [Def:Hodge]`.

A tag is `{#Tag}`. It sits at the **end of the first paragraph** of the statement or heading it names, or on the **line after** the display equation it names.

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

**Number an equation exactly when something cites it**, and tag a statement exactly when something cites it.
Only tagged formulas are promoted to `DisplayFormulaNumbered`; an untagged display equation prints without a number, which is right.

**Prefix the tags** — `Def:`, `Eq:`, `Lem:`, `Thm:`, `Prop:`, `Sec:`, `Ex:`.
It keeps them apart from bib keys, which carry no prefix.

Two shapes the front end will not resolve: a citation must be inline `TextData`, never `BoxData`; and a compound citation is one button per key, with literal separators between them.

## Examples and the fold

What an example *is* — one per result, a picture or one small algebraic value, three to ten lines, bare — is in [style.md](style.md) § *Examples*.
The mechanism is here.

**The fold hides the code, never the result.**
A reader scrolling the document meets statements and pictures; the code is one click away and never in the way.
That is why an example's code must be short — it is read by someone who chose to open it.

The mechanism is the group state `{2}` — a closed group displaying its **second** cell:

```wolfram
Cell[ CellGroupData[ {
  Cell[ codeString,             "Input"  ],
  Cell[ BoxData[ outputBoxes ], "Output" ] }, {2} ] ]
```

`Open` shows both, `Closed` shows the `Input` — backwards.
`{n}` is the third state: closed, displaying cell `n`.
`FoldExampleGroups` builds it ([build.md](build.md)).

Three consequences:

- **One Output per Input.** A closed group displays a single cell. Split the computation.
- **Nothing else is needed** — no `CellOpen -> False`, no `CellGrouping -> Manual`. Both were tried and are worse.
- **An `Input` cell must carry real code** — a code `String` or genuine boxes. `ToBoxes` applied to a code *string* ships a cell displaying the quoted string; the failure is silent and visible only on screen.

The `Example` environment cell is a **sibling above** the group, not its head.
It numbers on the shared counter, so it is citable as `Example 2.2`.
An `### Example` subsection is wrong on all three counts.

## Initialization

Last in the document, folded: paclet loads, ``Needs[ "WolframInstitute`MathNotebook`" ]``, `SeedRandom`, a reproducibility line (paclet version, git commit, date), and the example objects the Examples use, copied verbatim from the project's example module so the notebook is self-contained.
Add one Text cell noting that the stylesheet can be swapped from the MathNotebook palette ([build.md](build.md)).

**Initialization can sit at the bottom because the outputs are embedded.**
Nothing above it needs evaluating to be read.
An `InitializationCell` evaluates on open wherever it sits, so a reader who does want to compute is served too.

## Checklist

Run [style.md](style.md)'s checklist first — it covers tiers, budgets, proofs, examples and language.
Then these, which are this skill's own:

- [ ] Reads as a paper: mathematical section titles, sections in the order the mathematics needs, nothing used before it is defined.
- [ ] Introduction states every result as a numbered statement saying where it is proved; abstract written last.
- [ ] Body carries no `Claim`, no verification range, no experiment; the experiments sit together near the end if there are any; everything cut is in the journal.
- [ ] Definitions precise enough to formalise, though no formalisation attempted unasked; the computing symbol named in one sentence after the statement, not inside it.
- [ ] One statement per cell — no continuation cells, since Markdown cannot express one.
- [ ] No number typed into the source anywhere; tags written `{#Tag}`, prefixed, cited bare as `[Tag]`.
- [ ] An equation is numbered exactly when it is cited; a statement is tagged exactly when it is cited.
- [ ] Head is `[ LLM Generated ]`, Title, the **model** as Author, the date, and the footnote with the operator, the **bold** freedom level and the prompt summary — no human as author.
- [ ] Code folded, graphic not: `CellGroupData[{Input, Output}, {2}]` — never `Closed`, never `Open`. One Output per Input. `Input` cells carry real code.
- [ ] Initialization last and folded: paclet loads, seed, reproducibility line, example objects, stylesheet-swap note.
- [ ] Build: rich engine at the pinned clone, `CellLabel` stripped, no `::: theorem` divs, no `\to` or `\tag{…}` in rich mode, `PlainArticle.nb` embedded.
- [ ] Drift checked before every regeneration; any user edit in the `.nb` stops the build and goes to the user.
- [ ] Fingerprint computed **after** the export/re-import round trip and **merged** into `TaggingRules`.
- [ ] Zero-message evaluation; outputs embedded live, not rasterized; `ExportString` result checked with `StringQ` and the file re-imported.
- [ ] Deployed public; README `Research Notebooks` table updated.

## Integration with other skills

- `new-notebook` supplies the base pipeline conventions (backtick escaping, init-cell marking, engine selection) and owns every per-function demonstration notebook; this skill layers the rich engine + MathNotebook post-processing on top.
- `scaffold-paper` shares [style.md](style.md), so a LaTeX or Typst paper reads the same as a notebook one.
- `journal` is where everything below the settled tier goes — it is part of the workflow, not an optional extra.
- `cite` produces the bibliography entries; `provenance` stamps the `"Provenance"` key when its toggle is on; `lean` can pick up the statements, but only when the operator asks for a formalisation.

## When NOT to use

- A demo, tour, or exploration notebook, or a per-function walkthrough — that is `new-notebook` (or `start-tour`).
- A running record of what was tried — that is the `journal`.
- The user edited the generated `.nb` and the drift is unresolved — the build stays stopped until they decide.
