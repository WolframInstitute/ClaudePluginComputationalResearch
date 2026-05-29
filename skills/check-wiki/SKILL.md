---
name: check-wiki
description: >
  Run a health check on the wiki. Finds stale articles, missing coverage,
  broken backlinks, and opportunities for cross-linking. Use at the start
  of a new session, or when the user says "check wiki", "wiki health",
  "audit wiki", "wiki status".
---

# Wiki Health Check

Audit the wiki for staleness, gaps, and broken links. Fix issues automatically
where possible; report what was fixed and what needs human attention.

## Prerequisites

`Wiki/` must exist. If it doesn't, suggest running init-wiki.

## Procedure

### 1. Load the wiki state

Read `Wiki/Index.md` to get the full article inventory. Read `Wiki/Status.md`
for current project context.

### 2. Check for stale articles

For each article in the index:

1. Read the article
2. Identify code files, functions, or entities it references
3. Check if those still exist and match the article's description
4. If stale: **update the article** to match current reality

Stale = article describes something that has changed, been renamed, removed,
or works differently than described.

### 3. Find missing articles

Scan the repo for entities that should have wiki coverage but don't:

- Code files with no corresponding article
- Functions/classes/modules not mentioned in any article
- Resources in `Wiki/Resources/` not indexed
- Notebooks not indexed

For each missing entity: **create** a wiki article and add it to the index.

### 4. Check cross-links

Scan all relative markdown links across all articles:

- If a link points to a nonexistent file: either create the article
  (if the entity exists) or remove the broken link
- If two articles are clearly related but not cross-linked: add the link

### 5. Check resources

For each `Wiki/Resources/*.md` file:

1. Verify the `## Recover` section exists and has a valid URL
2. Optionally test URL reachability (only if the user explicitly asks for deep check)
3. Flag resources with missing or malformed recover sections

### 6. Verify index completeness

Compare the files in `Wiki/` subdirectories against entries in `Wiki/Index.md`.
Every `.md` file (except Index.md, Status.md) should have an index entry.
Add missing entries.

### 7. Check work items

Read `Work/README.md` and scan `Work/*.md`. Flag any item with `Status: active`
whose `## Progress` has no recent session (or none at all) — it may be stalled.
Flag board rows whose "next task" no longer matches the first unchecked task.
Light check — report, don't auto-fix.

### 8. Report

Present a summary to the user:

```
Wiki Health Check:
- Articles checked: N
- Stale articles fixed: N (list)
- New articles created: N (list)
- Broken links fixed: N
- Missing index entries added: N
- Resource issues: N (list)
- Stalled work items: N (list)
```

If everything is clean: "Wiki is healthy. No issues found."

## When to run automatically

- Start of a new conversation/session (quick check)
- After a large refactor or code reorganization
- When the user asks for project status

For session-start checks, keep it fast: only scan the index and status,
don't deep-check every article. Flag anything suspicious for manual review.
