Produce a BibTeX entry from an arXiv ID or DOI using the `cite` skill.

Recognized inputs: bare arXiv ID (e.g. `2301.00001`), old-style ID (`math-ph/0501001`), arXiv URL, bare DOI (`10.xxxx/...`), or DOI URL.

Pass the identifier as the argument (e.g., `/cite 2301.00001` or `/cite 10.1088/0951-7715/4/2/002`).

The skill shows the BibTeX entry to you first, then optionally appends to `Paper/references.bib` if it exists, and/or creates a `Wiki/Resources/` article via `add-resource`.

The general-purpose `cite` skill (without `-id`) is still available for free-form citation lookup; use this command when you already have an arXiv ID or DOI in hand.
