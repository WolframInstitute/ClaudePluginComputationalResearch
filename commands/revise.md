Run one revision round on a document using the `revise` skill, following its [round.md](../skills/revise/round.md).

The user has read the document where it lives — a notebook, a LaTeX or Typst paper, a Markdown file, code — and left comments on lines starting with `>>` (after the comment sign in code: `% >>`, `(* >>`, `// >>`, `<!-- >>`), and perhaps edited it by hand.
Write the next version beside the latest one, with the next number (`Note_260927_2.tex`, then `_3`), changing only what the comments ask and carrying everything else over verbatim, hand edits included.
Never edit the commented version; commit it as the user left it, then commit the new one.
A comment not acted on stays, followed by `>> not done: <reason>`.
For a notebook, the `.nb` is the source: rewrite only the commented cells through the Wolfram MCP, and never evaluate.

Then list each comment with what was done, and wait.

Pass the file as argument (e.g. `/revise Research/Artifacts/GeodesicPools_260919.nb`).
Without one, take the file changed since the last commit that holds comments; if there are several, ask.
