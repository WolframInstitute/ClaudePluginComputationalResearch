---
name: new-research-note
description: >
  Turn the conversation that just happened into a dated, self-contained
  research artifact: five files sharing one stem in `Research/Artifacts/` — a plain
  mathematics document (`.tex` + compiled `.pdf`), a paclet-independent
  Wolfram notebook (`.md` source + converted `.nb`, shipped unevaluated),
  a `.wl` carrying the same definitions for `Get`, and a README saying what
  was settled. The document has no abstract and no prose paragraphs — a
  Setting, numbered Steps, Claims with complete proofs, Definitions,
  Assumptions naming every unproved input, Observations marked "measured,
  not proved", and a catalogue of the degenerate cases and the smallest
  counterexamples. Every number in it was computed in a kernel during the
  session, or cited to a named source. Nothing is uploaded to the cloud.
  Use when the user says "research note", "write this up as a research
  note", "make an artifact of this", "research artifact", "code extract",
  or runs `/new-research-note`.
---

# Research Note

A research note is **the conversation, made checkable**.

A discussion reached something — a construction, a count, a failure case.
The note freezes it in four files that stand on their own: a document a mathematician can check line by line, a notebook a Wolfram user can open and evaluate on a bare kernel, a code file to `Get`, and a README that says what was settled.
None of it needs the conversation, the project, or a paclet.

**The two readers are served separately, and nothing is written for the space between them.**
The `.pdf` reader wants statements and proofs, so it carries no prose.
The `.nb` reader wants to run things, so it carries no proofs.

| Skill | Produces |
|-------|----------|
| `new-research-note` | a dated artifact folder: plain LaTeX, an unevaluated notebook, a loadable `.wl`, nothing uploaded |
| `new-research-notebook` | a paper *as* a notebook: MathNotebook environments, tags cited by the front end, outputs embedded, deployed to the Cloud |
| `new-notebook` | the generic Markdown → `.nb` pipeline both build on |

## When to use

- The user says "research note", "write this up as a research note", "make an artifact of this", "research artifact", "code extract", or runs `/new-research-note`.
- A conversation produced mathematics worth keeping and the project has nowhere to put it: it is not a wiki concept, not a work item, not a paclet feature.
- The user wants the session's code lifted out of the paclet so it runs on a bare kernel — that is the "code extract" case, and it produces the same folder.

## What it produces

```
Research/Artifacts/
  README.md                     the index — one row per artifact
  <Topic>_<YYMMDD>.tex          the document — plain mathematics
  <Topic>_<YYMMDD>.pdf          compiled from it
  <Topic>_<YYMMDD>.md           the notebook source
  <Topic>_<YYMMDD>.nb           converted from it, UNEVALUATED
  <Topic>_<YYMMDD>.wl           the notebook's definitions, loadable with Get
```

Five files sharing one stem, flat in `Research/Artifacts/`, plus a row in its index.
The convention they follow — the rule, the shape, the naming, git and the Cloud — is [artifacts.md](../new-notebook/artifacts.md); this skill only says what goes *inside* each file.

- `<Topic>` is explicit `CapitalizedWords` saying what the note settles, then the date it was settled, `YYMMDD`, **the same in all five names**.
- The artifact is self-contained: no `PacletInstall`, no `PacletDirectoryLoad`, no path into the project, no file it does not ship.
- **It grows into a folder** — `Research/Artifacts/<Topic>_<YYMMDD>/`, its own README, the files inside going bare — only once it carries its own data, bibliography or build script. Five files are not a reason.
- **Nothing is uploaded to the Wolfram Cloud** — a property of the artifact, not a default that can be flipped in passing.

## Kernel execution (license-aware)

