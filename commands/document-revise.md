Run one revision round on a document using the `document-revise` skill, following its [round.md](../skills/document-revise/round.md).

The user has read the document where it lives — a notebook, a LaTeX or Typst paper, a Markdown file, code — and left notes in it as `<< … >>`, inside a line or over several lines (in code, inside a comment: `% << … >>`, `(* << … >> *)`, `// << … >>`), and perhaps edited it by hand.
First read the rules and the last two rounds in the document's provenance file, `<stem>.provenance.md`.
Write the next version beside the latest one, with the next number (`Note_260927_2.tex`, then `_3`), changing only what the notes ask, obeying the rules, and carrying everything else over verbatim, hand edits included.
Never edit the annotated version; commit it as the user left it, then commit the new one with the provenance file — never a `.nb`.
A note not acted on stays, followed by `<< not done: <reason> >>`.
For a notebook, the notes point at lines of its `.md`: write the change into `Name_k+1.md` first, convert only that passage through the Wolfram MCP, and never evaluate ([round.md § *Notebooks*](../skills/document-revise/round.md#notebooks)).

Then list each note with what was done, and each new rule, and wait.

Pass the file as argument (e.g. `/document-revise Research/Artifacts/GeodesicPools_260919.nb`).
Without one, take the file changed since the last commit that holds notes; if there are several, ask.
