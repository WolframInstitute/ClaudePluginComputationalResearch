---
name: research-notebook
description: >
  Build an LLM-generated "research notebook": a concise, mathematically precise,
  cloud-published Wolfram notebook that develops one topic as a research
  document — definitions first, then the strongest conjectures we can defend
  (each with computed evidence), function demonstrations named by the literal
  code, an enumerated list of further research questions, and a literature
  section. Uses the MathNotebook paclet environments (Definition, Conjecture,
  Question, ...) so statements translate directly to Lean. Visual-first: mostly
  pictures and plots, not numeric dumps. Kept in two-way sync with a Markdown
  source — user edits in the .nb are folded back into the .md, never
  overwritten. Use when the user says "research notebook", "notebook with
  conjectures", "research document on X", "write up the research on X", or the
  /research-notebook command.
---

# Research Notebook

A research notebook is a *mathematical research document*, not a demo and not an
exploration log:

| Skill | Produces |
|-------|----------|
| `new-notebook` | generic Markdown → `.nb` pipeline (this skill builds on it) |
| `demo-notebook` | paclet demo: function reference card + worked examples |
| `research-notebook` | definitions → conjectures + evidence → demonstrations → open questions → literature |

**Style: lightweight and precise.** Every sentence either defines, states, or
points at code. No filler prose, no over-explanation, no code inside Text
cells. If a paragraph doesn't add a mathematical fact, delete it.

## Pipeline and two-way sync — Critical

The source of truth is `NotebooksLLM/<Topic>.md`, converted via the
[new-notebook](../new-notebook/SKILL.md) pipeline (backtick escaping, boxify,
init-cell marking, `[LLM Generated]` subtitle — all of it applies). The
generated `.nb` sits beside it, gitignored, dated on first creation.

**Never overwrite user edits in the `.nb`.** Before every regeneration:

1. Export the existing `.nb` to Markdown via the MCP
   (`ExportString[ Import[ path ], "Markdown" ]`).
2. Diff against the source `.md`. Any cell the user added or changed is
   **incorporated into the `.md` first** (ask if a conflict is ambiguous —
   user content wins by default).
3. Only then regenerate the `.nb` from the updated source.

So the notebook is never "only LLM generated": it is a shared document where
the `.md` accumulates both LLM and user contributions.

## MathNotebook environments and Lean-translatability

Load the MathNotebook paclet in Initialization; install it if missing:

```wolfram
Quiet @ Check[ Needs[ "WolframInstitute`MathNotebook`" ],
  PacletInstall[ "WolframInstitute/MathNotebook" ]; Needs[ "WolframInstitute`MathNotebook`" ] ]
```