Everything Wolfram runs on the official AgentTools MCP — `mcp__Wolfram__WolframLanguageEvaluator` for the computations and the conversion — one persistent kernel, no extra seat.
**Keep one session and pass its id on every call**, so the definitions accumulate and what the notebook ships is literally what was run.
`pdflatex` costs no Wolfram seat.
The authoritative policy is [`CLAUDE.md` § *Wolfram Kernel Execution Policy*](../../CLAUDE.md#wolfram-kernel-execution-policy); check headroom before any `wolframscript` fallback.

**Never read the generated `.nb` with the `Read` tool** — a `PreToolUse` hook blocks it, and the file is unreadable anyway. Inspect it in the kernel ([*Verify*](#7-compile-verify-fix-re-verify)).

## Compute before you write — Critical

Nothing is written until the kernel has produced it.

1. **Reproduce every number.** A number that was said in the conversation but never evaluated is not a number yet. Re-derive it, in the session, in the form the artifact will ship.
2. **Write the definitions as they will ship** — paclet-free, plain, lowercase — and build every result on top of *those*, not on the paclet functions the discussion used. A definition that was never run in its shipping form is untested.
3. **Check the second way round.** Where a fast computation has a brute-force counterpart (enumeration against a closed form, a count against a listing), run both and confirm they agree. The disagreement is the finding, when there is one.
4. **A claim that resists verification never quietly becomes a sentence.** It becomes an `assumption`, or an `observation` marked measured, or it is left out and named in the report.

## The document — `<Topic>_<date>.tex`

### Preamble

Fixed, and copied as-is except for the title block:

```latex
\documentclass[11pt]{article}
\usepackage[a4paper,margin=1.1in]{geometry}
\usepackage{amsmath,amssymb,amsthm,mathtools}
\usepackage{enumitem}
\usepackage{xcolor}
\usepackage[colorlinks=true,linkcolor=blue!60!black,urlcolor=blue!60!black]{hyperref}

\theoremstyle{plain}
\newtheorem{claim}{Claim}[section]
\theoremstyle{definition}
\newtheorem{definition}[claim]{Definition}
\newtheorem{step}[claim]{Step}
\newtheorem{assumption}[claim]{Assumption}
\newtheorem{example}[claim]{Example}
\theoremstyle{remark}
\newtheorem{remark}[claim]{Remark}
\newtheorem{observation}[claim]{Observation}

\setlist[enumerate]{itemsep=1pt,topsep=2pt}
```

- **`xcolor` is loaded before `hyperref`.** `blue!60!black` is an xcolor expression that hyperref parses at load time; the other order fails with an undefined colour.
- **One counter per section, shared by every environment** — the `[claim]` in each `\newtheorem`. A Claim, a Definition and a Step in the same section never collide, and `Claim~\ref{cl:x}` always points at exactly one thing.
- Declare the operators and short macros the topic needs (`\DeclareMathOperator`, `\newcommand`) and nothing else.

### Title and the disclosure footnote

```latex
\title{<topic, as a sentence-case phrase>}
\author{}
\date{<YYYY-MM-DD>\thanks{Written by Claude (<model name>) for <operator>,
from <one sentence saying what the conversation asked for>.
\textbf{<Directed|Guided|Open exploration>}: <what the operator fixed and what is the model's>.
Companion notebook: \texttt{<Topic>\_<YYMMDD>.nb}.}}
```

`\author{}` is empty on purpose — the date carries the footnote and the footnote carries the authorship.
The freedom level is **bold**, and it is one of three:

| Level | Means |
|---|---|
| **Directed** | the operator fixed the constructions; the proofs and the layout are the model's |
| **Guided** | the operator set the direction and the model chose the constructions |
| **Open exploration** | the model chose what to investigate |

### What goes in — and nothing else

Only these, in the order the mathematics needs:

- `\section*{Setting}` — the standing objects and conventions, a few lines each: what the graphs are, what the metric is, what the words mean. No motivation.
- `step` — the construction, numbered, in build order. A Step names an object and says how to build it. It proves nothing.
- `claim` + `proof` — **complete proofs**. Every case, every direction, no "clearly", no "it follows", nothing left to the reader. A multi-part claim is `\begin{enumerate}[label=(\roman*)]` and its proof answers (i), (ii), (iii) in the same labels.
- `definition` — one object each, explicit hypotheses and quantifiers.
- `assumption` — **every topological or otherwise unproved input, isolated and named**, and cited where it is used (`Under Assumption~\ref{as:annular}, …`). An unproved input buried inside a proof is the exact failure this rule exists to prevent.
- `observation` — a computational fact, headed `[measured]`, saying what was measured, on what, and against what it was checked. It is never a proof and never stands in for one.
- `remark` — cost, a pitfall, a scope note, and one *what is not proved here* remark late in the construction listing the topological inputs and where they are known to fail.

Forbidden: an abstract, an introduction, a motivation paragraph, a conclusion, a summary, and **any paragraph of prose living outside an environment**.
If a sentence is not part of a Setting, a Step, a Definition, a Claim, a Proof, an Assumption, an Observation or a Remark, it does not go in the document.

Sections are numbered and carry mathematical titles; the catalogue and the worked family go in `\subsection`s.
Label everything that is cited, with a prefix per environment — `cl:`, `st:`, `def:`, `as:`, `ob:` — and cite it as `Claim~\ref{cl:…}`, so the word and the number always arrive together.
A statement nothing cites carries no label.

### The catalogue

A section of tables near the end, one table per family of objects.
It is where the reader learns the shape of the thing, so it is chosen, not dumped:

- the **degenerate cases** — where there is nothing, where there is exactly one, where the count is trivial;
- the **non-degenerate contrast** — the case the note is actually about, with its closed form;
- the **simplest counterexamples and failure cases** — the smallest object on which the construction misses, and what it misses by.

Each row carries the relevant numbers and ends in a **status column**: `exact` (the construction agrees with exhaustive enumeration), `misses` (objects exist and the construction finds none or fewer), `not enumerated` (too large to check — say so rather than implying either).
Set the tables as plain `array` environments with `|` rules, wrapped in `{\small …}` when wide; no `booktabs`, no colour.
Every proved row sits under a Claim that proves it; the rest sit under one `observation` headed `[measured]` that says how they were obtained.

### Numbers

**Every number in the document was computed in a kernel during this session, or is cited to a named source** — the note, the paper, the design document, named in the text.
A number inherited from the conversation without being re-run is a number with no provenance and does not go in.

## The notebook — `<Topic>_<date>.md` → `.nb`

### Conversion

Write the Markdown source, then convert it with the [new-notebook](../new-notebook/SKILL.md) pipeline on the MCP kernel — built-in or rich engine, chosen as there — which stamps each cell with the lines of the `.md` it came from, the anchors a [revision round](../revise/round.md#notebooks) needs.
`mcp__Wolfram__WriteNotebook` is not used: it turns each line of a paragraph into its own cell, and cannot carry source lines (measured 2026-10-03).
The mapping: `#` → `Title`, `##` → `Section`, a paragraph → one `Text` cell, a fenced block tagged `wolfram` → one `Input` cell.
The `.md` is the source and the `.nb` is generated from it; edit the `.md` and convert again.

**The notebook ships unevaluated.**
Input cells only, no `Output` cells, no `CellLabel`s — the user evaluates it, and that is the point of shipping it.
No `SeedRandom` unless randomness is itself the subject.
**No `PacletInstall` setup cell** unless the notebook genuinely touches a paclet: paclet-independence is the property that makes the artifact portable.

### Order — a walkthrough

1. One paragraph of title text: what the object is, what is read off it, and that everything below is defined from scratch.
2. `## Definitions` — one definition per Input cell, each preceded by **one short text cell saying in words what it is**. Main definitions first, the ones they call below them.
3. The **simplest demonstration**: the smallest graph on which the thing is visible, the count, the picture.
4. The richer demonstrations, in increasing order of what they show.
5. The **catalogue**: the degenerate cases, then the cases with a handful of objects, then the counterexamples where the construction is silent — the same rows as the document's tables.
6. Brute force **next to** every fast computation: enumerate, count, compare. A fast number with no cross-check beside it is not demonstrated.
7. The limits section (interior, range of validity, scaling) last, if the topic has one.

### Text cells

Short human prose.
A text cell says what the next cell is *for*, in words — never a function name, never a code fragment, never jargon.
Enumerations are itemized lists.
Two or three sentences is a long text cell.

### Code

Written as a person would write it, for a reader who will modify it:

- plain `Module` / `With`, Wolfram built-ins used idiomatically, `v |-> …` rather than `Function[v, …]`;
- **no options, no overloads, no parameters nobody passes, no helper-function sprawl** — a helper exists only if it is used in several places or is the only way to keep a definition readable;
- **no comments anywhere** — the notebook's text cells carry the explanation, and the `.wl` carries none;
- lowercase names that cannot shadow a paclet symbol;
- one idea per cell: a definition, or a computation, or a picture.

**Every code cell was evaluated in the kernel session before it was written into the source, and every output it produces was looked at.**
A cell that errors, prints a message, or takes minutes does not ship.

## The code file — `<Topic>_<date>.wl`

The notebook's definitions, **verbatim**, in the notebook's order, one blank line between them.
No comments, no `BeginPackage`, no `Package[]`, no usage messages, no examples, no demonstrations — nothing but the definitions.
Verify it by `Get`-ing it into the kernel and re-running one demonstration from the notebook.

## The index row and the artifact README

The artifact's home is one row in `Research/Artifacts/README.md`.
A **flat** artifact gets that row and nothing else — its document is its own documentation.
A **folder** artifact also carries its own `README.md`, in five parts, in this order:

1. The artifact's row in `Research/Artifacts/README.md`: its name, what it settles, and its state. Add it in the same step that writes the files, never later.
2. A short paragraph *What is proved*, and a **results table** — the headline numbers, the ones a reader would quote.
3. Optional short paragraphs on the catalogue and the limits, naming the cases rather than describing them.
4. `## Contents` — one line per file, saying what is in it.
5. The rebuild command in a fenced block, then the closing line: `Not uploaded to the Wolfram Cloud.`

```bash
# from Research/Artifacts/
latexmk -pdf <Topic>_<YYMMDD>.tex && latexmk -c
```

`latexmk` is for the human rebuilding it later; the build in step 7 is `pdflatex` twice, because the log has to be read.

## Steps

### 1. Fix the topic, the date, the freedom level

`<Topic>` in explicit `CapitalizedWords`, today's date as `YYMMDD`, and which of Directed / Guided / Open exploration the session was — the operator's degree of control is a fact about the conversation, not a flattering guess.
Say the stem and the three of them in one line before starting; that is the whole plan, and it is cheap to correct.

### 2. Compute everything, in one kernel session

Per [*Compute before you write*](#compute-before-you-write--critical). Open the session, define the shipping definitions, reproduce every number, run the cross-checks, and keep the session id for the rest of the job.

### 3. Write the document

`.tex` first, because it is where the mathematics has to hold up.
Preamble, title block with the disclosure footnote, Setting, Steps, Claims with full proofs, Assumptions, Observations, the catalogue tables.

### 4. Write the notebook source and convert it

The `.md` in walkthrough order, then the conversion.

### 5. Extract the code file

The definitions out of the `.md`, verbatim, into `<Topic>_<date>.wl`. `Get` it and re-run one demonstration.

### 6. Write the README

Last of the four, since it reports on the other three.

### 7. Compile, verify, fix, re-verify

**Compile through `bash -c`** — the user's shell is fish, where `status` is read-only and a compile line written for `sh` misbehaves:

```bash
bash -c 'cd "<…>/Research/Artifacts" && pdflatex -interaction=nonstopmode <Topic>_<date>.tex >/dev/null && pdflatex -interaction=nonstopmode <Topic>_<date>.tex >/dev/null'
bash -c 'grep -nE "^!|Undefined|Overfull" "<…>/Research/Artifacts/<Topic>_<date>.log"'
```

Twice, so `\ref` resolves; then read the log.
Fix every hit — errors, undefined references, and overfull boxes of **10pt or more** (smaller ones are noise) — then compile again and re-check.
Keep the pattern loose and judge the hits; a clever regex hides the one line that mattered.
Then delete the build litter and keep only `.tex` and `.pdf`:

```bash
bash -c 'cd "<…>/Research/Artifacts" && rm -f <Topic>_<date>.aux <Topic>_<date>.log <Topic>_<date>.out <Topic>_<date>.fls <Topic>_<date>.fdb_latexmk'
```

Verify the notebook in the kernel, never with `Read`:

```wolfram
Counts[Cases[Get["<…>/Research/Artifacts/<Topic>_<date>.nb"], Cell[_, s_String, ___] :> s, Infinity]]
```

Expect one `Title`, one `Section` per `##`, one `Text` per paragraph, one `Input` per fence — **and no `Output`**.
A census that is short on `Input` means fences were mangled; one with `Output` in it means the notebook was evaluated and must be rebuilt.

### 8. Report

Follow [revise](../revise/SKILL.md): the artifact is the deliverable and the report is the presentation.
Producing it in full before presenting is safe here precisely because nothing is uploaded and version 1 is a commit that can be amended.
A few lines:

- the folder path;
- the page count of the `.pdf`;
- the cell census of the `.nb`;
- **what is left unproved** — each item already sitting in the document as an `assumption` or a measured `observation`, named here too;
- **anything the conversation asked for that the artifact could not honour** — a claim that did not verify, a case that was too large to enumerate. Say it in the report; do not ship it as a sentence in the document.

Write `<stem>.provenance.md` and commit version 1 as written, files staged by name, never the `.nb` ([provenance § *Version 1*](../provenance/SKILL.md#version-1)); do not upload.

## Checklist

- [ ] Five files sharing one stem in `Research/Artifacts/`, the same date in all five names, and the index row written.
- [ ] Every number in the `.tex` computed in this session's kernel, or cited to a named source.
- [ ] `.tex`: no abstract, no introduction, no conclusion, no paragraph outside an environment.
- [ ] Proofs complete — every case, every direction, nothing left to the reader.
- [ ] Every unproved input is a named `assumption`, cited where used; every computational fact is an `observation` marked measured.
- [ ] Catalogue tables carry the degenerate cases, the contrast, the counterexamples, and a status column.
- [ ] `xcolor` before `hyperref`; one shared counter; the `\date` footnote names the model, the operator, the instruction in one sentence, the **bold** freedom level and the companion notebook.
- [ ] `pdflatex` twice, log clean of `^!`, undefined references and overfull boxes ≥ 10pt; `.aux .log .out .fls .fdb_latexmk` deleted.
- [ ] `.nb` unevaluated: Input cells only, no Output, no `SeedRandom`, no paclet load; census checked in the kernel.
- [ ] Notebook text cells are short prose with no function names; code has no comments, no options, no helper sprawl.
- [ ] Every notebook code cell was evaluated in the session and its output checked; each fast computation has its brute-force check beside it.
- [ ] `.wl` is the notebook's definitions verbatim and nothing else; `Get` re-runs a demonstration.
- [ ] README: what was settled, results table, contents, rebuild command, `Not uploaded to the Wolfram Cloud.`
- [ ] `<stem>.provenance.md` written with the first Request; version 1 committed as written (no `.nb`); nothing uploaded.

## Integration with other skills

- `new-notebook` owns the Markdown → `.nb` conventions this skill uses; the artifact notebook differs from its house output in two ways only — it ships **unevaluated** and it loads no paclet.
- `new-research-notebook` is the other direction: numbered MathNotebook environments, cited tags, embedded outputs, Cloud deployment. A research note is a *pair* of documents instead, and stays local.
- `update-wiki` is where the durable concept goes if one came out of the note; the artifact is the record, the wiki article is the knowledge. Link the artifact folder from the article.
- `journal`, when it is on, takes the hedged material the document refuses — the claims that did not verify and the ranges that are not proofs.
- `work`, when the note turns out to be the start of something: the artifact stays as it is and a work item carries the follow-up.
- `revise` — the report is the gate ([*Report*](#8-report)).

## When NOT to use

- The result belongs in the paclet, the wiki or a work item — write it there; an artifact is for what has no other home.
- A notebook that demonstrates paclet functions — that is `new-notebook`.
- A paper with numbered cross-referenced statements, or one to be deployed to the Cloud — that is `new-research-notebook`.
- Nothing was actually settled. A conversation of guesses makes a bad artifact: say what is missing and compute it first.
