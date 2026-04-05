---
name: resource-add
description: >
  Add a resource (paper, repo, notebook, dataset, tool, web page) to the
  wiki. Downloads the file locally (gitignored), creates a wiki article
  with a Recover section for reproducibility, and updates the index.
  Use when the user says "add this paper", "save this resource", "note
  this repo", or when encountering a new reference during work. Also
  use during computational-exploration to register discovered papers
  and Wolfram Community resources.
---

# Resource Management

Resources have two layers:

1. **Wiki article** (`Wiki/Resources/Name.md`) — tracked in git, permanent.
   Contains citation, summary, and a machine-readable `## Recover` section.
2. **Local file** (`Resources/`) — gitignored, ephemeral. The actual PDF,
   repo clone, notebook, or dataset.

The wiki article is the source of truth. Local files can be rebuilt from
`## Recover` sections via `Scripts/recover_resources.sh`.

## Adding a resource

### Step 1 — Download (if applicable)

Create `Resources/` if it doesn't exist.

| Type | Action |
|------|--------|
| Paper (PDF) | Download to `Resources/Author_Year_ShortTitle.pdf` |
| arXiv paper | Use `mcp__arxiv__download_paper` → `Resources/` |
| Git repo | Clone to `Resources/RepoName/` or add as git submodule |
| Wolfram notebook | Download to `Resources/Author_Year_Title.nb` |
| Dataset | Download to `Resources/DatasetName.ext` |
| Web page | No download — just the URL |
| Tool/package | Download or note install command |

**Naming convention for files:**
- Papers: `Author_Year_ShortTitle.pdf` (first author last name, year, 2-4 word title)
- Notebooks: `Author_Year_ShortTitle.nb`
- Repos: directory name matching the repo name
- Other: descriptive name with extension

### Step 2 — Create wiki article

Write `Wiki/Resources/Name.md`:

```markdown
# Author Year — Short Title

Full citation. *Journal/venue*, volume, pages, year.

## Summary

What it is and why it matters to this project. Key results or contents.
2-3 paragraphs.

## Use in this project

How this resource connects to or supports the current work.

## Recover

Download: https://doi.org/...
Target: Resources/Author_Year_ShortTitle.pdf
```

#### Recover section variants

**Paper with DOI:**
```markdown
## Recover

Download: https://doi.org/10.1088/0951-7715/4/2/002
Target: Resources/Moore_1991_GeneralizedShifts.pdf
```

**arXiv paper:**
```markdown
## Recover

Download: https://arxiv.org/pdf/0810.5625
Target: Resources/Ollivier_2009_RicciCurvature.pdf
```

**Git repo:**
```markdown
## Recover

Clone: https://github.com/org/repo
Target: Resources/RepoName
```

**Wolfram Community notebook:**
```markdown
## Recover

Download: https://community.wolfram.com/...
Target: Resources/Author_Year_Title.nb
```

**Web page (no download):**
```markdown
## Recover

URL: https://example.com/page
```

**Tool/package:**
```markdown
## Recover

Install: pip install package-name
```

The `## Recover` section is machine-readable. Each line is `Key: Value`.
The recovery script parses these to rebuild `Resources/`.

### Step 3 — Update wiki

1. Add one-line entry to `Wiki/Index.md` under Resources:
   ```markdown
   - [Author Year — Short Title](Resources/Name.md) — one-line summary
   ```

2. Add cross-links to related articles' See also sections

3. Append to `Wiki/Log.md`:
   ```markdown
   | YYYY-MM-DD | LLM | Added resource: Author Year — Short Title |
   ```

### Step 4 — Read and summarize (if paper)

For papers specifically:

1. Use arXiv MCP tools to get abstract and sections if available
2. Read the PDF if downloaded (via MCP PDF reader or similar)
3. Write a substantive summary — not just the abstract, but key results,
   theorems, definitions that matter for the project
4. Note specific connections to the current work in "Use in this project"

## Batch resource addition

When adding multiple resources at once (e.g., during initial exploration):

1. Download all files first
2. Create all wiki articles
3. Add all index entries in one update
4. Log once with count: "Added N resources: [list]"

## Resource recovery

`Resources/` is gitignored. To rebuild from scratch:

```bash
Scripts/recover_resources.sh
```

The script:
1. Scans all `Wiki/Resources/*.md` files
2. Reads each `## Recover` section
3. Parses `Download:` lines → `curl` to `Target:` path
4. Parses `Clone:` lines → `git clone` to `Target:` path
5. Parses `Install:` lines → runs install command
6. Submodules recovered via `git submodule update --init --recursive`

**Git submodules:** When adding a repo that the project depends on at build time
(e.g., a Lean dependency, a Wolfram paclet), prefer `git submodule add` over a
plain clone. The submodule is tracked in `.gitmodules` and survives across clones.
Add a `!Resources/SubmoduleName/` exception to `.gitignore` so the submodule
directory isn't ignored. The Recover section uses `Submodule:` instead of `Clone:`:

```markdown
## Recover

Submodule: https://github.com/org/repo Resources/RepoName
```

For non-dependency repos (reference code, examples), a plain clone is fine.

## What counts as a resource

Anything external that informs or supports the project:
- Papers (PDFs)
- Git repos / submodules
- Notebooks (.nb, .ipynb)
- Datasets, spreadsheets
- Tools, packages, libraries
- Web pages, blog posts, documentation
- Emails, chat logs, slide decks
