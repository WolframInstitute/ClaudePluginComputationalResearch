---
name: scaffold-paper
description: >
  Scaffold a Paper/ folder with LaTeX (amsart, biblatex) or Typst article
  templates and a shared preamble, then act as an editor on the user-owned
  document. Prose written into the paper follows the shared writing guide in
  research-notebook/style.md: settled statements only, experiments in a
  Ruliology section, complete proofs, short sentences, each result stated at the
  generality its proof reaches, and the model as sole author with a footnote
  naming the operator and disclosing in bold how much freedom the model had. Use when the user
  says "scaffold paper", "add paper", "create paper folder", "set up latex",
  "set up typst", or during new-project when the user wants a paper. Trigger on:
  "paper setup", "latex template", "typst template", "add Paper/", "I want to
  write a paper".
---

# Scaffold Paper

Create a `Paper/` directory for a typeset article, then help the user *edit* it.
Two formats:

- **LaTeX** (default) — amsart document class, biblatex with biber, shared `macros.sty`.
- **Typst** — `main.typ` importing a shared `macros.typ`, native `bibliography()`.

The paper is the **user's document**.
This skill scaffolds the structure and then acts as an *editor*, not an author (see Rules below).

## Style — read this before writing any prose

**[research-notebook/style.md](../research-notebook/style.md) is the writing guide, and it is canonical here.**
It is shared so a paper reads the same whether it ships as LaTeX, Typst or a notebook.

The four things it decides that this skill cannot:

- **Tiers.** The paper carries only settled statements — proved in full, or cited to a source that was read. Experiments (enumeration ranges, sweeps, distributions, timings) are gathered near the end, usually a `Ruliology` section — if there are none, there is no such section. Hedged claims, heuristics, alternate proofs and failed attempts go to the [journal](../journal/SKILL.md), never the paper. Nothing is silently dropped — and with the journal off, nothing is silently cut either: the list goes to the operator ([style.md](../research-notebook/style.md) § *When the journal is off*).
- **Length.** Abstract ≤ 4 sentences. Introduction 3 paragraphs of ≤ 6 sentences. No prose paragraph over 6 sentences and never two in a row — the abstract, the introduction and the *Ruliology* entries are prose by construction and exempt. Connecting sentences ≤ 25 words; a proof deduction and an abstract sentence are not word-capped.
- **Proofs.** Complete prose, one deduction per sentence, each naming what it uses through `\cref`. No *clearly*, *one easily sees*, *we omit the details*, no proof sketches. A long proof is fine when it reads clearly — never abbreviate to fit, and never break an argument into a chain of one-line lemmas. The 8-sentence trigger counts one run of deductions, so a two-part proof is counted part by part.
- **Authorship.** `\author` is the **model**; `\date` is the date the document was generated, written out and never `\today`; the `\thanks` footnote (Typst: a small block under the model line) names the operator, sets the freedom level in `\textbf` — Directed, Guided or Open exploration — and summarises the instructions in one sentence. `[ LLM Generated ]` is the first line of the title, since amsart has no slot for it. The template ships all of this already.
- **Results.** State each result at the generality the proof actually reaches — a general theorem is the goal, and the only rule is that generality is never bought with a gap. Every statement names its own hypotheses and survives being lifted out of the document. Nothing is used before it is proved. Every conjecture says what would settle it. A short paper is fine.
- **Formalisation** is never undertaken unasked; `\cref`-able precise statements are always worth writing, a Lean development only on an explicit request.

`macros.sty` / `macros.typ` is where every nontrivial symbol gets a macro, defined once.
That rule is the LaTeX half of style.md § *Notation*, and the namespace is already occupied at many obvious names (`\mid`, `\d`), so take the shortest free name rather than redefining an existing command.