Set the notebook's `StyleDefinitions` to the paclet stylesheet
(`FrontEnd`FileName[ { "MathNotebook" }, "AMSArticle.nb" ]`) so the theorem
environments render and number themselves.

**Source convention → environment cells.** In the `.md` source, open a
paragraph with a bold marker: `**Definition.**`, `**Conjecture.**`,
`**Question.**`, `**Observation.**`, `**Remark.**`. Post-processing (after the
new-notebook pipeline, before `ExportString`) converts each such Text cell to
the matching MathNotebook style cell with the marker stripped — the stylesheet
supplies numbering.

**Write every Definition and Conjecture so it translates directly to a Lean
statement**: explicit hypotheses, explicit quantifiers, quantification over
finite/decidable objects wherever possible ("for every connected graph $G$ with
$|V| \le n$ ..."), no appeals to pictures inside statements. Open questions and
proved conjectures feed the [lean](../lean/SKILL.md) skill for formalization.

## Notebook structure

1. **Title**, `[LLM Generated]` subtitle, then a 2–4 sentence abstract stating
   the main claims — written **last**, after the evidence is in.
2. **Initialization** (folded, init cells): paclet loads, MathNotebook load,
   `SeedRandom`, a reproducibility line (paclet version, git commit, date),
   and — for graph topics — the example-graph constructions **copied verbatim
   from the project's ExampleGraphs notebook/module** (e.g. Infrageometry's
   `Kernel/ExampleGraphs.wl`), so the notebook is self-contained.
3. **Definitions** — `Definition` cells, precise, Lean-translatable.
4. **Conjectures** — the strongest conjectures the computations support, each a
   numbered `Conjecture` cell followed by a folded **Evidence** subsection:
   a systematic check over the example-graph battery whose verdict is rendered
   **as a graphic** (see *Visual-first*). Each conjecture carries a status
   marker: `verified up to n = ...` / `open` / `proved in [ref]`. A conjecture
   that fails the battery is **demoted to a Question** and the minimal
   counterexample found is kept, as a picture.
5. **Demonstrations** — one Section per function, titled by the **literal
   symbol name** (e.g. `GraphInteriorForm`); Subsections titled by the literal
   option/method form (e.g. `"Method" -> "3DFiber"`). Short Text cell, then
   code, then picture. Follow `wi:sw-example` house style when present.
6. **Further research questions** — an enumerated list (`ItemNumbered`), each
   referencing the conjectures/definitions it concerns by number; proof
   strategies for the conjectures live here.
7. **Literature** — every claim that isn't ours gets a citation tag `[tag]`
   (MathNotebook `Citation` style); the final References section lists the
   entries, produced by the [cite](../cite/SKILL.md) skill and kept in sync
   with `Paper/references.bib` when the project has one.

## Visual-first — Critical

The notebook is **mostly pictures and plots**. Never end an evidence or
demonstration cell with a bare number, boolean list, or textual table:

- verdicts over the graph battery → `ArrayPlot`/heatmap grid or a row of
  highlighted graphs, pastel colors;
- counterexamples → the graph drawn with the violating substructure
  highlighted;
- quantitative claims → a plot, not a list of values.

A small symbolic result (a single boolean, a short set) may stand alone only
when that value *is* the point.

## Evaluate, publish, link — like the Infrageometry repo

1. **Smoke test**: evaluate every Input cell through the Wolfram MCP
   (license-aware — see [new-notebook](../new-notebook/SKILL.md) *Kernel
   execution*); the build must finish with **zero messages**.
2. **Embed outputs**: the published copy carries real evaluated outputs —
   graphics rasterized, small symbolic results as live boxes (same
   rasterize-vs-boxes rules as [demo-notebook](../demo-notebook/SKILL.md)).
3. **Deploy** to the Wolfram Cloud, public, stable object name
   `<Project>/<Topic>.nb` (matching `Scripts/publish_notebooks.wls`).
4. **Link from the repo README** in a `## 📓 Research Notebooks` section — a
   table `| Notebook | Description | Link |`, one row per notebook, the link
   anchored on "Wolfram Cloud" — exactly the format the Infrageometry paclet
   README uses. Create the section if missing; update the row in place if the
   notebook already has one.

## After publishing

- Sync the open questions to the Wiki (or the journal, when it is on) so they
  outlive the notebook.
- If prompt tracking is on (`Prompt tracking: **on**` in `CLAUDE.md` — see
  [provenance](../provenance/SKILL.md)), record the originating prompt in the
  `.md` source and `Wiki/Prompts.md`.

## Checklist

- [ ] `.md` source in `NotebooksLLM/`; user `.nb` edits folded back before regeneration.
- [ ] MathNotebook stylesheet + environments; markers converted to Definition/Conjecture/Question cells.
- [ ] Definitions and conjectures Lean-translatable (explicit hypotheses and quantifiers).
- [ ] Every conjecture has evidence rendered as a graphic and a status marker; failures demoted with counterexample pictures.
- [ ] Demonstration sections titled by literal function/option code; no code in Text cells.
- [ ] Enumerated further research questions referencing conjectures by number.
- [ ] Literature section with citation tags, synced with `Paper/references.bib`.
- [ ] Initialization folded: seeds, reproducibility line, ExampleGraphs constructions.
- [ ] Zero-message evaluation; outputs embedded; deployed public; README `Research Notebooks` table updated.
- [ ] `[LLM Generated]` subtitle present; abstract written last.
