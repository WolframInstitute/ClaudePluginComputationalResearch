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

- [ ] T3 — Draft the `paclet-docs` skill and its slash command.
- [ ] T4 — Generate docs end-to-end for one real paclet; verify with `CheckPaclet` and a live `?Symbol` / F1 lookup after install.
- [ ] T5 — Wire docs into `build-paclet` and `publish-paclet`.
- [ ] T6 — Execute the T2 decision; update `README.md`, `CLAUDE.md`, `plugin.json`, `marketplace.json`; present the blog-post edit for review.

### Done

- [x] T1 — Study PureMath's documentation layout and build; catalogue the doc-authoring MCP tools against it; write the target page structure (guide + symbol pages, function list first). *(Session 1)*
- [x] T2 — Decide `demo-notebook`'s fate (retire / reshape / fold in); present the recommendation with the reach-vs-legitimacy tradeoff, and record it in `## Decisions`. *(Session 2)*

## Progress

### Session 1 — 2026-07-27 — T1

- **Prompt:** "Continue working on research items until done. Commit and push after each. I am going to bed."
- **Did:** cloned `WolframInstitute/PureMath` (private; SSH clone, gitignored path) and studied it.

  **The single most important finding: PureMath does not author `.nb` documentation at all.**
  It authors **Markdown** — 1,480 pages, 100 guides plus 1,380 symbol pages — and converts them with the deployed **MarkdownToNotebook** resource function, then runs `DocumentationBuild`.
  `scripts/build_notebooks.wls` calls `ResourceFunction[ResourceObject["https://www.wolframcloud.com/obj/nikm/DeployedResources/Function/MarkdownToNotebook"]]` directly.
  It also ships `.agent-skills/wolfram-guide-page/` and `.agent-skills/wolfram-symbol-page/` — specialised forks of the very skills catalogued in `EvaluateMarkdownToNotebook` T2, one of which says outright "build it with MarkdownToNotebook".
  So the reference implementation the Origin points at *is* the MarkdownToNotebook pipeline, which makes this item's central build-vs-adopt question largely pre-answered and confirms Phase 3 of that item's Recommendation.

  **Layout.** `docs/en/{Guides,ReferencePages/Symbols,Tutorials}/`, nested by mathematical domain (`Guides/Geometry/DifferentialGeometry/`, `ReferencePages/Symbols/Algebra/LieTheory/`), plus a parallel `docs/dev/en/` tree for the dev paclet.
  Frontmatter on every page: `Template`, `Name`, `Title`, `Context`, `Paclet`, `URI`, `Description`, `Keywords`, `SeeAlso`, `RelatedGuides`, `RelatedTutorials`.
  The `URI` is the in-product address (`WolframInstitute/PureMath/ref/ConjugatePriorQ`).

  **The Origin's "list of functions first and then examples" is exactly PureMath's guide shape**, confirmed on a leaf guide: `## Abstract`, then `## Functions` with `### ` subsections grouping one-line bullets — `` `Symbol` `` followed by a single clause, with `(WL)` marking built-ins folded in alongside the paclet's own, and `<!-- SUGGESTED: … -->` marking planned symbols.
  Symbol pages run `## Usage`, `## Details & Options`, `## Basic Examples`, `## Possible Issues`; links to symbols are written `<code>[Symbol]()</code>` (MarkdownToNotebook's inferred-link form) and expected results as `<!-- => True -->` comments, with `<!-- #| annotation: … -->` carrying design-review notes.

  **Build.** `lint_docs.wls` (house-style lint — notably every ` ```wl ` cell must satisfy `SyntaxQ` without evaluation), `build_notebooks.wls` (MTN conversion), `run_doc_examples.wls`, `publish.wls`, `build_docs_site.wls`, `clean_deployed_docs.wls`.
  CI (`.github/workflows/build_paclet.yml`) lints and tests on a hosted runner, then does the heavy build on a **provisioned 16–32 vCPU Prime Intellect pod**, because hosted runners cap at 2–4 vCPUs and, in the workflow's own words, that "barely parallelizes the Wolfram doc build".

  **A cost signal that should not be glossed over.** `build_notebooks.wls` carries roughly ten documented workarounds for MarkdownToNotebook's behaviour: the frontmatter parser mangles `Links: [...]`, the Paclet template emits eight bare scaffolded `Subsection`s, tutorials still get the legacy "Tech Note" categorization instead of the modern `Tutorial` entity, and `guideNotebook` has no code path for `RelatedTutorials`.
  Driving MTN for documentation is not turnkey — the reference implementation pays a continuing shim tax for it.

  **Catalogue of the doc-authoring MCP tools against that layout.**
  Read from their tool contracts, not inferred from names; none were invoked, since `CreateSymbolDoc` writes files.

  | Tool | Produces | Fits the layout? |
  |---|---|---|
  | `CreateSymbolDoc` | a symbol `ref/` page `.nb` in the right place in the paclet doc tree, from **Markdown** `usage` / `notes` / `basicExamples`, evaluating code blocks; takes `seeAlso`, `keywords`, `relatedGuides`, `techNotes`, `relatedLinks`, `newInVersion` | Yes, for symbol pages — and it is markdown-in, so much closer to MTN than the Spec assumed |
  | `EditSymbolDoc` | in-place edits to an existing page: `setUsage`, `setNotes`, `addNote`, `setDetailsTable`, `setSeeAlso`, `setTechNotes`, `setRelatedGuides`, `setRelatedLinks`, `setKeywords`, `setHistory` | Yes — covers every symbol-page metadata slot PureMath's frontmatter carries |
  | `EditSymbolDocExamples` | example sections — `BasicExamples`, `Scope`, `Options`, `Applications`, `PropertiesRelations`, `PossibleIssues`, `NeatExamples`, … — with append/prepend/insert/replace/remove/clear/set, evaluating inputs and returning the result as markdown | Yes, and it is the closest thing to `run_doc_examples.wls` |
  | `CheckPaclet` | metadata/structure issues by severity before build or submit | Yes — the verification T4 needs |
  | `BuildPaclet`, `SubmitPaclet` | archive / repository submission | Adjacent, not doc authoring |
  | unofficial `create_paclet_doc_skeleton`, `create_function_doc`, `document_symbols` | skeleton and per-function pages | Untested here; the official set covers symbol pages already |

  **The gap in the official set is the guide page.** There is no `CreateGuideDoc` — `CreateSymbolDoc` is symbol-only, and `EditSymbolDoc`'s `setRelatedGuides` only *links* to a guide it cannot create.
  Since the Origin's explicit requirement is the function-list-first **guide**, the official MCP path cannot deliver the headline feature on its own, whereas MTN's `Template: Guide` can and does, 100 times over, in PureMath.

  **Target page structure** (for T3, both page types authored as Markdown):

  ```
  Guide:  frontmatter (Template: Guide, Name, Title, Context, Paclet, URI,
          Description, Keywords, RelatedGuides)
          ## Abstract        one short paragraph
          ## Functions       ### role subsections, one-line `Symbol` bullets,
                             built-ins folded in and marked (WL)
  Symbol: frontmatter (Template: Symbol, Name, Context, Paclet, URI,
          Keywords, SeeAlso, RelatedGuides)
          ## Usage           <code>[Symbol]()</code>[*args*] one line per signature
          ## Details & Options
          ## Basic Examples  ```wl cells, expected results as <!-- => … --> comments
          ## Possible Issues
  ```
- **Learned:** the Spec's framing — "the doc-authoring tools are already available and no skill in this plugin uses them" — is true but reads as an oversight when it is closer to a fork in the road.
  The reference implementation the same Origin names went the other way, and did so at scale.
  The real decision for T3 is therefore *which* markdown-to-doc-page engine to drive, official MCP or MTN, and the guide-page gap plus PureMath's 1,480-page precedent both point at MTN — while MTN's missing licence and the shim tax point the other way.
  That is a genuine trade-off and it is not mine to settle unattended.
- **Next:** T2 — the `demo-notebook` decision.

### Session 2 — 2026-07-27 — T2

- **Did:** worked the `demo-notebook` decision, with one fact from T1 that changes the trade-off the Spec set up.

  **The reach-vs-legitimacy trade-off is not as sharp as the Spec assumes**, because PureMath deploys its *documentation* to a public URL: `scripts/build_docs_site.wls` builds a docs site and the CI job "prints the deployed docs URL", with `clean_deployed_docs.wls` maintaining it.
  So a reader with no paclet installed can still be sent a link — to the real documentation rather than to a separate hand-built notebook.
  Once `paclet-docs` exists and its output is deployed the same way, `demo-notebook` has no remaining audience of its own: docs cover the installed reader (searchable, `?Symbol`, F1) and the deployed docs site covers the zero-install reader.

  **Recommendation: retire it — Option 1 — but sequenced, not immediately.**
  Retire `demo-notebook` in T6 only once *both* hold: `paclet-docs` ships and produces a guide plus symbol pages that resolve in-product, **and** a deployed docs-site URL replaces the current README demo link.
  Retiring before that trades a working artifact for a promise and leaves the README pointing at nothing.
  Against Option 2 (keep it reshaped): it would mean maintaining two generators whose only difference is packaging, and the Origin's own lean is retirement.
  Against Option 3 (fold in): emitting a cloud notebook *and* a doc tree from one source sounds economical but the two want different sources — a demo notebook is a narrative sequence of worked examples, a doc tree is one page per symbol; PureMath keeps `notebooks/` and `docs/` separate for that reason.

  **This is recorded as a recommendation, not executed.** It removes a shipped, documented feature (a skill, a command, a script, README and CLAUDE.md entries) and the Spec puts execution in T6 behind the doc tree actually working. Nothing was deleted.
- **Learned:** the deployed-docs-site path is the piece that makes retirement safe, and it was not in the Spec's option list at all — the Spec framed the choice as notebook-or-docs when PureMath's answer is "docs, published twice".
  T5's scope should grow to include deploying the built docs, since that is now load-bearing for T6.
- **Next:** T3 — draft the `paclet-docs` skill. **Blocked, deliberately** — see the note below.

## Blocked

T3–T6 are not started, and should not be started unattended:

- **T3 needs a decision that is the user's**: whether `paclet-docs` drives the official MCP doc tools or MarkdownToNotebook.
  T1 makes the case for MTN (it is what PureMath uses, at 1,480 pages, and it is the only one of the two that can build the function-list-first guide page the Origin asks for), but MTN currently has **no licence** and no pinnable release — see `Done/2026-07-27-EvaluateMarkdownToNotebook.md`, whose Phase 0 asks upstream for exactly those.
  Drafting a skill against an unlicensed, unpinned dependency risks work that gets discarded.
- **T4 needs a human at a front end.** `CheckPaclet` runs headless, but "resolves in-product via `?Symbol` / F1" is the acceptance criterion the Spec calls decisive, and F1 in the Documentation Center is not verifiable from here.
- **T5 should be re-scoped first** to include deploying the built docs, per T2's finding.
- **T6 is destructive and outward-facing**: it deletes a shipped skill, command, and script, bumps the plugin version, pushes to the marketplace repo, and touches the public blog post. It also depends on the T2 recommendation being confirmed.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | Retire `demo-notebook` (Option 1), but only in T6 and only once `paclet-docs` produces in-product-resolving pages **and** a deployed docs-site URL replaces the README demo link. — *recommendation, awaiting confirmation* | PureMath publishes its documentation to a public URL as well as shipping it in the paclet, so once docs are deployed the same way there is no reader left that only a demo notebook serves. Sequencing matters: retiring first would leave the README pointing at nothing. Options 2 and 3 both mean maintaining two generators for one product. |
| 2026-07-27 | Do not draft `paclet-docs` yet. | The engine choice — official MCP doc tools vs MarkdownToNotebook — is a real trade-off (guide-page gap and a 1,480-page precedent on one side; no licence, no pinnable release, and a documented shim tax on the other) and it determines the skill's whole shape. |
