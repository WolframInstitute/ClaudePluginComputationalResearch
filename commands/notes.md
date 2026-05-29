Administer a running LaTeX or Typst notes document using the `notes` skill.

Notes live in a single running file (`Notes/notes.tex` or `Notes/notes.typ`),
newest entries first. Unlike scaffold-paper, the LLM writes the note entries.

Interpret `$ARGUMENTS`:

- `scaffold [--typst]` — create `Notes/` if absent (LaTeX by default; `--typst`
  for Typst) via `scaffold-notes.sh`.
- `add "<topic / content>"` — write a new dated section just below the file's
  end-marker (newest first), distilling the request into a clean note. Scaffold
  Notes/ first if it does not exist.
- `list` (or no argument) — list the dated section headers as an index.

Follow the format and rules defined in the `notes` skill. If the project's prompt
tracking toggle is on, follow the `provenance` format for the added entry.
