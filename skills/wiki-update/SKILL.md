---
name: wiki-update
description: >
  Update the wiki after a substantial change. Creates or updates articles,
  maintains the index, status, log, and backlinks. Use after any significant
  step — code changes, new functionality, completed tasks, discoveries.
  Triggers on: "update wiki", "log this", or automatically after substantial work.
  Also invoke proactively after completing any multi-step task.
---

# Wiki Update

After every substantial step, update the wiki to keep it accurate. The wiki is
documentation — update freely, no human sign-off needed for prose.

## Prerequisites

`Wiki/` must exist. If it doesn't, invoke the `wiki-init` skill first.

## What counts as "substantial"

- New code written or existing code changed
- A work item created, updated, or completed
- A resource added or analyzed
- A bug found and fixed
- A design decision made
- An experiment run and results obtained
- Any task completed from a work item

## Update procedure

### 1. Read current state

Read `Wiki/Index.md` to understand what articles exist and the wiki structure.
Skim `Wiki/Status.md` for current project state. You do NOT need to read every
article — only read the ones you'll modify.

### 2. Create or update articles

For each entity affected by the change:

- **New entity**: create `Wiki/<Folder>/<Name>.md` using the article format below
- **Changed entity**: update the relevant article's content to match current reality
- **Removed entity**: delete the article and remove its index entry

Article format:

```markdown
# Title

One-paragraph summary.

## Details

Body. Use subsections as needed.

## See also

- [Other Article](../Folder/OtherArticle.md) — why it's related
```

Keep articles concise and factual. Write like an encyclopedia, not a journal.

### 3. Update Wiki/Index.md

Add one-line entries for new articles. Remove entries for deleted articles.
Update summaries if they've changed. Entry format:

```markdown
- [Title](Folder/Name.md) — one-line summary
```

### 4. Update Wiki/Status.md

If the knowledge base changed (new results, articles, or open questions), update
the relevant sections. Execution state — active work and blockers — lives in
`Work/README.md`, not here:

```markdown
# Status

## Current state

Brief summary of where the project stands.

## Recent changes

- What changed recently in the knowledge base

## Open questions

- Unresolved questions worth surfacing
```

### 5. Add cross-links

In every article mentioned by or related to the changed articles, add a
relative markdown link in the "See also" section if not already present.
Links are bidirectional — if A references B, B should reference A.

Use standard markdown links with relative paths:
```markdown
- [Article Title](../Folder/Article.md) — why it's related
```

## What NOT to do

- Do not ask the user for permission to update wiki prose
- Do not create articles for trivial changes (typo fixes, formatting)
- Do not duplicate information across articles — cross-reference instead
- Do not add status headers to articles (that's what Status.md is for)
- Do not write in first person — write in neutral encyclopedic tone
