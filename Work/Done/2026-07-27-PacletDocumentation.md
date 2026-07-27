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
  - **one symbol reference page per exported function** — Usage, Details, Examples (Basic Examples at minimum), following the plugin's existing example house style.
  - ~~**one guide page** — every exported symbol, grouped by role, function list first~~ — **removed from scope 2026-07-27** at the user's call: "You dont have to do guide pages then. This is anyway better for humans." The guide page is a human deliverable.
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

All tasks are done.

### Done

- [x] T5 — Wire docs into `build-paclet` and `publish-paclet`, including deploying the built docs to a public URL (re-scoped per T2) and staging `Documentation/` in publish scripts that copy a fixed directory list. *(Session 6)*

- [x] T4 — Generate docs end-to-end for one real paclet; verify by resolving every doc URI after a real install. *(Session 5)*

- [x] T1 — Study PureMath's documentation layout and build; catalogue the doc-authoring MCP tools against it; write the target page structure (guide + symbol pages, function list first). *(Session 1)*
- [x] T2 — Decide `demo-notebook`'s fate (retire / reshape / fold in); present the recommendation with the reach-vs-legitimacy tradeoff, and record it in `## Decisions`. *(Session 2)*
- [x] T3 — Draft the `paclet-docs` skill and its slash command. *(Session 4)*
- [x] T6 — Execute the T2 decision; update `README.md`, `CLAUDE.md`, `plugin.json`, `marketplace.json`; present the blog-post edit for review. *(Session 3, out of order at the user's instruction)*

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
- **Next:** T3 — draft the `paclet-docs` skill.

### Session 3 — 2026-07-27 — T6 (out of order)

- **Prompt:** "keep the official tools then for the time being, but the evaluation for later task" / "okey, retire that" / retire now, in this session.
- **Did:** two decisions taken by the user, then executed the retirement half of T6 ahead of T3–T5 at their instruction.

  **Engine: the official MCP doc tools.** `CreateSymbolDoc`, `EditSymbolDoc`, `EditSymbolDocExamples`, verified with `CheckPaclet`.
  MarkdownToNotebook adoption is deferred to its own item, `Backlog/AdoptMarkdownToNotebook.md`, which carries the guide-page gap forward as the open problem: the official set has no guide-page tool, and the function-list-first guide is the Origin's headline requirement.
  T3 must therefore solve the guide page some other way — most likely by assembling the guide notebook directly, since `EditSymbolDoc`'s `setRelatedGuides` can only link to a guide it cannot create.

  **`demo-notebook` retired, now.** Removed `skills/demo-notebook/SKILL.md`, `commands/demo-notebook.md`, and `scripts/build_demo_notebook.wls`.
  Downstream references updated: the `README.md` Skills & Commands row; the `CLAUDE.md` skills, scripts, and commands tables with their counts (20 → 19 skills, 27 → 26 scripts, 21 → 20 commands); the comparison table at the top of `research-notebook/SKILL.md`; and the `description` in both `plugin.json` and `marketplace.json`, which claimed "cloud-deployed paclet demo notebooks".
  Version bumped **3.16.0 → 4.0.0** in both — removing a shipped skill and command is a breaking change, not a feature.
  The blog post needed no edit: it never mentioned `demo-notebook`, so there is nothing to present for review.
  A grep over the shipped files confirms no reference survives.
- **Learned:** the retirement was cheaper than the Spec anticipated because the feature had almost no surface area outside its own three files — four table rows and one description clause.
  The Spec's worry about "every downstream reference" was warranted in form but small in fact.
  What the retirement does leave owed is the deployed docs URL: the README no longer points anywhere for a zero-install reader, which is the cost the user accepted in choosing immediate removal over the sequenced plan, and T5 is where it gets repaid.
- **Next:** T3 — draft the `paclet-docs` skill against the official MCP doc tools.

### Session 4 — 2026-07-27 — T3

- **Prompt:** "You dont have to do guide pages then. This is anyway better for humans"
- **Did:** took the scope reduction, then drafted the skill.

  **Guide pages are out of scope.** The user's reasoning is the better one: grouping a paclet's functions by role, naming the groups, and writing the abstract is editorial judgement about what the paclet *is*.
  That removes T3's only real obstacle — the official MCP set has no guide-page tool, which was the last thing blocking a draft — and it narrows the Origin, which had asked for "guides and symbol pages".

  Added `skills/paclet-docs/SKILL.md` and `commands/paclet-docs.md`; registered in `README.md` and the `CLAUDE.md` skills and commands tables (19 → 20 skills, 20 → 21 commands).

  The skill: detect the paclet directory as `build-paclet` does; take the public API from the `"Symbols"` list in `PacletInfo.wl` in preference to `Names[context <> "*"]`, since that list is the author's own statement of what is public, and say which source was used; agree the symbol list before generating anything; generate **one page first** and get its shape approved before the rest, per `revise`, because page shape is wrong in the same way thirty times; then `CreateSymbolDoc` per symbol with Markdown `usage` / `notes` / `basicExamples`, extended by `EditSymbolDocExamples` for `Scope` / `Options` / `PossibleIssues` and `EditSymbolDoc` for metadata; `CheckPaclet` with errors blocking; then install with docs bundled and assert `Information[symbol]` shows the usage.

  Two things written in deliberately.
  `EditSymbolDocExamples` returns its generated content as Markdown, so the skill reads it back and checks the examples produced what was expected — an example that errored still writes a page.
  And the skill states plainly that F1 and Documentation Center search **need a human**, and that the step is outstanding until the author does it, rather than letting a headless `Information` check pass for the real acceptance criterion.

  On guides the skill does two permitted things: link symbol pages to a guide the author has already written (`relatedGuides`, or `setRelatedGuides`), and offer a draft function list as plain text on request — offer it, never write the guide.
- **Learned:** dropping the guide page also removes the strongest technical argument for MarkdownToNotebook, which was that its `Template: Guide` could build the function-list-first guide and the official tools could not.
  The MTN case is now much weaker for this plugin's purposes, and `Backlog/AdoptMarkdownToNotebook.md` has been amended so a later session does not re-open it on an argument that no longer applies.
- **Next:** T4 — generate docs for one real paclet and verify; needs a human for the F1 step.

### Session 5 — 2026-07-27 — T4

- **Prompt:** `/next-session` — and, on the one question this session asked, "All 21, examples only where honest".
- **Did:** ran `paclet-docs` end to end against `WolframInstitute/MathNotebook` — 21 exported symbols, a real paclet with a clean tree and no `Documentation/`.
  Dry-ran the tools on a scratchpad copy first, which is where every defect below surfaced; only then wrote into the real repo.

  **All 21 pages exist and all 21 resolve.**
  `Documentation`ResolveLink` returns an existing file under `…/Paclets/Repository/WolframInstitute__MathNotebook-0.1.11/Documentation/…` for every symbol, after `CreatePacletArchive` + `PacletInstall` — a real install, not a `PacletDirectoryLoad`.
  The symbol list and the page list match exactly in both directions.
  `ImportLaTeXDocument` and `ExportLaTeXDocument` carry evaluated Basic Examples; the round-trip example genuinely returns `True`.
  MathNotebook's own suite stays green: 130 passed, 0 failed across nine `.wlt` files.
  Committed in the MathNotebook repo as `3735912` (not pushed).

  **Five defects in the T3 skill, all of which would have shipped broken docs.** All five are now fixed in `skills/paclet-docs/SKILL.md`.

  1. **`CheckPaclet` is not a paclet linter, and step 3 was built on it.** It wraps `Wolfram`PacletCICD`CheckPaclet`, whose first definition is `CheckPaclet[dir_File?DirectoryQ] := CheckPaclet[findDefinitionNotebook@dir]` — it wants a Paclet *Repository* definition notebook. Against a plain paclet it answers `CheckPaclet::invfile` and the MCP wrapper dies with `AgentTools::Internal::UnhandledDownValues::formatCheckResult`. The skill's only verification gate could never have run.
  2. **`CreateSymbolDoc` does not declare the `Documentation` extension.** It writes the page and leaves `PacletInfo.wl` alone, so the URI resolves to `Null` — the exact silent failure the Spec predicted, reproduced and then fixed by adding `{"Documentation", "Root" -> "Documentation", "Language" -> "English"}`.
  3. **`Information` cannot verify a doc page.** It prints `::usage` from the kernel. `ConvertMathCells` printed a full usage line while having no page at all, so the check the Spec and the skill both named is one that cannot fail. `Documentation`ResolveLink` replaced it.
  4. **`pacletName` must not repeat the publisher.** `"WolframInstitute/MathNotebook"` plus `publisherID` produced `WolframInstitute/WolframInstitute/MathNotebook/ref/…`.
  5. **One statement per code block.** Two become a `Defer[a, b]` that is visible in the rendered input cell. `a; b` on one line is fine.

  **The finding that shaped the deliverable: there is no unevaluated code block.**
  A ` ```wl-input ` fence is evaluated like any other and its output is written into the page — on `NotebookPut[ImportLaTeXDocument["paper.tex"]]` it wrote `NotebookPut[WolframInstitute`MathNotebook`PackageScope`latexToNotebook[$Failed]]`, an internal symbol presented as a result.
  19 of MathNotebook's 21 symbols act on the front end selection, an open notebook, or the network, so they cannot have an evaluated example that means anything.
  Those pages ship with Usage and `Details & Options` and an empty Basic Examples section, which was the user's call when asked.
- **Learned:** the Spec's decisive acceptance criterion — "resolves in-product via `?Symbol`" — was the weakest of the three checks available, and `CheckPaclet`, the one the skill leaned hardest on, does not apply to this class of paclet at all. Both were settled from tool contracts in T1 rather than by running them, which is exactly the reading T1 flagged as untested.
  The general lesson for the plugin: a paclet's public API shape decides whether generated reference docs can carry examples, and a front-end-driven paclet cannot. Worth asking before promising examples.
  Also owed: `MathNotebook/Scripts/PublishPaclet.wls:26` stages a fixed `{"Kernel", "FrontEnd", "Assets", "Tests"}` and would drop `Documentation/` from anything published — T5's problem, recorded in Blocked.
- **Next:** T5 — wire docs into `build-paclet` and `publish-paclet`, deploy them, and fix fixed-list publish scripts.

### Session 6 — 2026-07-27 — T5

- **Prompt:** `/next-session`, and on the two questions this session asked: "Public and keep it" for the docs deploy, "publish on, build off" for the docs default.
- **Did:** wired docs through build and publish, deployed them, and fixed a staging bug that was bigger than the one T5 was scoped for.

  **The fixed staging list was the real defect, and `Documentation/` was only its latest victim.**
  `paclet_common.wl` copied `PacletInfo.wl` + `Kernel/` + `Tests/` and nothing else, so building `MathNotebook` through the plugin installed it with no `FrontEnd/` and no `Assets/` — no palette, no stylesheets, a paclet that loads and is missing most of what it is for.
  MathNotebook's own `CLAUDE.md` had already written this up as "do not use the generic recipe here", which is the shape of a bug that has been worked around rather than found.
  Staging is now every top-level item except dotfiles and `build/`, with `Documentation/` the one conditional entry, so a paclet that adds a directory tomorrow ships it.
  Verified: staging reports `{Assets, Documentation, FrontEnd, Kernel, PacletInfo.wl, Tests}` with docs on and the same minus `Documentation` with docs off; a real build+install of MathNotebook 0.1.11 now installs all six, and 21/21 doc URIs still resolve from `$UserBasePacletsDirectory` afterwards.

  **Docs default: on for publish, off for build**, the user's call. `publish_paclet.wls` takes `--no-docs` to opt out; `build_paclet.wls` keeps `--with-docs` to opt in.

  **The deployed docs URL is live and is the debt T6 left open:** `https://www.wolframcloud.com/obj/hajek_pavel/MathNotebook/Documentation/index.html` — 21 cloud notebooks under `Documentation/ref/` plus an HTML index, all serving 200 to an unauthenticated reader (checked page by page, not sampled). Linked from MathNotebook's README next to the install line.
  New script `scripts/deploy_paclet_docs.wl` (Get through the MCP, wolframscript fallback), called automatically by `publish_paclet.wls` when docs were bundled, which prints `=== DOCS_URL: … ===` beside the existing `=== PACLET_URL: … ===`.

  **Two findings that shaped the script.**
  A generated page's own cross-links carry a web URL of `reference.wolfram.com/language/WolframInstitute/MathNotebook/ref/<Sym>.html` — a page that only exists for paclets shipped with the Wolfram Language — so re-hosting without rewriting publishes broken links to a Wolfram-branded 404. Links come in two forms, `TemplateBox[{label, "paclet:…", url}, "TextRefLink"]` in prose and `ButtonBox[…, ButtonData -> "paclet:…"]` in Usage and See Also; a rule for one silently leaves the other, and after both rules no `paclet:` string survives in a rewritten page.
  And `ExportString[nb, "HTML"]` is not an option for static pages: it rasterizes the cells into a 10 KB image map and drops every link, which is why the pages deploy as cloud notebooks.

  Also fixed `MathNotebook/Scripts/PublishPaclet.wls` to stage `Documentation/` (guarded by `DirectoryQ`, so the list tolerates a missing directory), and corrected that repo's `CLAUDE.md` note about the generic recipe, which is no longer true.
- **Learned:** the plugin had shipped a build recipe that quietly produced incomplete paclets, and the evidence was sitting in a downstream repo's CLAUDE.md as a workaround rather than reaching back as a bug report. Worth reading a paclet's own notes about the plugin, not just its code.
  On verification: `URLRead[url, "StatusCode"]` over every deployed page costs seconds and catches a permissions miss that a sampled check would not; the parts that genuinely need a human (F1, click-through) are now named as outstanding in the skills rather than implied to be done.
  Untested by design: `publish_paclet.wls`'s upload path was not run, since that would re-publish someone's paclet — the flag parsing and usage line were exercised, and the deploy function it calls was verified end to end through the MCP.
- **Next:** none — final task. The item is complete.

## Blocked

Nothing blocks the item; what is left is two human confirmations, neither of which is verifiable headlessly and both of which are recorded in the skills as outstanding:

- **The F1 step.** Every doc URI resolves from a real install (21/21, re-checked in Session 6 after the staging change), but pressing F1 in the Documentation Center and searching for a symbol needs a person. Outstanding on `WolframInstitute/MathNotebook` 0.1.11, installed with docs.
- **Click-through on the deployed pages.** The 21 pages and the index serve 200 to an anonymous reader and every `paclet:` link is rewritten to an absolute URL, but whether the cloud notebook viewer turns those into working links is a browser question.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | **Confirmed and executed:** `demo-notebook` retired immediately, not sequenced. The user chose immediate removal over the recommended sequencing. | The retirement itself was accepted on the reasoning below. On timing the user overrode the recommendation, accepting that the README loses its zero-install demo link until T5 deploys a docs URL. Executed in Session 3. |
| 2026-07-27 | Retire `demo-notebook` (Option 1) rather than reshape or fold in. | PureMath publishes its documentation to a public URL as well as shipping it in the paclet, so once docs are deployed the same way there is no reader left that only a demo notebook serves. Sequencing matters: retiring first would leave the README pointing at nothing. Options 2 and 3 both mean maintaining two generators for one product. |
| 2026-07-27 | Guide pages are **not generated** — a human deliverable. | The user's call, and the better argument: grouping functions by role and writing the abstract is editorial judgement about what the paclet is. It also disposes of the official set's guide-page gap. `paclet-docs` may link to an author-written guide and offer a draft function list, but not write the guide. |
| 2026-07-27 | `paclet-docs` drives the **official MCP doc tools** (`CreateSymbolDoc`, `EditSymbolDoc`, `EditSymbolDocExamples`, `CheckPaclet`) for the time being. MarkdownToNotebook adoption deferred to `Backlog/AdoptMarkdownToNotebook.md`. | The user's call. It avoids depending on a repo with no licence and no pinnable release. The cost is the guide-page gap: the official set has no guide-page tool, so T3 must build the guide notebook another way. |
