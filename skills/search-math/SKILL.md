---
name: search-math
description: >
  Search external mathematics resources for a topic: MathWorld, nLab, OEIS,
  DLMF, and Wikipedia math articles. Returns ranked results, optionally
  hands them to add-resource. Use when the user says "search math",
  "find on MathWorld", "look up in nLab", "OEIS sequence", "DLMF formula",
  "search Wikipedia math", or during math-research project setup when
  external math sources are needed.
---

# Math Resource Search

Companion to [search-wolfram](../search-wolfram/SKILL.md) — searches
external (non-Wolfram-ecosystem) mathematics resources. Use it whenever a
math-research project needs to anchor a concept against authoritative external
references.

## What you need

1. **Topic / keywords** — what to search for. Concept ("Lie algebra"),
   theorem ("Stokes theorem"), object ("Bessel function"), sequence
   ("Fibonacci numbers"), or named entity ("Galois theory").
2. **Project directory** (optional) — for logging results into `Wiki/` if it
   exists.

## Sources

Run scripts **in parallel**. Skip any source that is clearly irrelevant
(e.g. skip OEIS for a non-discrete topic).

### 1. MathWorld

Wolfram MathWorld — large encyclopedia, classical math through research math.

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_mathworld.wls" <keyword1> <keyword2> ...
```

Returns JSON array of `{name, url, snippet}`. The script scrapes the search
page for entry links matching `mathworld.wolfram.com/<EntryName>.html`. Names
are derived from CamelCase slugs.

### 2. nLab

Category-theoretic and higher-structures wiki. Best for category theory,
homotopy theory, algebraic geometry, mathematical physics.

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_nlab.wls" <keyword1> <keyword2> ...
```

Returns JSON array of `{name, url, snippet}`. Filters out archival
"YYYY Month changes" pages.

### 3. OEIS

Online Encyclopedia of Integer Sequences — only relevant when an integer
sequence appears.

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_oeis.wls" <keyword1> <keyword2> ...
```

Returns JSON array of `{anum, name, sequence, url}`. `anum` is the A-number
(e.g. `A000045`). `sequence` is the first ~120 chars of the data row.

You can also query by **first terms**:

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_oeis.wls" 1 1 2 3 5 8 13 21
```

### 4. DLMF

NIST Digital Library of Mathematical Functions — authoritative for special
functions, asymptotics, identities.

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_dlmf.wls" <keyword1> <keyword2> ...
```

Returns JSON array of `{name, url, location}`. `location` is the DLMF locator
(e.g. `10.2#E5` is chapter 10, section 2, equation 5).

### 5. Wikipedia math

Filtered Wikipedia search — uses the MediaWiki search API and ranks results
by math-keyword overlap and presence of LaTeX markers in snippets.

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_wikipedia_math.wls" <keyword1> <keyword2> ...
```

Returns JSON array of `{title, url, snippet}`.

## After searching

Present a single combined summary, grouped by source:

```
Math Resource Search: <topic>

MathWorld:   <n> entries
- <name> — <url>

nLab:        <n> entries
- <name> — <url>

OEIS:        <n> sequences
- A000045 — Fibonacci numbers — <url>

DLMF:        <n> formulas
- 10.2#E5 — <url>

Wikipedia:   <n> articles
- <title> — <url>
```

Then ask the user **which to keep**. For each kept result:

1. If `Wiki/` exists: invoke [add-resource](../add-resource/SKILL.md) with the
   URL — add-resource will recognise the URL pattern and create the right kind
   of wiki article (MathWorld / nLab / OEIS / DLMF / Wikipedia).
2. If no `Wiki/`: just print the URLs as references the user can keep.

## Integration with other skills

- Pair with [search-wolfram](../search-wolfram/SKILL.md) when the project
  also touches Wolfram-ecosystem material.
- Pair with [cite](../cite/SKILL.md) to immediately produce a
  BibTeX entry for any DOI/arXiv ID surfaced (e.g. references inside a
  MathWorld or Wikipedia article).
- Pair with [add-resource](../add-resource/SKILL.md) to commit kept results
  to `Wiki/Resources/`.

## When NOT to use

- Pure Wolfram-ecosystem questions → use [search-wolfram](../search-wolfram/SKILL.md).
- Looking for a specific paper (arXiv / DOI / title) → use the existing arXiv MCP
  and [cite](../cite/SKILL.md).
- Reading an already-added paper → use `mcp__arxiv-latex-mcp` or `mcp__arxiv__read_paper`.
