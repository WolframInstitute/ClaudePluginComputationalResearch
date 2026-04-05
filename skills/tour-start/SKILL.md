---
name: tour-start
description: >
  Start, resume, or manage a guided tour of the project. Creates an
  interactive walkthrough with narrative and runnable code for each topic.
  Use when the user says "start tour", "give me a tour", "continue tour",
  "where were we", "tour status", or when presenting the project to someone.
---

# Guided Tour

An interactive walkthrough of the project. Each section has narrative (what
it is, why it matters) and runnable code (demonstrations, experiments).
The LLM stops after each section for user feedback — this is the revision
loop applied to presentation.

## Prerequisites

`Wiki/` must exist with articles to tour. If the wiki is empty, suggest
running `wiki-init` and populating it first.

## Tour structure

```
Tour/
  Tour.md          plan + position + progress
  Sections/        one .md per section (narrative)
  Code/            one file per section (runnable code)
```

`Tour/` is gitignored — it's local, on-demand state.

## Starting a new tour

### 1. Create Tour/ directory

If `Tour/` doesn't exist, create it with `Sections/` and `Code/` subdirectories.

### 2. Generate the tour plan

Read `Wiki/Index.md` and `Wiki/Status.md` to understand the project. Order
topics from simplest → most complex (prerequisites first). Write `Tour/Tour.md`:

```markdown
# Tour Plan

## Sections

1. [ ] Topic A — one-line summary
2. [ ] Topic B — one-line summary
3. [ ] Topic C — one-line summary

## Position

Current section: 1
Last interaction: YYYY-MM-DD

## Log

| Date | Section | Action |
|---|---|---|
| YYYY-MM-DD | — | Tour plan created |
```

### 3. Present the plan

Show the section list to the user. Wait for feedback — they may want to
reorder, skip topics, or add sections.

### 4. Generate and present sections one at a time

For each section:

1. **Generate narrative**: `Tour/Sections/NN_Name.md`
   - What it is (definitions, context)
   - Why it matters (motivation, connections)
   - Key results or properties
   - Links to source files and wiki articles

2. **Generate code**: `Tour/Code/NN_Name.wl` (or `.py`, `.lean`, etc.)
   - Self-contained, runnable
   - Demonstrates the key concepts
   - Includes comments for presentation context

3. **Present to user**:
   > "Section N: [Topic]. Narrative in `Tour/Sections/NN_Name.md`,
   > code in `Tour/Code/NN_Name.wl`. Any feedback before we move on?"

4. **Wait for response**:
   - Approve → mark `[x]`, update position, advance
   - Revise → update files, re-present
   - Skip → mark `[-]`, advance
   - Stop → save position, end session

5. **Update Tour.md** after each interaction (position, log entry)

## Resuming a tour

If `Tour/Tour.md` exists, read it to find the current position. Tell the
user where they left off and continue from there:

> "Welcome back. Last time we covered [Topic N]. Ready for section N+1:
> [Next Topic]?"

## Tour section format

### Narrative (Sections/NN_Name.md)

```markdown
# Section N: Topic Name

## Overview

What this is and why it matters. 2-3 paragraphs.

## Key concepts

- Concept A — brief explanation
- Concept B — brief explanation

## In the codebase

- `Code/File.wl` — what it contains
- `Wiki/Domain/Article.md` — deeper reading

## Try it

Run `Tour/Code/NN_Name.wl` to see [what the code demonstrates].
```

### Code (Code/NN_Name.wl)

Self-contained Wolfram Language file (or whatever language the project uses).
Should run without errors and produce visible output (plots, printed results,
tables). Include brief inline comments for presentation context.

## Tour.md updates

After each section interaction, update:

- The checkbox: `[ ]` → `[x]` (or `[-]` for skipped)
- Position: `Current section: N+1`
- Last interaction date
- Log table entry

```markdown
| YYYY-MM-DD | N | Presented, user approved |
| YYYY-MM-DD | N | Presented, user revised: changed code example |
| YYYY-MM-DD | N | Skipped by user |
```
