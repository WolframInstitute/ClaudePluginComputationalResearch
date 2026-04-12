---
name: wolfram-resources
description: >
  Search Wolfram ecosystem resources for a topic: documentation, Function
  Repository, Community forum, Stephen Wolfram's writings, and the Wolfram
  Physics Technical Introduction. Downloads notebooks, creates wiki articles,
  and logs findings. Use when the user says "search wolfram", "find wolfram
  resources", "wolfram community search", "what functions exist for X",
  "check the function repository", or during project setup when the user
  wants Wolfram-specific resource gathering.
---

# Wolfram Resource Search

Systematically search the Wolfram ecosystem for resources related to a topic.
This is a standalone skill — invoke it when the user wants to find what
Wolfram already offers for their subject. Not every project needs this; it's
for projects that build on or connect to the Wolfram Language ecosystem.

## What you need

1. **Topic / keywords** — what to search for. Can be a research topic
   ("discrete Ricci curvature"), a function area ("graph distances"), or
   a concept ("hypergraph rewriting").
2. **Project directory** (optional) — where to put downloaded resources.
   If Wiki/ exists, resources are registered via resource-add. If not,
   results are just reported.

## Sources

Run these scripts in parallel where possible. Skip any source that is
clearly irrelevant to the topic.

### 1. Wolfram Language Documentation

Find built-in functions, guides, and tutorials relevant to the topic.

**Script:**
```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_wolfram_docs.wls" <keyword1> <keyword2> ...
```

Returns JSON array of `{name, url, type}` where type is "symbol", "guide",
or "tutorial". All keywords must match (AND search) for symbol names. Guide
and tutorial results come from a web search of the documentation site.

**Also try:** `mcp__Wolfram__WolframLanguageContext` with topic keywords for
documentation context that includes usage patterns.

**Output:** Report the function list to the user. If Wiki/ exists, create
a wiki article `Wiki/Resources/WolframDocumentation_<Topic>.md` summarizing
the relevant functions and linking to their documentation pages.

### 2. Wolfram Function Repository

Search for community-contributed functions.

**Script:**
```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_function_repo.wls" <keyword1> <keyword2> ...
```

Returns JSON array of `{name, url, description}`. Uses `ResourceSearch`
internally, filtered to Function type. Falls back to web scraping if
`ResourceSearch` is unavailable.

**Output:** Report relevant functions. For each useful one, note the
`ResourceFunction["Name"]` call. Create wiki article if Wiki/ exists.

### 3. Wolfram Community

Search the community forum for posts, discussions, and shared notebooks.

**Script:**
```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_wolfram_community.wls" <keyword1> <keyword2> ...
```

Returns JSON with `{search_url, tag_url}`. The Community site is
JavaScript-rendered, so the script cannot scrape results directly. Use
**WebFetch** on the returned URLs to get the actual search results.

**What to extract from WebFetch results:**
- Post titles and URLs
- Attached `.nb` files (download to `Resources/`)
- Code snippets in post bodies

**Output:** For each relevant post:
- If it has a `.nb` attachment: download to `Resources/`, create wiki article
  via resource-add
- If no attachment: create wiki article with URL and summary
- Title-match posts to topic keywords; skip loosely related ones

### 4. Stephen Wolfram's Writings

Search blog posts and essays for relevant material.

**Script:**
```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_wolfram_writings.wls" <keyword1> <keyword2> ...
```

Returns JSON array of `{title, url, date}`. Titles are extracted from URL
slugs (lowercase, spaces).

**Output:** For highly relevant posts, create wiki articles with URL,
summary, and key takeaways. Skip tangentially related posts — Wolfram
writes about everything, so be selective.

### 5. Wolfram Physics Project

Only relevant if the project relates to Wolfram models, hypergraph rewriting,
multiway systems, causal graphs, or related concepts. Skip otherwise.

**Script:**
```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/search_wolfram_physics.wls" <keyword1> <keyword2> ...
```

Returns JSON with:
- `glossary` — matching glossary terms from wolframphysics.org/glossary/
- `archives` — matching bulletins and working materials
- `technical_documents` — matching technical papers (arXiv PDFs, Wolfram Cloud docs)
- `tools` — available software tools
- `urls` — direct page URLs for all subsections (glossary, archives, tools,
  questions, universes, visual gallery, technical introduction)

Use **WebFetch** on the `urls` for deeper exploration of specific subsections
(e.g., the full Technical Introduction, Q&A, universe registry).

## After searching

Present a summary to the user:

```
Wolfram Resource Search: <topic>

Documentation:
- N relevant built-in functions found (list top ones)

Function Repository:
- N relevant community functions found

Community:
- N relevant posts found, M notebooks downloaded

Writings:
- N relevant blog posts found

Technical Introduction:
- Relevant / Not relevant (sections if relevant)
```

Suggest which resources are most useful for the project and what to
explore next.

## Integration with other skills

- Use **resource-add** for each downloaded notebook or notable reference
- Update **Wiki/Index.md** if new articles were created
- If Paper/ exists and references were found, suggest adding citations
  to `Paper/references.bib`
