---
name: new-paper
description: >
  Add a paper to Research/ — a LaTeX (amsart, biblatex) or Typst source from the
  template, sharing the folder's preamble — then act as an editor on the
  user-owned document. Research/ holds the papers beside the research notebooks
  and notes; when a paper is already there, ask whether the new one joins it or
  gets its own subfolder. A project that already has a Paper/ folder keeps using
  it. Prose written into the paper follows the shared writing guide in
  new-research-notebook/style.md: settled statements only, experiments in a
  Ruliology section, complete proofs, short sentences, each result stated at the
  generality its proof reaches, and the model as sole author with a footnote
  naming the operator and disclosing in bold how much freedom the model had. Use when the user
  says "scaffold paper", "add paper", "create paper folder", "set up latex",
  "set up typst", or during new-project when the user wants a paper. Trigger on:
  "paper setup", "latex template", "typst template", "I want to write a
  paper".
---

# New Paper

Add a typeset article to `Research/`, then help the user *edit* it.
`Research/` accumulates papers, research notebooks and notes over a project's life; this skill adds a paper and never disturbs another document.
A project that already has a `Paper/` folder keeps it: the paper is added there, and the skill tells the user that `Research/` is the new place and that nothing is moved.
Two formats:

- **LaTeX** (default) — amsart document class, biblatex with biber, shared `macros.sty`.
- **Typst** — a `.typ` source importing a shared `macros.typ`, native `bibliography()`.

The paper is the **user's document**.
This skill scaffolds the structure and then acts as an *editor*, not an author (see Rules below).

## Style — read this before writing any prose

**[new-research-notebook/style.md](../new-research-notebook/style.md) is the writing guide, and it is canonical here.**
It is shared so a paper reads the same whether it ships as LaTeX, Typst or a notebook.

The four things it decides that this skill cannot:

- **Tiers.** The paper carries only settled statements — proved in full, or cited to a source that was read. Experiments (enumeration ranges, sweeps, distributions, timings) are gathered near the end, usually a `Ruliology` section — if there are none, there is no such section. Hedged claims, heuristics, alternate proofs and failed attempts go to the [journal](../journal/SKILL.md), never the paper. Nothing is silently dropped — and with the journal off, nothing is silently cut either: the list goes to the operator when the material is set aside, not at the end ([style.md](../new-research-notebook/style.md) § *When the journal is off*).
- **Length.** Abstract ≤ 4 sentences. Introduction 3 paragraphs of ≤ 6 sentences. No prose paragraph over 6 sentences and never two in a row — the abstract, the introduction and the *Ruliology* entries are prose by construction and exempt. Connecting sentences ≤ 25 words; a proof deduction and an abstract sentence are not word-capped.
- **Proofs.** Complete prose, one deduction per sentence, each naming what it uses through `\cref`. No *clearly*, *one easily sees*, *we omit the details*, no proof sketches. A long proof is fine when it reads clearly — never abbreviate to fit, and never break an argument into a chain of one-line lemmas. The 8-sentence trigger counts one run of deductions, so a two-part proof is counted part by part.
- **Authorship.** `\author` is the **model**; `\date` is the date the document was generated, written out and never `\today`; the `\thanks` footnote (Typst: a small block under the model line) names the operator, sets the freedom level in `\textbf` — Directed, Guided or Open exploration — and summarises the instructions in one sentence. `[[ LLM Generated ]]` is the first line of the title, since amsart has no slot for it. The template ships all of this already.
- **Results.** State each result at the generality the proof actually reaches — a general theorem is the goal, and the only rule is that generality is never bought with a gap. Every statement names its own hypotheses and survives being lifted out of the document. Nothing is used before it is proved. Every conjecture says what would settle it. A short paper is fine.
- **Formalisation** is never undertaken unasked; `\cref`-able precise statements are always worth writing, a Lean development only on an explicit request.

`macros.sty` / `macros.typ` is where every nontrivial symbol gets a macro, defined once.
That rule is the LaTeX half of style.md § *Notation*, and the namespace is already occupied at many obvious names (`\mid`, `\d`), so take the shortest free name rather than redefining an existing command.

