# PacletDocumentation

*[ LLM Generated ]*

> Type: refactor

## Spec

Origin: "Demo notebook should use some different template, something like here https://github.com/WolframInstitute/PureMath. List of functions first and then examples. Demo notebooks should be replaced by guides and symbol pages in mathematica documentation paclets. Perhaps demo notebooks should be replaced by this immediately."

Move paclet presentation from a hand-built cloud notebook to **real Wolfram documentation**: a guide page plus one symbol reference page per exported function, built into the paclet's `Documentation/` tree so it is searchable in-product (`?Symbol`, F1, the Documentation Center) rather than being a link in a README.

Today `demo-notebook` builds `Scripts/build_<name>_notebook.wls`, assembles a reference card plus worked examples, rasterizes outputs, smoke-tests headless, and `CloudDeploy`s to a stable public URL.
That artifact is discoverable only by following a README link and is not the shape a Wolfram user expects when meeting a paclet.
Documentation pages are.

Notably, the doc-authoring tools are already available and **no skill in this plugin uses them**: `mcp__Wolfram__CreateSymbolDoc`, `EditSymbolDoc`, `EditSymbolDocExamples`, `CheckPaclet`, `BuildPaclet`, and (unofficial) `create_paclet_doc_skeleton`, `create_function_doc`, `document_symbols`.

`WolframInstitute/PureMath` is the reference implementation to copy — including the ordering the user specified: **the function list first, then the examples**.

### Requirements

- Study PureMath's documentation layout and build: the `Documentation/English/{Guides,ReferencePages/Symbols}` tree, how pages are authored and built, and whether it relies on `DocumentationBuild` or CI.
- Catalogue the doc-authoring MCP tools above against that layout — which tool produces which page type.
- Add a new skill (working name `paclet-docs`) plus its slash command, which generates:
  - **one guide page** — every exported symbol, grouped by role, function list first;
  - **one symbol reference page per exported function** — Usage, Details, Examples (Basic Examples at minimum), following the plugin's existing example house style.
- Verify with `CheckPaclet` and by resolving `?Symbol` / F1 for a real paclet after install — a doc page that doesn't resolve in-product has failed, regardless of how it looks.
- Wire docs into `build-paclet` and `publish-paclet` so a published paclet ships them.
- **Decide the fate of `demo-notebook`** and record it in `## Decisions`. Three live options:
  1. **Retire it** — `git rm` the skill, command, and `scripts/build_demo_notebook.wls`; docs replace it outright. (The user's stated lean, "perhaps immediately".)
  2. **Keep it, reshaped** — restyle it to the PureMath order (function list, then examples) and keep it as the shareable browser link, since a cloud URL needs no install and docs do.
  3. **Fold it in** — `paclet-docs` emits both the doc tree and, optionally, a cloud notebook from the same source.
- On removal or rename, update every downstream reference: `README.md`, `CLAUDE.md` tables and counts, `.claude-plugin/plugin.json` (description, keywords, version bump), `ClaudePluginMarketplace/.claude-plugin/marketplace.json`, and the blog post — the last **presented for review only, never committed**.

### Design / risks

- **A cloud notebook and a doc page are not the same product.** The notebook is a zero-install link you can send to anyone; documentation requires the reader to install the paclet. Retiring `demo-notebook` outright trades reach for legitimacy. Worth being explicit about before deleting anything — this is why the decision is its own task and not an assumption.
- Doc pages are `.nb` files in a specific tree with required metadata; malformed pages fail silently (page exists, search never finds it). `CheckPaclet` plus a real in-product lookup is the only trustworthy verification.
- The hook that blocks `.nb` reads (`hooks/`) applies here — pages must be authored through the MCP doc tools, not by reading and hand-editing notebook files.

### Kernel execution (license-aware)

Authoring and verification run through the official Wolfram MCP's persistent kernel.
Check `$MaxLicenseProcesses - $LicenseProcesses > 0` before any `wolframscript`.

### Edge cases & out of scope

- MathNotebook and the research-notebook side are out of scope (see `MathNotebookIntegration`) — this item is the paclet-facing half.
- Do not delete `demo-notebook` before T2 records the decision; if it is retired, the work item and skill history are the record of why.
- No changes to the paclet build/publish scripts until the doc tree is proven to resolve in-product.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T1 — Study PureMath's documentation layout and build; catalogue the doc-authoring MCP tools against it; write the target page structure (guide + symbol pages, function list first).
- [ ] T2 — Decide `demo-notebook`'s fate (retire / reshape / fold in); present the recommendation with the reach-vs-legitimacy tradeoff, and record it in `## Decisions`.
- [ ] T3 — Draft the `paclet-docs` skill and its slash command.
- [ ] T4 — Generate docs end-to-end for one real paclet; verify with `CheckPaclet` and a live `?Symbol` / F1 lookup after install.
- [ ] T5 — Wire docs into `build-paclet` and `publish-paclet`.
- [ ] T6 — Execute the T2 decision; update `README.md`, `CLAUDE.md`, `plugin.json`, `marketplace.json`; present the blog-post edit for review.

### Done

(completed tasks move here with the session that closed them)

## Progress

(no sessions yet)

## Decisions

| Date | Decision | Rationale |
|---|---|---|
