---
name: notes
description: >
  Administer a running LaTeX or Typst notes document in Notes/ — scaffold it, add
  dated note entries on request, and list the index. Unlike scaffold-paper (where
  the user writes), here the LLM writes the note entries. Use when the user says
  "take a note", "add a note", "note this", "scaffold notes", "list notes", or the
  /notes command. Trigger on: "notes", "research notes", "jot this down".
---

# Notes

A single running notes document the LLM administers. One file
(`Notes/notes.tex` or `Notes/notes.typ`), newest entries first, each a dated
section. LaTeX (default) or Typst — the format is fixed once Notes/ is scaffolded.

This skill dispatches on the action word in the request (mirrors the
`provenance` command):

## scaffold [--typst]

Create `Notes/` if it does not exist:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-notes.sh" [--typst] "<ProjectDir>" "<Title>" "<Author>"
```

LaTeX creates `Notes/{notes.tex, macros.sty, figures/, .latexmkrc}`; Typst
creates `Notes/{notes.typ, macros.typ, figures/}`. The running file carries an
end-marker where new entries are inserted:

- LaTeX: `% === notes below — newest first; LLM inserts dated sections here ===`
- Typst: `// === notes below — newest first; LLM inserts dated sections here ===`

If Notes/ is tracked (not gitignored), add the same build-artifact patterns as
scaffold-paper, scoped to `Notes/`.

## add "<topic / content>"

Append a new entry **directly below the end-marker** (newest first). The LLM
writes the entry — distill the user's request and the conversation into a clean,
self-contained note. Use today's date.

LaTeX:
```latex
\section{2026-05-29 — <topic>}
<note body: prose, math, \includegraphics from figures/, lstlisting, etc.>
```

Typst:
```typst
== 2026-05-29 — <topic>
<note body>
```

If Notes/ does not exist yet, scaffold it first (default LaTeX).

**Provenance:** an added note is a generated artifact. If the project's prompt
tracking toggle is on (see the `provenance` skill), follow its format — embed a
back-pointer comment in the entry and append a `Wiki/Prompts.md` ledger line.

## list (or no argument)

Read the running file and list the dated section headers as an index (most recent
first), so the user sees what notes exist.

## Rules for LLM

- **The LLM writes notes** — this is the opposite of scaffold-paper. Keep entries
  terse and self-contained; this is a research log, not a paper.
- Keep notation consistent with `macros.sty` / `macros.typ`; extend them freely.
- Never reorder or rewrite older entries unless asked — append at the marker.
- Put images/plots in `Notes/figures/`.
