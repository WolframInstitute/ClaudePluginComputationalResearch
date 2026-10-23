---
name: document-setup
description: >
  Locate the current human-owned paper or paclet design and its concise notes
  companion, or establish that pair during requested setup. Use when the user
  asks to set up human-led paper/design collaboration, select the current
  manuscript or design iteration, or identify which design implementation
  should follow. Do not use ordinary research or build requests to invent a
  new human iteration.
---

# Establish the human baseline

## When to use

- The user asks which manuscript or paclet design is current, or asks to establish this collaboration workflow.
- A requested setup needs an initial human design and companion.
- Existing guidance points to conflicting baselines that must be resolved before dependent work.

## Steps

### 1. Find the authority

Read project guidance, the user's selected source and any recorded current paths.
Follow [paper ownership](../paper-create/workflow.md) for manuscripts and [paclet design ownership](../project-create/paclet-design.md) for repositories.
An explicit user selection takes precedence over an older recorded pointer.
Do not choose authority by timestamp, highest number or the newest assistant output.
If the intended baseline remains ambiguous, ask one focused question and continue only independent work.
Finding the pair is read-only unless setup or a pointer change was requested.

### 2. Read the actual documents

Read the current human source and existing companion before suggesting content.
Use notebook-aware reading for `.nb` files; a generated Markdown source may omit subsequent human notebook edits.
Identify the existing section order, terminology, notation and scope.
Preserve established locations and formats.

### 3. Establish only what was requested

During authorized setup, create a minimal missing pair in the established format without overwriting existing work.
For a paper, use its actual stem, for example `liebracket1.tex` with `liebracket1_notes.tex`.
For a paclet, place `<PacletName>1.nb` and `<PacletName>1_notes.nb` in the repository root beside the paclet folder, using the actual paclet name.
Preserve existing human notebooks and their recorded paths unless relocation is explicitly requested.
Use actual editable Wolfram notebooks, not renamed text or PDF files.
The human source starts as a minimal editable skeleton informed by the user's input; proposed theory belongs in the companion.
Record the selected current paths in project `AGENTS.md` and `CLAUDE.md` during requested setup or selection, when the documents exist and the selection is established.
Do not treat a scaffold's empty headings as accepted mathematical or API decisions.

Only an explicit request to start the next human iteration authorizes doing so.
Preserve the previous iteration and use the human-selected starting text; never promote all companion proposals by default.
A routine paclet build proceeds without requiring a missing design notebook to be created first.

### 4. Report the pair

Give links to the current human source and companion, and state whether they were found or created.
Mention unresolved authority or unavailable notebook tooling precisely, without claiming a pair was established when it was not.
Do not add another status document, journal or full alternative draft.

## Integration with other skills

- `paper-create` and `project-create` supply authorized scaffolding; this skill does not scaffold an unrelated project.
- `notebook-create` supplies notebook mechanics subject to the ownership policies above; never regenerate over direct human notebook edits.
- `document-propose` maintains the concise companion; `document-compare` checks divergence.

## When NOT to use

- An ordinary build or small code edit with an already clear baseline.
- A request for research that does not ask to reorganize the project or advance its human iteration.
- Creating a second competing human design or an automatic next iteration.
