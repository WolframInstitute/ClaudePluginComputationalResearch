---
name: paper-cite
description: >
  Produce a BibTeX/biblatex entry from an arXiv ID or DOI. Optionally appends
  to Research/references.bib if it exists. Use when the user says "cite this",
  "bibtex for arXiv:...", "DOI 10.xxx/...", "add citation", or when adding a
  reference during paper writing.
---

# Cite

Use [scripts/citation_common.wl](../../scripts/citation_common.wl) to turn an identifier (arXiv ID, DOI, or URL containing either) into a BibTeX entry in the persistent MCP kernel.
The CLI wrapper [scripts/cite_from_id.wls](../../scripts/cite_from_id.wls) uses the same function for fallback and batch runs.
Optionally appends to `Research/references.bib` and creates a wiki article via [wiki-add-resource](../wiki-add-resource/SKILL.md).

## When to use

- The user says "cite this", "bibtex for arXiv:...", "DOI 10.xxx/...", "add citation".
- A reference is added during paper writing, journal entries, or `paper-create-notebook` literature sections.

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

## Kernel execution (license-aware)

Prefer `mcp__Wolfram__WolframLanguageEvaluator`: load the shared helper and call it in the existing kernel, with no new license seat.
Use `wolframscript` only when MCP is unavailable or for an explicitly chosen bulk batch run, after checking license headroom per [`CLAUDE.md` § *Wolfram Kernel Execution Policy*](../../CLAUDE.md#wolfram-kernel-execution-policy).
With no free seat, use the MCP; if it is unavailable, report the limitation instead of spawning another kernel.

## Steps

### 1. Fetch the entry through the MCP

Resolve `${CLAUDE_PLUGIN_ROOT}` to its absolute path, then evaluate:

```wolfram
Get["${CLAUDE_PLUGIN_ROOT}/scripts/citation_common.wl"];
citationFromIdentifier["<identifier>"]
```

The helper localizes its working variables and internal functions and returns a BibTeX string or `Failure`; it never prints, exits the kernel or writes project files.
Do not `Get` the CLI wrapper in the persistent kernel: that wrapper owns process exit handling.
For arXiv inputs the entry is built from the arXiv Atom API and includes `title`, `author`, `year`, `eprint`, `archivePrefix`, `url`, and `abstract`.
For DOI inputs the entry is fetched from Crossref's `application/x-bibtex` content negotiation.

Only for the license-checked fallback or chosen batch path:

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/cite_from_id.wls" "<identifier>"
```

The wrapper prints the entry to stdout, or a `%` error line with a nonzero exit status.

### 2. Show the entry to the user

Always show the raw BibTeX before writing anywhere.
The user may want to edit the key, trim the abstract, or fix author casing.

### 3. Decide where it goes

Ask the user (or infer from context):

- **`Research/references.bib`** — if a paper is in `Research/` (a `Paper/` folder in an older project) and the citation is for the paper being written; with a paper in its own subfolder, that paper's own `references.bib`.
  Append at end, **after** checking the key is not already present (`grep` first).
- **`Journal/references.bib`** — if a `Journal/` directory exists and the citation supports a journal entry (see the [paper-journal](../paper-journal/SKILL.md) skill).
  Append at end, after `grep`-checking the key is not already present, as for the paper.
- **`Wiki/Resources/<Key>.md`** — if the citation deserves a full wiki article (will be summarised).
  Invoke [wiki-add-resource](../wiki-add-resource/SKILL.md) with the BibTeX and the URL.
- **Stdout only** — when the user is just looking up a citation in conversation.

## Batch mode

If the user supplies multiple identifiers (newline- or comma-separated), call the shared helper once per identifier in the existing MCP kernel by default.
Collect successful entries, report failures, and **deduplicate keys** (suffix `a`, `b`, ... if collisions occur) before any authorized batch write.
Use the CLI only under the fallback/batch conditions above, checking headroom before each fresh process.

## Failure handling

- arXiv fetch fails or returns incomplete metadata → the helper returns `Failure`; the CLI prints a `%` error line and exits nonzero.
  Do not write a broken entry.
  Tell the user the ID couldn't be resolved.
- Crossref fetch fails → the helper returns `Failure`; the CLI prints `% Crossref fetch failed for <doi>` and exits nonzero.
  Same: do not write.
- Identifier looks like neither arXiv nor DOI → the helper returns `Failure`; the CLI exits nonzero with `% Could not classify identifier`.
  Ask the user for a corrected ID.

## Integration with other skills

- [wiki-add-resource](../wiki-add-resource/SKILL.md) — for full wiki articles instead of just BibTeX.
- [wiki-search-math](../wiki-search-math/SKILL.md) — surfaces references from MathWorld / Wikipedia that often have DOIs; pipe those DOIs into this skill.
- [paper-create](../paper-create/SKILL.md) — produces the `Research/references.bib` this skill appends to.
- [paper-journal](../paper-journal/SKILL.md) — owns `Journal/references.bib`; cite into it the same way as into a paper.

## When NOT to use

- The resource needs a full wiki article with a `## Recover` section — that is `wiki-add-resource`.
- No identifier exists (a blog post, a web page) — cite by URL in prose instead of fabricating an entry.
