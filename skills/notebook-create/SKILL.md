---
name: notebook-create
description: >
  Create Wolfram notebooks from Markdown, edit saved .nb files through
  notebook-aware tools, or export requested Markdown without changing the
  notebook. Use for "create notebook", "edit notebook", "update notebook",
  "put this in a notebook", and notebook/Markdown conversion. Preserve direct
  human edits, metadata and established paper or paclet design paths.
  Other skills use the creation pipeline when generating new notebook cells.
---

# Wolfram Notebook Pipeline

Choose the operation before converting anything:

- **Create from Markdown:** use the generation pipeline below for a new notebook or new cells.
- **Edit an existing `.nb`:** inspect and patch the saved notebook with native tools; read [editing.md](editing.md).
- **Export Markdown:** read [editing.md § Markdown export](editing.md#markdown-export); this writes only the requested export and never rebuilds the `.nb`.

For human papers and paclet designs, [paper ownership](../paper-create/workflow.md) and [paclet design ownership](../project-create/paclet-design.md) take precedence over generated-artifact conventions.
Read the actual human notebook and companion, preserve their names and locations, and edit only within the authorized scope.
The human controls integration and the next numbered iteration; a `_notes.nb` companion is maintained in place while preserving human corrections.

The creation technique, when a Markdown source is appropriate:

```
ExportString[ImportString[markdownString, {"Markdown", "Notebook"}], "NB"]
```

Markdown is imported as a Notebook expression, post-processed, then serialized with `ExportString` for writing to the selected local path.
This is a creation pipeline, not a reversible editor for existing notebook content.

Read only the references the operation needs:

- [pipeline-builtin.md](pipeline-builtin.md) — post-processing + the complete built-in-engine MCP call (the canonical copy of `boxifyInputCells`, `markInitCells`, `addLLMSubtitle`)
- [pipeline-rich.md](pipeline-rich.md) — what rich mode changes, the parser-degradation probe, the rich-mode MCP call
- [templates.md](templates.md) — the named templates (`research`, `paper-analysis`, `computation`, `theorem-proof`)
- [markdown-mapping.md](markdown-mapping.md) — markdown-to-cell mapping, long-notebook pattern, content best practices
- [editing.md](editing.md) — native editing, faithful per-cell source write-back, and export-only Markdown

## When to use

- The user says "create notebook", "make a notebook", "notebook about X", "edit notebook", "update notebook", "put this in a notebook", "generate .nb".
- Another skill produces notebook cells (`project-create`, `project-tour`); its ownership and document-role rules still apply.

## Hard Rules

- Do not load a raw `.nb` into the context with the `Read` tool.
  Use native notebook reading or inspect selected cells and options from `Import[path, "NB"]` in the Wolfram kernel; do not evaluate cell contents while inspecting them.
- Preserve the saved notebook's cells, grouping, options, tags, styles and author metadata outside the requested change.
  Never replace it with a Markdown round-trip or regenerate over unreconciled human edits.
- Confirm where the MCP can read and write.
  When its filesystem is separate from the user's workspace, use `ExportString[..., "NB"]` and a local write rather than assuming a kernel-side `Export` updated the user's file.
  If the saved notebook cannot be inspected and preserved with available tooling, report that limit and leave it intact.

## Kernel execution (license-aware)

This skill runs entirely on the AgentTools MCP (`mcp__Wolfram__WriteNotebook`, `mcp__Wolfram__ReadNotebook`, `mcp__Wolfram__WolframLanguageEvaluator`) — one persistent kernel, no extra license seat.
The batch `Scripts/generate_notebooks.wls` / `Scripts/publish_notebooks.wls` helpers each spawn a fresh `wolframscript` kernel and are a fallback for bulk runs only — check headroom first per the authoritative policy in [`CLAUDE.md` § *Wolfram Kernel Execution Policy*](../../CLAUDE.md#wolfram-kernel-execution-policy); with no free seat, generate notebooks one at a time through the MCP.

## Where notebooks live — Critical

Preserve an existing document's path and any explicit destination.
Human manuscripts and design notebooks are not relocated into `Code/Artifacts/`.
For a paclet, use the current `<PacletName>N.nb` and `<PacletName>N_notes.nb` in the repository root beside the paclet folder.

For a new notebook about the project's code, `Code/` holds a requested document in progress and `Code/Artifacts/` holds a one-off (the default when the request does not specify).
Read [artifacts.md](artifacts.md) for the topic index and archive convention, subject to the ownership rules above.
An authorized in-place edit does not require a new dated artifact or a new human iteration.

## Markdown-backed generation

For a new generated artifact, source and output share one dated stem:

```
Code/Artifacts/README.md               the index
Code/Artifacts/Name_YYMMDD.md           generation source
Code/Artifacts/Name_YYMMDD.nb           generated notebook
```

This arrangement applies when the chosen source can express the requested content.
A human-edited `.nb` is not disposable: preserve its direct edits and reconcile any supporting source before considering regeneration.
Follow the project's tracking policy; exclude a generated notebook from Git only while it is reproducible without losing human content or metadata.
These are not wiki articles.

Keep the same stem for a correction rather than adding a second date.
A full rebuild of an existing generated notebook requires an implemented and verified complete [drift check](../paper-create-notebook/fingerprint.md), reconciled source, and the requested scope; a missing or legacy stamp does not establish that overwriting is safe.
The fingerprint reference specifies a contract rather than shipping a complete verifier; absent a verified implementation, preserve the saved notebook and use native edits, unless its replacement was explicitly authorized with its original retained.
Otherwise use targeted notebook edits.
A substantive revisit may be a new dated artifact, with the earlier work preserved in `Archive/`.

Use Markdown for a new artifact meant to be regenerated, or create a native notebook directly when no source layer is needed.
Do not invent a Markdown source for an existing notebook merely to make it fit the pipeline.
A new source follows [markdown-mapping.md](markdown-mapping.md); source and output use the same stem even when that stem is an author-selected numbered name.
Add an index row only for a newly created artifact, not for a root-level design pair or an existing human document.

Batch scripts are generation-only fallbacks, subject to the same preservation checks.
Do not run a folder-wide generator against existing notebooks with unchecked human edits, or a publisher without scoped publication authorization.

## Provenance (optional)

If the project has prompt tracking on (a `Prompt tracking: **on**` line in `CLAUDE.md` — see the [project-provenance](../project-provenance/SKILL.md) skill), record the originating prompt/intent for the notebook:

1. Write a leading `<!-- provenance: ... -->` comment at the top of the `Code/Artifacts/Name_YYMMDD.md` source.
2. Inject it into the `.nb` on the MCP path yourself:
   build `prov = <| "intent" -> ..., "date" -> ..., ... |>` from the comment's fields,
   strip the comment from the markdown string before conversion (the built-in importer drops HTML comments, but the rich parser is not guaranteed to), replacing its lines by empty lines so the cells' source lines stay the file's,
   and stamp the notebook expression just before `ExportString` with the `stampTaggingRule` merge helper from the [project-provenance](../project-provenance/SKILL.md) skill.
   `TaggingRules` is a shared slot — `paper-create-notebook`'s fingerprint key lives there too — so merge by key; never write a literal `TaggingRules -> {...}` that replaces the option.
   In the built-in call this wraps the final expression: `ExportString[ stampTaggingRule[ ReplacePart[nb, 1 -> cells], "Provenance" -> prov ], "NB" ]`;
   in the rich-mode call apply it to `ReplacePart[nb, 1 -> cells]`, which it leaves option-complete (the helper preserves `CreateCellID` and `StyleDefinitions`).
3. On the batch fallback path only, skip step 2: `generate_notebooks.wls` strips the comment and injects the `TaggingRules` itself.
4. Append an entry to the `Wiki/Prompts.md` ledger.

When tracking is off (default), skip this — generate the notebook as usual.

## Which MCP tool to use

- **Official MCP with notebook tools** (preferred): use the supported `ReadNotebook` / `WriteNotebook` operations for focused reading and edits only when they preserve the required content and options; inspect their actual schemas rather than assuming a cell-patching interface.
- **Evaluator:** inspect and patch a saved Notebook expression, preserving untouched expressions and options, or generate new cells from Markdown.
  The Markdown pipeline is `ExportString[ImportString[md, {"Markdown", "Notebook"}], "NB"]`; it is not the existing-notebook editing path.
- **Unofficial MCP** (`mcp__wolfram__`): use its LSP tools (hover_info, find_definition, find_references, get_diagnostics, document_symbols) for code navigation only; do not use its notebook-manipulation tools when the official MCP is available.
- **No notebook tooling:** a minimal new native `.nb` skeleton may be written when its structure is understood; do not claim that complex formulas or an existing notebook were preserved without verification.
  Leave an existing file intact if it cannot be read and safely edited.

To check availability: evaluate `1+1` with the official MCP.

## Conversion engine — built-in vs rich

Two engines convert Markdown to cells: the built-in `ImportString[md, {"Markdown", "Notebook"}]` ([pipeline-builtin.md](pipeline-builtin.md)) and the **rich** [`WolframInstitute/MarkdownToNotebook`](https://github.com/WolframInstitute/MarkdownToNotebook) parser ([pipeline-rich.md](pipeline-rich.md)), which carries constructs the built-in importer mangles or drops.

Engine choice is **auto-detected from the source**, not configured.
Decide in this order:

1. **Is the clone present?**
   Rich mode needs `MarkdownToNotebook/MarkdownToNotebook.wl` at the project root.
   If it is absent, use the built-in engine and tell the user rich mode was skipped, with the clone command from the wiki article.
   Never clone it silently — that is unrequested network I/O.
2. **Does the source need it?**
   Use the rich engine when the source has **YAML frontmatter** (a `---` first line) or **LaTeX math** (`$$…$$` or `$…$`).
   Those are exactly the constructs the built-in engine gets wrong: frontmatter leaks in as a literal `Text` cell, and math comes back as flat `InlineMath` rather than real boxes.
3. **Otherwise** use the built-in engine.

A source with neither frontmatter nor math gains little from rich mode, so plain sources keep the cheaper path and the smaller dependency surface.

Fixed conversion settings, either engine:

- **`"Evaluate" -> False`** for Markdown conversion.
  New cells ship unevaluated unless the requested output explicitly includes checked outputs; editing does not automatically authorize running the notebook.
- **`Template: Default`** — the default when frontmatter omits it, and the only template this skill uses.
  The documentation templates (`Symbol`, `Guide`, `TechNote`, `Paclet`) belong to [paclet-docs](../paclet-docs/SKILL.md), which uses the official MCP doc tools instead.
- **Pin by SHA, call the local file.** Load the clone with `Get`, never the deployed cloud resource: that resource lives on a personal `obj/nikm/` path and reports no `"Version"`, so drift is undetectable.

## Backtick escaping — Critical

The Wolfram MCP interprets raw backtick characters as Wolfram context marks.
Triple-backtick fences in markdown strings get corrupted if written as literal characters.

**Always construct backticks via `FromCharacterCode`:**

```
tick = FromCharacterCode[96];
fence = StringJoin[tick, tick, tick];
```

Then use `fence` when building the markdown string:

```
md = "# Title\n\n" <> fence <> "wolfram\nPlot[Sin[x],{x,0,2Pi}]\n" <> fence <> "\n\n";
```

For inline code, use a single `tick`.
For Wolfram package names containing context marks (e.g., `"Needs[\"MyPackage`\""]`), use:
```
"Needs[\"MyPackage" <> tick <> "\"]"
```

This is the single most important rule.
Without it, code blocks will not parse as Input cells.

Always build markdown with `StringJoin` using `fence` and `tick` variables; the other escapes are the usual `\` → `\\`, `"` → `\"`, newlines as `\n`.

## Steps

Creating a new notebook:

1. Select the document role, authorized path and name before composing content.
2. Compose Markdown per [markdown-mapping.md](markdown-mapping.md) when it suits the output, or use native cells.
3. Convert only the new content and apply the role-appropriate generation passes ([pipeline-builtin.md](pipeline-builtin.md) or [pipeline-rich.md](pipeline-rich.md)).
4. Write to the selected path without clobbering an existing file, then re-read it with notebook-aware tooling.
   Check the actual cells, math, options and metadata relevant to the result; file size and cell count alone do not establish fidelity.

For an existing notebook, read [editing.md](editing.md) and patch the requested cells or options in the saved notebook.
Keep its editor open when available, preserve unrelated cells and metadata, and reconcile supporting sources only where faithful conversion is available.
A specifically requested versioned revision uses [round.md](../document-revise/round.md#notebooks); ordinary edits and companion updates do not automatically create another version.

For a Markdown-export request, use the separate export procedure in [editing.md](editing.md#markdown-export).
Do not feed that export back into the original `.nb`.

## Claude Desktop / VM mode

When running inside a VM (Claude Desktop Projects or sandboxed environment):

- Confirm that a shared folder exists and is accessible
- The `ExportString` + `Write` pipeline works on mounted filesystems
- If native re-reading is unavailable, file size is only a basic transport check; disclose that notebook fidelity could not be verified

## Style rules — Critical

These are defaults for a requested, fully assistant-written expository notebook.
They do not reformat human manuscripts, design notebooks, shared notes or existing content.
Follow the human document's structure, terminology and metadata; design companions may use API signatures and itemized proposals.

- **`[[ LLM Generated ]]` as a `Subtitle` cell right after the `Title`** for a fully assistant-written standalone notebook.
  Use the explicit `llmStandalone` generation flag in [pipeline-builtin.md](pipeline-builtin.md); leave it `False` for human-owned or shared documents and for generated cell fragments.
  Identify assistant contributions locally or in companion provenance without changing human authorship.
- **A discovery walkthrough**, building up to the main results. Few sections, no sprawl.
- **Visuals over numbers** — code illustrates each concept graphically. Prefer a picture to a numerical result, a `True`/`False`, or a list.
- **One concept on several substrates** — `GraphicsRow` (3 pictures per row) or `GraphicsGrid` (3 × 3).
- **Text cells: short, plain sentences** stating the math and the narrative. Itemized lists for enumerations. No code or function names, no descriptions of code, no numerical summaries of results.
- **Text first, then code** — a Text cell, then the code cell. Never interleave text and code within a paragraph.
- **Math in LaTeX** (`$…$`, `$$…$$`) — except in table cells, where `$…$` does not render; use plain text there.
- **Examples are full, self-contained snippets** in the snippet style of the project's `CLAUDE.md` § *Snippets*: a chained `With`, one construction per block, literals inline, the display last. No big shared helper functions; copy code between examples instead.
- **Setup cell** — for a project that publishes a paclet, `PacletInstall[ "<cloud url>", ForceVersionInstall -> True ]` then `` Needs[ "WolframInstitute`<Name>`" ] ``; for local work, `PacletDirectoryLoad[ "<path>" ]` beside the `PacletInstall`. Shared initialization definitions go in a separate initialization cell after it.
- **References as plain text** — author, title, arXiv link.
- **Plain tables** — no separating lines, dividers, or frames in tables; use plain rows and `Grid`.
- **No labels on graphics** — no `PlotLabel`, axis labels, or annotations; let the surrounding text carry the meaning.
- **Name after the code, not prose** — subsection titles name the function call or option being illustrated, e.g. `FindPoint`, `"From" -> "Center"` — not a descriptive sentence.
- **Lean on defaults** — only style what carries meaning; otherwise use default rendering (§ *Graphics* of the project's `CLAUDE.md`: `Standard*` colors, no `ImageSize`).

When writing cells directly through `mcp__Wolfram__WriteNotebook` rather than the Markdown pipeline:

- Styles that work: `Title`, `Subtitle`, `Section`, `Subsection`, `Text`, `Item`, `ItemNumbered`, `Input`. Not `Subitem`, `Subsubitem`.
- `Text` / `Item` cells: plain strings plus named characters (`\[Alpha]`, `\[Integral]`, `\[Element]`, …). Not `\n`, `\t`, Unicode escapes, `TextData`, `BoxData`, `StyleBox`, `ButtonBox`, `\[Superscript]`, `\[Subscript]`. Separate cells instead of newlines.

## Naming conventions

Preserve any supplied or established name and location.
New one-off artifacts use one shared `TopicName_YYMMDD` stem for `.md` (when present) and `.nb`; do not append a second date to the notebook.
Human-owned numbered documents keep their author-selected names, for example `Infrageometry1.nb` and `Infrageometry1_notes.nb` at the repository root.
The human chooses the next numbered iteration; maintaining the companion in place does not advance it.
A specifically requested versioned artifact revision uses the naming rule in [round.md](../document-revise/round.md#names).

## Integration with other skills

- `paper-create-notebook` builds on this pipeline (rich engine + MathNotebook post-processing) for research documents.
- `project-create` and `project-tour` generate their notebooks through it.
- `paclet-docs` does **not** — documentation pages go through the official MCP doc tools.
- `project-provenance` defines the `stampTaggingRule` helper used in the *Provenance* step.

## When NOT to use

- An explicitly requested mathematics paper or article as a notebook — that is `paper-create-notebook`; ordinary exploration and conjecture notebooks remain here.
- Paclet documentation pages — that is `paclet-docs`.
- Regenerating over unreconciled human edits or writing a human document outside the requested scope — see [editing.md](editing.md) and the ownership policies above.
