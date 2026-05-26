Produce a BibTeX entry from an arXiv ID or DOI using the `cite-from-id` skill.

Recognized inputs: bare arXiv ID (e.g. `2301.00001`), old-style ID
(`math-ph/0501001`), arXiv URL, bare DOI (`10.xxxx/...`), or DOI URL.

Pass the identifier as the argument (e.g., `/cite-id 2301.00001` or
`/cite-id 10.1088/0951-7715/4/2/002`).

The skill shows the BibTeX entry to you first, then optionally appends to
`Paper/references.bib` if it exists, and/or creates a `Wiki/Resources/`
article via `resource-add`.

The general-purpose `cite` skill (without `-id`) is still available for
free-form citation lookup; use this command when you already have an
arXiv ID or DOI in hand.
