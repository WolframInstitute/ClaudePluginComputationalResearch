---
name: journal
description: >
  Optionally maintain a running scientific journal in LaTeX or Typst — a concise,
  structured, append-only stream of dated def/thm/rem/claim entries recording the
  math and physics content and main claims established during research, with every
  resource cited. Off by default; gated by a per-project toggle in CLAUDE.md.
  Scaffold it, append dated entries automatically when on, and list the index. Use
  when the user says "keep a journal", "scientific journal", "journal this", "turn
  the journal on/off", "journal status", or the /journal command. Distinct from the
  Wiki (deduplicated encyclopedia): the journal is the typeset, cited record of what
  was learned and when. Other skills (update-wiki, next-session, cite) feed it when on.
---

# Scientific Journal

A running LaTeX or Typst document the LLM maintains: one file
(`Journal/journal.tex` or `Journal/journal.typ`), newest entries first, each a
dated section holding concise `definition` / `theorem` / `remark` / `claim`
environments with citations. LaTeX (default) or Typst — the format is fixed once
`Journal/` is scaffolded. **Optional** — nothing here runs unless the project
toggle is on.

## Journal vs. Wiki

| | `Wiki/Definitions`, `Wiki/Theorems` | `Journal/journal.tex` |
|---|---|---|
| Shape | Encyclopedia | Lab journal |
| Trigger | On durable change | Toggle-gated, auto when on |
| Unit | One article per concept, deduplicated | One dated entry per checkpoint, append-only |
| On change | Overwrite to stay current | Append a new dated entry; never reorder |
| Format | Markdown prose + `Status:` | LaTeX/Typst def/thm/rem/claim + `\cite` |

The Wiki answers *"what do we know?"* and is overwritten to stay current; the
journal answers *"what did we learn, when, and from where?"* and is appended to,
never rewritten. Record the *event of learning* (with citation) in the journal;
record the *settled fact* in the Wiki. Do not copy Wiki prose verbatim.

## The toggle (check this first)

The journal is opt-in per project, declared in the project's `CLAUDE.md`:

```markdown
## Scientific journal

Scientific journal: **off**
<!-- When on, the LLM keeps a running LaTeX/Typst journal in Journal/ — a concise,
     structured, append-only stream of dated def/thm/rem/claim entries recording the
     math/physics content and main claims established, with resources cited into
     Journal/references.bib. Plain "on" = very concise; "on (verbose)" = fuller
     detail. Toggle with /journal; see the `journal` skill. -->
```

Before recording anything, check the toggle:

```bash
grep -qiE 'scientific journal:[[:space:]]*\*{0,2}on' CLAUDE.md && echo on || echo off
```

(A second `grep -qi 'verbose'` on that line distinguishes `on` from `on (verbose)`.)

- **off** (default, or section absent): do nothing. Never scaffold `Journal/`,
  never append. Stay silent — do not nag the user to turn it on.
- **on**: at each natural checkpoint — a definition is settled, a theorem or claim
  is established or refuted, a resource is used — append **one very concise** dated
  entry, citing resources used. Mention it in passing ("logged to the journal");
  do not present it for sign-off.
- **on (verbose)**: same, but capture per datum with fuller statements.

The journal is a **record, not a deliverable** — exempt from the `revise` loop
(like wiki prose and the prompt ledger). Edit `journal.tex` / `macros.sty` freely.

## scaffold [--typst]

Create `Journal/` if it does not exist:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-journal.sh" [--typst] "<ProjectDir>" "<Title>" "<Author>"
```

LaTeX creates `Journal/{journal.tex, macros.sty, references.bib, entries/, figures/, .latexmkrc}`;
Typst creates `Journal/{journal.typ, macros.typ, references.bib, entries/, figures/}`.

The master file (`journal.tex` / `journal.typ`) holds the preamble and the
bibliography; **each day's entries live in their own file** under `entries/`
(`entries/YYYY-MM-DD.tex` or `.typ`), pulled into the master with a plain `\input`
/ `#include` — no `subfiles` package. The master carries an end-marker where those
include lines go, newest first:

- LaTeX: `% === day-files below — newest first; LLM adds \input{entries/YYYY-MM-DD} lines here ===`
- Typst: `// === day-files below — newest first; LLM adds #include "entries/YYYY-MM-DD.typ" lines here ===`

Scaffold **lazily** — `Journal/` is never pre-created by `new-project`; create it
(default LaTeX) the first time the toggle goes on or the first `add`. If `Journal/` is tracked (not gitignored), add the same
build-artifact patterns as `scaffold-paper`, scoped to `Journal/`.

## add "<topic / content>"

One file per day. Distill the conversation into **concise** def/thm/rem/claim
environments — not prose paragraphs. Capture every definition, theorem, and main
claim (math **and** physics; use `claim` for assertions that are not formal
theorems), and cite every resource used.

