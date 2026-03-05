---
name: list-topics
description: >
  List all topics in the current research project with short descriptions and
  the resource they come from. Scans Resources1.nb and notes*.tex files.
  Trigger when the user asks "what topics do we have", "list topics",
  "show me the topics", "what have we covered", or similar.
---

# List Project Topics

Scan the current research project for topics and present them as a formatted list.
Each topic should show its name, a short description, and which file it comes from.

## Sources to scan

### 1. Resources notebook (Resources1.nb or latest ResourcesN.nb)

Use `mcp__wolfram__list_cells` on the resources notebook to get all cells.
Extract every **Section** cell — each represents a resource (paper, community
notebook, or other reference). For the description, use the first Text cell
after the Section heading (typically contains the full title, authors, and year).

Format each as:
- **Topic**: the Section heading text
- **Description**: first sentence or line of the following Text cell
- **Source**: `Resources1.nb`

### 2. Notes files (Article/notes*.tex)

Read all `Article/notes*.tex` files. Extract every `\section{...}` title.
For the description, take the first sentence of the paragraph following the
section heading.

Format each as:
- **Topic**: the `\section{}` title
- **Description**: first sentence of the section body
- **Source**: the notes file name (e.g. `notes1.tex`)

## Output format

Present the results as a table:

| # | Topic | Description | Source |
|---|-------|-------------|--------|
| 1 | ... | ... | Resources1.nb |
| 2 | ... | ... | notes1.tex |

Group by source type: resources first, then notes. Number sequentially.

If no topics are found in a source, note that the source is empty or does not
exist yet.
