---
name: new-notebook
description: >
  Create or modify Wolfram Notebooks (.nb) from structured Markdown content
  using the Wolfram MCP. This is the unified notebook skill — use it for
  creating new notebooks, editing existing ones, or converting NotebooksLLM/
  markdown sources into .nb files. Triggers on: "create notebook", "make a
  notebook", "notebook about X", "edit notebook", "update notebook",
  "put this in a notebook", "generate .nb". Also used by other skills
  (new-project, start-tour) when they produce notebooks.
---

# Wolfram Notebook Pipeline

**All skills that create or modify `.nb` files must use this skill's pipeline and conventions** — including math formatting, backtick escaping, and post-processing.

The core technique:

```
ExportString[ImportString[markdownString, {"Markdown", "Notebook"}], "NB"]
```

No temporary files are created.
The markdown lives as a string in the Wolfram kernel, gets imported as a Notebook expression, post-processed, then serialized back to a string via `ExportString`.
You then write that string to the target `.nb` file using the local `Write` tool.

The details live in four read-on-demand siblings — read only what the current job needs:

- [pipeline-builtin.md](pipeline-builtin.md) — post-processing + the complete built-in-engine MCP call (the canonical copy of `boxifyInputCells`, `markInitCells`, `addLLMSubtitle`)
- [pipeline-rich.md](pipeline-rich.md) — what rich mode changes, the parser-degradation probe, the rich-mode MCP call
- [templates.md](templates.md) — the named templates (`research`, `paper-analysis`, `computation`, `theorem-proof`)
- [markdown-mapping.md](markdown-mapping.md) — markdown-to-cell mapping, long-notebook pattern, content best practices

## When to use

- The user says "create notebook", "make a notebook", "notebook about X", "edit notebook", "update notebook", "put this in a notebook", "generate .nb".
- Another skill produces a notebook (`new-project`, `start-tour`) — every `.nb`-touching skill routes through this pipeline.

## Hard Rules

- **NEVER** read a `.nb` file with the `Read` tool or load its raw content into the context window.
  To work with an existing notebook, export to Markdown first via `ExportString[Import[path], "Markdown"]` in the Wolfram MCP.
- **NEVER** use `Export[path, ...]` in MCP code — always `ExportString[...]` and write the result with the `Write` tool.
  The MCP kernel runs in a separate process with its own filesystem, so `Export` writes where the user cannot see.

## Kernel execution (license-aware)

