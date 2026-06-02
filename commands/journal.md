Maintain an optional scientific journal using the `journal` skill.

The journal is a running LaTeX or Typst document (`Journal/journal.tex` or
`Journal/journal.typ`) — a concise, structured, append-only stream of dated
def/thm/rem/claim entries recording the math/physics content and main claims
established during research, with every resource cited into
`Journal/references.bib`. It is off by default, gated by a `Scientific journal`
toggle in the project's `CLAUDE.md`. Distinct from the Wiki (deduplicated
encyclopedia): the journal is the typeset, cited record of what was learned and when.

Interpret `$ARGUMENTS`:

- `on` / `off` — flip the toggle in `CLAUDE.md`. The first time it goes on,
  scaffold `Journal/` (LaTeX by default) if absent. `on (verbose)` captures per
  datum; plain `on` captures at conversational checkpoints, very concisely.
- `status` (or no argument) — report whether the journal is on, on (verbose), or off.
- `scaffold [--typst]` — create `Journal/` (with `entries/`) if absent (LaTeX by
  default; `--typst` for Typst) via `scaffold-journal.sh`.
- `add "<topic / content>"` — append a dated def/thm/rem/claim entry to today's
  day-file `Journal/entries/YYYY-MM-DD`, `\input`/`#include`-ed from the master
  (newest first), citing resources used into `Journal/references.bib`.
- `list` — list the dated section headers as an index.
- `show` — print or compile the current journal.

Follow the format and rules defined in the `journal` skill. The journal is a
record, not a deliverable — it is exempt from the revise loop (like wiki prose).