Three things a typeset paper has to do that a notebook does not, all of them measured on [the first paper written under the guide](../../Wiki/Concepts/PaperStyleExercise.md#four-findings-the-latex-path-exposed-on-its-own):

- **An Example's picture is a file.** The code does not evaluate, so the Example carries the call *and* a graphic exported from exactly that call. No `figure`, no `\caption` — that numbers and labels the picture, which § *Examples* bans — so a centred non-floating box, bound to the call inside one `minipage` or the picture floats away from the Example that owns it.
- **Code is wrapped by the column, not by the source.** The ten-line example budget counts rendered lines; wrap a long call to the text width by hand before counting it.
- **The code behind the *Ruliology* calls goes in an appendix**, named once from *Ruliology*. A notebook hides it in *Initialization*; LaTeX has no such section, and left inline it buries the one-line calls the section exists to carry.

## When to use

- The user says "new paper", "add a paper", "scaffold paper", "set up latex", "set up typst", "I want to write a paper".
- During `new-project` when the questionnaire's *Include a paper?* is yes.

## What you need

1. **Project directory** — whose `Research/` holds the paper, or gets it.
   Usually the project root.
2. **Name** — `CapitalizedWords` for the paper, which becomes its filename.
   Only the first paper in a `Research/` without one may go unnamed, as `main`.
3. **Format** — LaTeX (default) or Typst.
   Pass `--typst` if the user wants Typst, or they say "typst".
4. **Title** (optional) — working title.
   Default: the name.
5. **Operator** (optional) — the person running the session; defaults from git config.
   Not the author: the author is the model (§ *Style*).
6. **Model, freedom level and prompt summary** — your own name and identifier, one of Directed / Guided / Open exploration, and one sentence on the instructions you worked under.

If invoked from new-project, these are already known.

## Steps

### 0. If `Research/` already holds a paper, ask

A second paper can sit either way, and the choice is the user's — **ask, do not guess**:

- **Beside the others** (default) — `Research/<Name>.tex`, sharing `Research/macros.sty` and `Research/references.bib`. One preamble, one bibliography, every paper in the project drawing on both.
- **Its own subfolder** (`--subfolder`) — `Research/<Name>/<Name>.tex`, with its own macros and bibliography. Self-contained, and handed to a co-author or a journal as a directory.

A `Research/` without a paper needs no question: scaffold it and name the paper.

### 1. Run the scaffold script

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paper.sh" [--typst] [--name <Name>] [--subfolder] [--force] "<ProjectDir>" "<Title>" "<Operator>" "<email>" "<Model>" "<Freedom>" "<Prompt>" "<Date>"
```

`<Name>` is `CapitalizedWords` naming the paper, and it becomes the filename; leave it off for the first paper and the source is `main.tex`.
`<Operator>` is the person running the session and `<Model>` is you, by name and exact identifier.
`<Freedom>` is one of `Directed`, `Guided`, `Open exploration` — it prints **bold** in the footnote, and between two labels you take the more open one.
`<Prompt>` is one sentence summarising the instructions you actually worked under, including what was left unspecified.
`<Date>` defaults to today and is baked into the document, since `\today` re-dates the paper on every compile.

**The script refuses to overwrite an existing source file** — that target is often a paper someone is writing.
Give a different `--name` rather than reaching for `--force`.
A `macros.sty` or `references.bib` already in the folder is reused untouched, so a new paper joins the existing ones instead of replacing their preamble.

If the project has a `Paper/` folder, the script uses it instead and says so; tell the user that `Research/` is the new place for papers.
Nothing is moved.

LaTeX creates:
```
Research/
├── <Name>.tex         — article (amsart + \usepackage{macros})
├── macros.sty         — shared preamble, theorem envs, macros    (written once)
├── references.bib     — bibliography (biblatex format)           (written once)
├── figures/           — for TikZ exports and plots
└── .latexmkrc         — latexmk config (pdflatex + biber)
```

Typst (`--typst`) creates:
```
Research/
├── <Name>.typ         — document (#import "macros.typ": *)
├── macros.typ         — shared preamble, math shorthand, theorem envs
├── references.bib     — bibliography (read natively by Typst)
└── figures/           — for plots and images
```

The paper is **not** an artifact and does not go in `Artifacts/`: it is a document in progress, the user's from the moment it is scaffolded, and lives in `Research/` itself; this skill edits it on request ([artifacts.md](../new-notebook/artifacts.md) § *Papers*).

### 2. Seed references from existing resources

If `Wiki/Resources/` exists and contains paper articles, extract BibTeX entries and add them to `references.bib`.
Use arXiv MCP or crossref MCP to fetch proper biblatex/BibTeX entries for each paper.
Both formats read `references.bib`.

### 3. Update .gitignore

Add build artifact patterns, unless the project's `.gitignore` already lists them.
LaTeX; the `**` covers a paper in a subfolder as well as one at the top level of `Research/`:

```
Research/**/*.aux
Research/**/*.bbl
Research/**/*.bcf
Research/**/*.blg
Research/**/*.fdb_latexmk
Research/**/*.fls
Research/**/*.log
Research/**/*.out
Research/**/*.run.xml
Research/**/*.synctex.gz
Research/**/*.toc
Research/**/*.pdf
```

Typst produces only `Research/**/*.pdf`.
For a paper in an existing `Paper/`, use `Paper/` in the patterns; if that folder is already gitignored entirely, no action needed.

## Template contents

### macros.sty (LaTeX)

Shared preamble loaded by every paper in the folder:

- **Fonts**: newpxtext + newpxmath (Palatino), microtype
- **Math**: amsthm, amsmath, amssymb, mathtools, mathrsfs
- **Graphics**: tikz, tikz-cd, subcaption
- **Bibliography**: biblatex with biber (alphabetic style) — `\printbibliography` ships commented out, since a self-contained paper prints no empty References section; `\tableofcontents` likewise
- **References**: cleveref (nameinlink, capitalize, **nosort**)
- **Theorem environments**: theorem, corollary, proposition, lemma, conjecture, claim, definition, example, construction, remark, question, observation — one shared counter, but each on its **own counter name** through `aliascnt`
- **Code**: a `wolfram` listings environment, wrapped at the column with a continuation arrow
- **Operators**: dist, diam, Aut, End, Hom
- **Shorthand**: \NN, \ZZ, \QQ, \RR, \CC, \FF, \GG, \VV, \EE

### macros.typ (Typst)

Shared preamble applied with `#show: macros`.
Mirrors the LaTeX setup: page/font style, the same math shorthand (`NN`, `ZZ`, …), the same operators, and dependency-free counter-based theorem blocks (`theorem`, `lemma`, `definition`, …) so the first compile needs no network.
A comment points to `@preview/ctheorems` for richer numbering.

Extend macros.sty / macros.typ freely as the project needs.

**Do not collapse the theorem environments back onto one `\newtheorem[theorem]`.**
cleveref names a reference from its counter, so a shared counter makes every `\cref` print "Theorem" — a definition cited as "by Theorem 2.4" tells the reader the wrong kind of thing is being invoked.
`aliascnt` gives each environment its own counter name and keeps the shared numbering, and `nosort` is the other half of the fix: with aliased counters, cleveref's range compression silently **drops** entries from a multi-reference list, with no warning in the log.
Measured on both halves — [the evidence](../../Wiki/Concepts/PaperStyleExercise.md#the-build-path--six-defects-in-the-shipped-template), and a five-label `\cref` re-checked against the corrected template on 2026-08-20.

### Compiling

```bash
cd Research && latexmk -pdf <Name>.tex   # LaTeX
cd Research && typst compile <Name>.typ  # Typst (typst watch for live preview)
```

## Rules for LLM

This skill **scaffolds and edits**; it does not write the paper.

- **The paper source is the user's writing space** — it sits in `Research/` itself, outside every `Artifacts/` folder, which is exactly what makes it protected content in the [revise](../revise/SKILL.md) § *Protected content* sense: never author or overwrite it unprompted.
- Act as an **editor on request**:
  - Import material at a specified location ("put the lemma after Section 2").
  - Correct or rewrite a paragraph the user points to.
  - Add figures (TikZ / `figures/` images), code listings, tables.
  - Keep notation consistent with macros.sty / macros.typ.
- **macros.sty / macros.typ** can be extended freely — add macros, operators, theorem environments as needed.
- **references.bib** — add entries when papers are downloaded or cited.
- When you do add prose at the user's request, write in the user's voice and to [style.md](../new-research-notebook/style.md).
- **Move, do not drop.** Material that fails the settled tier goes to the [journal](../journal/SKILL.md) with one line saying why — never deleted, never left hedged in the paper.
  With the journal off, stop when the material is set aside — not at the end — and put the list to the operator: turn the journal on, keep it in a marked retained block, or drop it explicitly ([style.md](../new-research-notebook/style.md) § *When the journal is off*).
  A retained block has a fixed form there; on a typeset path it is a terminal section of `remark` environments, each opening `[ Retained — no journal ]`, and it is the one place a `[lookup]` may stand.
  Unattended, keep it and write the list into the item's `## Hand-off` — the session cannot write the run digest, and `## Hand-off` is what the digest quotes.
- **Source formatting.** Prose you add or rewrite in the paper source follows the `Semantic line breaks` toggle in `CLAUDE.md` § *Source formatting* (source-only; the compiled PDF is unchanged).
  Do not reflow paragraphs of existing user prose you were not asked to touch.

## Integration with other skills

- `new-project` invokes this when a paper is requested; `cite` and `add-resource` feed `references.bib`.
- `journal` is the other typeset document — append-only entries, distinct from the user-owned paper, and the destination for everything the paper cannot carry.
- `new-research-notebook` owns the shared [style.md](../new-research-notebook/style.md) and applies it to a `.nb`.
- The editor role is the [revise](../revise/SKILL.md) § *Protected content* rule applied to the paper source.

## When NOT to use

- Writing the paper's content — the paper is the user's; act only as an editor on request.
- A running record of results — that is the `journal` skill.