This skill runs entirely on the AgentTools MCP (`mcp__Wolfram__WriteNotebook`, `mcp__Wolfram__ReadNotebook`, `mcp__Wolfram__WolframLanguageEvaluator`) — one persistent kernel, no extra license seat.
The batch `Scripts/generate_notebooks.wls` / `Scripts/publish_notebooks.wls` helpers each spawn a fresh `wolframscript` kernel and are a fallback for bulk runs only — check headroom first per the authoritative policy in [`CLAUDE.md` § *Wolfram Kernel Execution Policy*](../../CLAUDE.md#wolfram-kernel-execution-policy); with no free seat, generate notebooks one at a time through the MCP.

## Where notebooks live — Critical

All LLM notebook artifacts live in `NotebooksLLM/`.
The plain `Notebooks/` folder is reserved for user-authored notebooks — protected content per [revise](../revise/SKILL.md) § *Protected content*: **never read, write, or overwrite anything in `Notebooks/`.** Within `NotebooksLLM/` you may freely create and overwrite.

## Two-layer architecture (co-located)

Source and output live side by side in `NotebooksLLM/`:

```
NotebooksLLM/Name.md              ← tracked in git, source of truth
NotebooksLLM/Name_YYYY-MM-DD.nb   ← gitignored (NotebooksLLM/*.nb), generated from the .md
Notebooks/                        ← user-authored notebooks; LLM never touches these
```

The `.md` source is the durable, hand-editable artifact; the `.nb` is regenerated from it.
These are **not** wiki articles — they do not go in `Wiki/`.

The generated `.nb` filename carries the source's **first-creation date** as a `_YYYY-MM-DD` suffix.
The date is stamped once, when the notebook is first generated, and **preserved on every later regeneration** — `generate_notebooks.wls` reuses the earliest date already present in the folder and deletes any other-dated or legacy un-dated copy, so exactly one `.nb` survives per source.
The date lives only in the filename; **do not** put it inside the notebook (the `[ LLM Generated ]` subtitle stays undated).

When to use the source layer:

- Creating a notebook intended to persist across sessions → write `NotebooksLLM/Name.md` as the source, then generate the `.nb`
- Quick one-off exploration → generate `NotebooksLLM/Name_YYYY-MM-DD.nb` directly, skip the `.md` source

The source is a structured Markdown file following [markdown-mapping.md](markdown-mapping.md): one `# Title`, a `## Setup` section for package loads (becomes InitializationCells), `wolfram`-tagged fences for evaluatable Input cells, plain text for Text cells.

To generate: read `NotebooksLLM/Name.md`, pass its content through the MCP pipeline, write the result to `NotebooksLLM/Name_YYYY-MM-DD.nb`.
Use the first-creation date: if a `Name_*.nb` already exists, reuse its date and overwrite that file; otherwise use today's date.
Only as the license-gated fallback, run the batch scripts (`wolframscript -file Scripts/generate_notebooks.wls`, plus `publish_notebooks.wls` for cloud publishing) — they do the date bookkeeping automatically.

## Provenance (optional)

If the project has prompt tracking on (a `Prompt tracking: **on**` line in `CLAUDE.md` — see the [provenance](../provenance/SKILL.md) skill), record the originating prompt/intent for the notebook:

1. Write a leading `<!-- provenance: ... -->` comment at the top of the `NotebooksLLM/Name.md` source.
2. Inject it into the `.nb` on the MCP path yourself:
   build `prov = <| "intent" -> ..., "date" -> ..., ... |>` from the comment's fields,
   strip the comment from the markdown string before conversion (the built-in importer drops HTML comments, but the rich parser is not guaranteed to),
   and stamp the notebook expression just before `ExportString` with the `stampTaggingRule` merge helper from the [provenance](../provenance/SKILL.md) skill.
   `TaggingRules` is a shared slot — `research-notebook`'s fingerprint key lives there too — so merge by key; never write a literal `TaggingRules -> {...}` that replaces the option.
   In the built-in call this wraps the final expression: `ExportString[ stampTaggingRule[ Notebook[cells], "Provenance" -> prov ], "NB" ]`;
   in the rich-mode call apply it to `ReplacePart[nb, 1 -> cells]`, which it leaves option-complete (the helper preserves `CreateCellID` and `StyleDefinitions`).
3. On the batch fallback path only, skip step 2: `generate_notebooks.wls` strips the comment and injects the `TaggingRules` itself.
4. Append an entry to the `Wiki/Prompts.md` ledger.

When tracking is off (default), skip this — generate the notebook as usual.

## Which MCP tool to use

- **Official MCP with the `WolframPacletDevelopment` profile** (preferred): use `mcp__Wolfram__WriteNotebook` / `mcp__Wolfram__ReadNotebook` — they handle `.nb` files natively without the Markdown→ImportString workaround.
- **Markdown pipeline** (fallback, older profile): `ExportString[ImportString[md, {"Markdown", "Notebook"}], "NB"]` via `mcp__Wolfram__WolframLanguageEvaluator`.
- **Unofficial MCP** (`mcp__wolfram__`): use its LSP tools (hover_info, find_definition, find_references, get_diagnostics, document_symbols) for code navigation only; do not use its notebook-manipulation tools when the official MCP is available.
- **Last resort** (no MCP): create a minimal `.nb` manually with the `Write` tool and raw NB format, and warn the user.

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

- **`"Evaluate" -> False`** always.
  Cells ship unevaluated; the front end evaluates them.
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

1. **Compose** well-structured Markdown per [markdown-mapping.md](markdown-mapping.md) (structure from [templates.md](templates.md) when applicable)
2. **Evaluate** via the Wolfram MCP: build string → convert → post-process → `ExportString` ([pipeline-builtin.md](pipeline-builtin.md) or [pipeline-rich.md](pipeline-rich.md))
3. **Write** the returned string to the target `.nb` file using the `Write` tool
4. **Verify** by checking file size or evaluating `Length[First[Import["/path/to/file.nb"]]]` via the official MCP

Modifying an existing notebook:

1. **Export** → `ExportString[Import["/path/to/file.nb"], "Markdown"]` via the official Wolfram MCP
2. **Edit** the Markdown string (find/replace, append, restructure)
3. **Re-import** through the full pipeline: convert → post-process → `ExportString`
4. **Write** back to the original path (or a new file if the user wants to keep the original)
5. **Verify** cell count

**Short notebooks** (< ~30 cells): rebuild entirely from Markdown.
**Long notebooks**: export → patch the relevant section → re-import.
**Appending**: export → append new Markdown sections at the end → re-import the full combined string.

Do **not** manipulate raw `.nb` cell lists by hand — always go through the Markdown round-trip.

## Claude Desktop / VM mode

When running inside a VM (Claude Desktop Projects or sandboxed environment):

- Confirm that a shared folder exists and is accessible
- The `ExportString` + `Write` pipeline works on mounted filesystems
- Cell count verification via `Import` may fail — check file size instead

## Style rules — Critical

These govern the *content* of every LLM-generated notebook. Apply them as you compose the markdown.

- **Concise** — keep text simple and short; don't over-complicate or over-explain.
- **Prefer bullet points over prose** — use bulleted lists, not flowing paragraphs, wherever possible.
- **Text first, then code** — explain in a Text cell, then show the code cell. Never interleave text and code within a paragraph.
- **No inline code in prose** — keep calls and code out of flowing sentences; they belong in their own cells.
- **Focus on substance** — the math, algorithms, and what functions do. Explain things properly; don't just print numbers.
- **Clear structure** — few sections, no sprawl.
- **Visual, not numeric** — favor graph and plot visualizations over numeric output.
- **No LaTeX math in table cells** — use plain text inside table cells so they render.
- **Plain tables** — no separating lines, dividers, or frames in tables; use plain rows and `Grid`.
- **No labels on graphics** — no `PlotLabel`, axis labels, or annotations; let the surrounding text carry the meaning.
- **Name after the code, not prose** — subsection titles and any labels should name the function call or option being illustrated, e.g. `FindPoint`, `"From" -> "Center"` — not a descriptive sentence.
- **Only meaningful functions** — define only functions with genuine mathematical meaning. No utility/helper functions (no frame/anim/origin/ecc-style helpers).
- **Lean on defaults** — only style what carries meaning; otherwise use default rendering.

## Naming conventions

The `.md` source name is undated; the generated `.nb` appends the first-creation date (`_YYYY-MM-DD`, preserved across regenerations — see *Two-layer architecture*).

- Single-topic notebooks: `TopicName.md` / `TopicName_YYYY-MM-DD.nb`
- Paper analysis: `Author_Year.md`
- Chains/multi-topic: descriptive name (`UniversalityGraph.md`)

## Integration with other skills

- `research-notebook` builds on this pipeline (rich engine + MathNotebook post-processing) for research documents.
- `new-project` and `start-tour` generate their notebooks through it.
- `paclet-docs` does **not** — documentation pages go through the official MCP doc tools.
- `provenance` defines the `stampTaggingRule` helper used in the *Provenance* step.

## When NOT to use

- Research documents with definitions/theorems/conjectures — that is `research-notebook`.
- Paclet documentation pages — that is `paclet-docs`.
- Anything in the user-authored `Notebooks/` folder — protected, never touched.
