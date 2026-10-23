---
name: document-propose
description: >
  Maintain one concise research companion to a human-owned manuscript or
  paclet design. Use when the user asks for itemized proposals, mathematical
  statements, API suggestions, corrections, questions, citations, or updates to
  a manuscript's or design notebook's _notes companion. Preserve the human
  baseline and human corrections; put authorized lengthy investigations in
  linked topical artifacts rather than writing a replacement paper or design.
---

# Propose additions in the notes

## When to use

- The user asks for research or proposed improvements around an existing human paper or paclet design.
- The user asks to create or update its `_notes` companion.
- New requested work needs to be reconciled with existing companion proposals and human corrections.

## Steps

### 1. Read the baseline and corrections

Read current project guidance, the actual human source and its existing companion.
Follow [paper ownership](../paper-create/workflow.md) or [paclet design ownership](../project-create/paclet-design.md).
Use `document-setup` only if authority is unclear or setup is requested.
Do not infer that a proposal was accepted because it is old, appears in code or received no reply.
Read notebook content through notebook-aware tools, including direct human edits, rather than relying only on an older generated source.

### 2. Answer the requested question

Follow the human source's sections, notation, vocabulary and scope.
Use short mathematical sentences and itemized proposals, candidate statements, signatures, small examples, corrections, questions and citations.
State the hypotheses and distinguish cited background, an available argument, conjectures, computational observations and open problems.
Identify proof gaps and the limits of finite computations; do not label either as a theorem.
Cite sources actually read, with precise locations when available; do not imply novelty or source verification without evidence.
Do not add an unsolicited abstract, survey, polished replacement draft or unrelated direction.

### 3. Keep one companion

Update `<human-stem>_notes.<extension>` in place within the requested scope, preserving human corrections and unrelated content.
If no companion exists, create only the concise companion authorized by the research request, using the established document format.
Keep meaningful superseded material recoverable in the established `Archive/` when replacing it substantively.
Use optional `notes.tex` as a human/shared scratchpad, not another briefing; do not introduce competing `_llm` drafts or human/LLM folder trees.
Identify assistant contributions inside the companion where useful without changing human authorship of the baseline.

Link existing topical `Artifacts/` for details and state their proof or verification status.
Create a new detailed artifact only when requested or necessary for the authorized question; do not multiply deliverables automatically.
For each link, give the topic or result so the companion remains understandable without opening every artifact.

### 4. Maintain usability and report limits

Before saving, recheck that the baseline and companion have not changed; reconcile concurrent edits rather than overwriting them.
Use standard labels and build/reference mechanisms, with distinct document namespaces.
The assistant maintains references and notebook tooling; do not ask the author to run custom refresh scripts or promise unverified automatic freshness.
Check an edited open LaTeX document with its normal compiler and keep its editor open.
For `.nb` companions, preserve notebook edits and use actual editable notebook output; if tooling is unavailable, report the limitation without disguising text as a notebook.
Do not export or replace reading copies, upload, publish or change annotated Goodnotes copies merely because local notes changed.
Report the result, its status, relevant evidence and file links briefly.

## Integration with other skills

- `document-compare` supplies focused discrepancies; accepted changes still require the human's decision.
- `paper-cite`, resource skills and notebook tools support the requested work without changing its scope.
- Ownership policies take precedence over generic `document-revise` defaults that would automatically number every companion update or regenerate a notebook from stale Markdown.

## When NOT to use

- An explicit edit to the human manuscript itself: make only that authorized edit using its established workflow.
- A requested full alternative draft: keep it separately identified instead of replacing the concise companion.
- An ordinary code/build request with no research-companion update needed.
