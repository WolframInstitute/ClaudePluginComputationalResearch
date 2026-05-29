---
name: cite
description: >
  Produce a BibTeX/biblatex entry from an arXiv ID or DOI. Optionally appends
  to Paper/references.bib if it exists. Use when the user says "cite this",
  "bibtex for arXiv:...", "DOI 10.xxx/...", "add citation", or when adding a
  reference during paper writing.
---

# Cite

Thin wrapper around [scripts/cite_from_id.wls](../../scripts/cite_from_id.wls)
that takes an identifier (arXiv ID, DOI, or URL containing either) and emits
a BibTeX entry. Optionally appends to `Paper/references.bib` and creates a
wiki article via [add-resource](../add-resource/SKILL.md).

## Recognized inputs

| Input | Example |
|-------|---------|
| New-style arXiv ID | `2301.00001` |
| Old-style arXiv ID | `math-ph/0501001` |
| arXiv URL | `https://arxiv.org/abs/2301.00001` |
| `arXiv:` prefixed | `arXiv:2301.00001` |
| Bare DOI | `10.1088/0951-7715/4/2/002` |
| DOI URL | `https://doi.org/10.1088/...` |
| `doi:` prefixed | `doi:10.1088/...` |

## Workflow

### Step 1 — Run the script

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/cite_from_id.wls" <identifier>
```

Output is a BibTeX entry on stdout. For arXiv inputs the entry is built from
the arXiv Atom API and includes `title`, `author`, `year`, `eprint`,
`archivePrefix`, `url`, and `abstract`. For DOI inputs the entry is fetched
from Crossref's `application/x-bibtex` content negotiation.

### Step 2 — Show the entry to the user

Always show the raw BibTeX before writing anywhere. The user may want to
edit the key, trim the abstract, or fix author casing.

### Step 3 — Decide where it goes

Ask the user (or infer from context):

- **`Paper/references.bib`** — if a Paper/ directory exists and the
  citation is for the paper being written. Append at end, **after** checking
  the key is not already present (`grep` first).
- **`Wiki/Resources/<Key>.md`** — if the citation deserves a full wiki
  article (will be summarised). Invoke [add-resource](../add-resource/SKILL.md)
  with the BibTeX and the URL.
- **Stdout only** — when the user is just looking up a citation in
  conversation.

## Batch mode

If the user supplies multiple identifiers (newline- or comma-separated),
run the script once per identifier, collect all BibTeX entries, **deduplicate
keys** (suffix `a`, `b`, ... if collisions occur), then write the batch.

## Failure handling

- arXiv fetch fails → script prints `% arXiv fetch failed for <id>`. Do not
  write a broken entry. Tell the user the ID couldn't be resolved.
- Crossref fetch fails → script prints `% Crossref fetch failed for <doi>`.
  Same: do not write.
- Identifier looks like neither arXiv nor DOI → script exits non-zero with
  `% Could not classify identifier`. Ask the user for a corrected ID.

## Integration with other skills

- [add-resource](../add-resource/SKILL.md) — for full wiki articles instead
  of just BibTeX.
- [search-math](../search-math/SKILL.md) — surfaces references from
  MathWorld / Wikipedia that often have DOIs; pipe those DOIs into this skill.
- [scaffold-paper](../scaffold-paper/SKILL.md) — produces the `Paper/references.bib`
  this skill appends to.