1. Target today's day-file: `Journal/entries/YYYY-MM-DD.tex` (or `.typ`).
2. **If it does not exist**, create it (content below) and add an include line
   **directly below the master's end-marker**, newest first —
   `\input{entries/YYYY-MM-DD}` (LaTeX) or `#include "entries/YYYY-MM-DD.typ"`
   (Typst).
3. **If it already exists**, append the new entry to the *end* of that day-file;
   do not add a second include line and do not touch the master.

Never reorder the include lines and never rewrite a past day-file.

LaTeX day-file (`entries/2026-06-02.tex`) — a bare fragment, no preamble; the
master's `\usepackage{macros}` supplies the environments:
```latex
\section{2026-06-02 — Ollivier–Ricci curvature on graphs}
\begin{definition}[Ollivier–Ricci curvature]
$\kappa(x,y)=1-W_1(\mu_x,\mu_y)$, with $\mu_x$ uniform on the 1-ball at $x$.
\end{definition}
\begin{theorem}[Lin–Lu–Yau]
The limit $\kappa_{LLY}(x,y)$ exists for all edges. \cite{LinLuYau2011}
\end{theorem}
\begin{claim}
On expander families the curvature is bounded below by a positive constant
(heuristic, unproved).
\end{claim}
\begin{remark}
Matches \texttt{Code/Curvature.wl} on $C_n$ to machine precision.
\end{remark}
```

Typst day-file (`entries/2026-06-02.typ`) — opens with the macros import (an
included file needs it in scope); `#cite` resolves against the master's
`#bibliography`:
```typst
#import "../macros.typ": *

== 2026-06-02 — Ollivier–Ricci curvature on graphs
#definition[*Ollivier–Ricci curvature.* $kappa(x,y) = 1 - W_1(mu_x, mu_y)$, with $mu_x$ uniform on the 1-ball at $x$.]
#theorem[*Lin–Lu–Yau.* The limit $kappa_("LLY")(x,y)$ exists for all edges. #cite(<LinLuYau2011>)]
#claim[On expander families the curvature is bounded below by a positive constant (heuristic, unproved).]
#remark[Matches `Code/Curvature.wl` on $C_n$ to machine precision.]
```

If `Journal/` does not exist yet, scaffold it first (default LaTeX).

## Citing into the journal

The journal owns `Journal/references.bib`. To cite a resource, generate a BibTeX
entry, append it there, then reference it with `\cite{key}` (LaTeX) or
`#cite(<key>)` (Typst).

Generate the entry with [cite](../cite/SKILL.md) / `cite_from_id.wls`, which is
**license-aware**: before spawning `wolframscript`, check headroom on the
AgentTools MCP (no extra seat):

```wolfram
With[{free = $MaxLicenseProcesses - $LicenseProcesses}, free]
```

If `free <= 0`, run the same `Import[...]` through
`mcp__Wolfram__WolframLanguageEvaluator` instead. `grep` the key in
`references.bib` first to avoid duplicates.

## list (or no argument)

List the `entries/` day-files (equivalently, the `\input` / `#include` lines in the
master), most recent first, so the user sees what the journal contains.

## Turning it on / off

When the user asks to enable the journal:

1. Set `Scientific journal: **on**` (or `**on (verbose)**`) in the project's
   `CLAUDE.md` (add the `## Scientific journal` section if absent).
2. Scaffold `Journal/` (default LaTeX, or `--typst` if asked) if it does not exist.

To disable, set `Scientific journal: **off**`. Leave existing entries in place —
they are part of the git history.

## How other skills feed the journal

When the toggle is on, these skills append to the journal in this format:

- **update-wiki** — when a definition/theorem/claim becomes durable knowledge,
  appends the dated, cited entry to `Journal/` alongside the deduplicated Wiki
  article.
- **next-session** — at the end of a session, appends a concise entry for what was
  established, citing resources used.
- **cite** — appends generated BibTeX to `Journal/references.bib` when a `Journal/`
  exists.

This skill is the single source of truth for the format — the others reference it.

## Rules for LLM

- The journal is a **record, not a deliverable** — exempt from the `revise` loop.
  Mention in passing; do not present entries for sign-off.
- **Concise by default**; expand only under `on (verbose)` or on explicit request.
- Capture math **and** physics main claims — use `claim` for non-theorem assertions.
- Keep notation consistent with `macros.sty` / `macros.typ`; extend them freely.
- One file per day under `entries/`; never reorder the include lines and never
  rewrite a past day-file.
- Put images/plots in `Journal/figures/`.
- When `CLAUDE.md` has `Semantic line breaks: on` (the default — see its *Source
  formatting* rule), write the prose inside def/thm/rem/claim environments one
  sentence per source line. This is source-only; the typeset output is unchanged.