Three things a typeset paper has to do that a notebook does not, all of them measured on [the first paper written under the guide](../../Wiki/Concepts/PaperStyleExercise.md#four-findings-the-latex-path-exposed-on-its-own):

- **An Example's picture is a file.** The code does not evaluate, so the Example carries the call *and* a graphic exported from exactly that call. No `figure`, no `\caption` — that numbers and labels the picture, which § *Examples* bans — so a centred non-floating box, bound to the call inside one `minipage` or the picture floats away from the Example that owns it.
- **Code is wrapped by the column, not by the source.** The ten-line example budget counts rendered lines; wrap a long call to the text width by hand before counting it.
- **The code behind the *Ruliology* calls goes in an appendix**, named once from *Ruliology*. A notebook hides it in *Initialization*; LaTeX has no such section, and left inline it buries the one-line calls the section exists to carry.

## When to use

- The user says "scaffold paper", "add paper", "create paper folder", "set up latex", "set up typst", "I want to write a paper".
- During `new-project` when the questionnaire's *Include Paper/?* is yes.

## What you need

1. **Project directory** — where to create Paper/.
   Usually the project root.
2. **Format** — LaTeX (default) or Typst.
   Pass `--typst` if the user wants Typst, or they say "typst".
3. **Title** (optional) — working title.
   Default: project name.
4. **Operator** (optional) — the person running the session; defaults from git config.
   Not the author: the author is the model (§ *Style*).
5. **Model, freedom level and prompt summary** — your own name and identifier, one of Directed / Guided / Open exploration, and one sentence on the instructions you worked under.

If invoked from new-project, these are already known.

## Steps

### 1. Run the scaffold script

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paper.sh" [--typst] [--force] "<ProjectDir>" "<Title>" "<Operator>" "<email>" "<Model>" "<Freedom>" "<Prompt>" "<Date>"
```

`<Operator>` is the person running the session and `<Model>` is you, by name and exact identifier.
`<Freedom>` is one of `Directed`, `Guided`, `Open exploration` — it prints **bold** in the footnote, and between two labels you take the more open one.
`<Prompt>` is one sentence summarising the instructions you actually worked under, including what was left unspecified.
`<Date>` defaults to today and is baked into the document, since `\today` re-dates the paper on every compile.

**The script writes `<ProjectDir>/Paper/`, and it refuses to overwrite an existing `main.tex`, `macros.sty` or `references.bib`** — that target is often a paper someone is writing.
Give a different directory rather than reaching for `--force`.

LaTeX creates:
```
Paper/
├── main.tex           — article (amsart + \usepackage{macros})
├── macros.sty         — shared preamble, theorem envs, macros
├── references.bib     — bibliography (biblatex format)
├── figures/           — for TikZ exports and plots
└── .latexmkrc         — latexmk config (pdflatex + biber)
```

Typst (`--typst`) creates:
```
Paper/
├── main.typ           — document (#import "macros.typ": *)
├── macros.typ         — shared preamble, math shorthand, theorem envs
├── references.bib     — bibliography (read natively by Typst)
└── figures/           — for plots and images
```

### 2. Seed references from existing resources

If `Wiki/Resources/` exists and contains paper articles, extract BibTeX entries and add them to `references.bib`.
Use arXiv MCP or crossref MCP to fetch proper biblatex/BibTeX entries for each paper.
Both formats read `references.bib`.

### 3. Update .gitignore

If Paper/ is NOT already gitignored (research projects where Paper/ is tracked), add build artifact patterns.
LaTeX:

```
Paper/*.aux
Paper/*.bbl
Paper/*.bcf
Paper/*.blg
Paper/*.fdb_latexmk
Paper/*.fls
Paper/*.log
Paper/*.out
Paper/*.run.xml
Paper/*.synctex.gz
Paper/*.toc
Paper/*.pdf
```

Typst produces only `Paper/*.pdf`.
If Paper/ is already gitignored entirely (paclet-dev type), no action needed.

## Template contents

### macros.sty (LaTeX)

Shared preamble loaded by main.tex:

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
cd Paper && latexmk -pdf main.tex      # LaTeX
cd Paper && typst compile main.typ     # Typst (typst watch for live preview)
```

## Rules for LLM

This skill **scaffolds and edits**; it does not write the paper.

- **main.tex / main.typ is the user's writing space** — protected content in the [revise](../revise/SKILL.md) § *Protected content* sense: never author or overwrite it unprompted.
- Act as an **editor on request**:
  - Import material at a specified location ("put the lemma after Section 2").
  - Correct or rewrite a paragraph the user points to.
  - Add figures (TikZ / `figures/` images), code listings, tables.
  - Keep notation consistent with macros.sty / macros.typ.
- **macros.sty / macros.typ** can be extended freely — add macros, operators, theorem environments as needed.
- **references.bib** — add entries when papers are downloaded or cited.
- When you do add prose at the user's request, write in the user's voice and to [style.md](../research-notebook/style.md).
- **Move, do not drop.** Material that fails the settled tier goes to the [journal](../journal/SKILL.md) with one line saying why — never deleted, never left hedged in the paper.
  With the journal off, stop and put the list to the operator — turn the journal on, keep it marked in the paper, or drop it explicitly ([style.md](../research-notebook/style.md) § *When the journal is off*).
  Unattended, keep it and report the list in the run digest.
- **Source formatting.** Prose you add or rewrite in `main.tex` / `main.typ` follows the `Semantic line breaks` toggle in `CLAUDE.md` § *Source formatting* (source-only; the compiled PDF is unchanged).
  Do not reflow paragraphs of existing user prose you were not asked to touch.

## Integration with other skills

- `new-project` invokes this when a paper is requested; `cite` and `add-resource` feed `references.bib`.
- `journal` is the other typeset document — append-only entries, distinct from the user-owned paper, and the destination for everything the paper cannot carry.
- `research-notebook` owns the shared [style.md](../research-notebook/style.md) and applies it to a `.nb`.
- The editor role is the [revise](../revise/SKILL.md) § *Protected content* rule applied to `main.tex` / `main.typ`.

## When NOT to use

- Writing the paper's content — the paper is the user's; act only as an editor on request.
- A running record of results — that is the `journal` skill.
