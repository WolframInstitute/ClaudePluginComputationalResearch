# Paclet guide pages and tutorials

*[ LLM Generated ]*

How a paclet gets guide pages and tutorials beside its reference pages, and how the whole set is deployed as one public site.
The four design questions of the `DocumentationSite` item, answered on InfraGeometry with evidence (T1, 2026-10-05).
The ruling is the item's T2; the recommendations below are proposals, not decisions.

## InfraGeometry already runs the whole pipeline

The trial paclet is not a blank page.
Between 2026-09-28 and 2026-10-05 InfraGeometry built PureMath's path end to end, in its own scripts:

| Stage | InfraGeometry | State on 2026-10-05 |
|---|---|---|
| Sources | `<pacletDir>/docs/{Symbols,Guides,Tutorials}/*.md`, PureMath frontmatter | 154 symbol pages, 7 guides, 4 tutorials |
| Convert | `Scripts/build_docs.wls`: MarkdownToNotebook at the pin `204db7c`, templates `Symbol` / `Guide` / `TechNote` | authoring notebooks in `Documentation/English/` |
| Package | `Scripts/check_docs_package.wls`: `PacletBuild` from a scratch copy, `ResolveLink`, `DocumentationBuildHTML` preview | every source ships and resolves |
| Deploy | `Scripts/publish_docs.wls`: the paclet as a public **paclet resource** | live at `hajek_pavel/DeployedResources/Paclet/WolframInstitute/InfraGeometry` |

Its own article (`Wiki/Concepts/PacletDocumentation.md` in the InfraGeometry dev repo, 1,259 lines) records every run.

Two consequences for the item:

- The plugin's work is to **lift a pipeline that works**, not to design one.
- The criterion "InfraGeometry has a deployed guide page and one deployed tutorial" is **already true**, by InfraGeometry's scripts.
  The T5 trial means something only if it runs the plugin's path.

## What was measured

All on 2026-10-05, read-only on InfraGeometry and PureMath; the builds ran on copies in the session scratchpad.

| Measurement | Method | Result |
|---|---|---|
| Live site | anonymous `curl` of a guide, two tutorials, a ref page | `200` each; each `.html` is a ~125 kB resource shingle whose `#notebook-embed` points at the page's `.nb` |
| Embedded pages | anonymous `curl` of the `.nb` URLs | `200`; the server renders the text and the pictures: 373 kB and 19 images for *Straightening at a Scale*, 549 kB and 21 images for *The Metric Tensor* (13 MB notebook) |
| The plugin's own deployed docs | `curl` of `hajek_pavel/MathNotebook/Documentation/index.html`; `FileExistsQ` and `CloudObjects` from the signed-in kernel | redirect to the sign-in page; no object exists under `MathNotebook/Documentation` (the paclet itself is public) |
| Front end and seats | `UsingFrontEnd` in the MCP kernel | front end up in 1.9 s; `$LicenseProcesses` stays 1; `$MaxLicenseProcesses` is `Infinity` on this machine |
| Package through the MCP | `PacletTools`PacletBuild` on a copy of the 2.0.1 paclet, in the MCP kernel | `Success` in 203 s; archive 13.7 MB with 154 ref pages, 7 guides, 4 tutorials, **no file from `docs/`**; `$LicenseProcesses` 1 before and after |
| Authoring against built | cell styles of `Guides/InfraSubstrates.nb` before and after `PacletBuild` | authoring only: `MetadataSection`, `CategorizationSection`, `Categorization`, `KeywordsSection`, `Keywords`, `History`; built only: `AnchorBarGrid`, `PacletNameCell`, `FooterCell`; stylesheet `GuidePageStylesExt.nb` against `Reference.nb` |
| The plugin's archive | `CreatePacletArchive`, the call in `scripts/paclet_common.wl`, on a copy holding that one authoring guide | the archived guide still carries `MetadataSection` and `CategorizationSection` on `GuidePageStylesExt.nb`: no `DocumentationBuild` ran |
| Versioned source names | the pinned converter on `InfraSubstrates.md` and on an identical copy `InfraSubstrates_2.md`; a tutorial copy `…Tutorial_3.md` | identical notebooks once `ExpressionUUID`, `CellID`, `CellChangeTimes` are dropped; `URI` and `Entity Type` come from the frontmatter; neither `_2` nor `_3` appears in the output |
| Conversion cost | same calls, `"Evaluate" -> False` | guide 0.15–0.26 s; tutorial 5.1 s |
| Official doc tools | tool search in this session | no `CreateSymbolDoc` / `EditSymbolDoc` attached |

## 1. Where the sources live

**The options.**

- (a) In the paclet directory, `<pacletDir>/docs/` beside `PacletInfo.wl`: InfraGeometry.
- (b) At the paclet repo root beside the paclet directory, `<Repo>/docs/`: PureMath (`docs/en/…` beside `PureMath/`).
- (c) In the dev repo, `Code/Docs/`, outside the paclet repo.

**The evidence.**

- Sources and API move together.
  A rename sweeps the examples, the chips and the frontmatter in the same paclet commit; InfraGeometry's 2.0.0 rename did exactly that.
  Option (c) splits one change across two repos, so it is out.
- `PacletBuild` stages only the declared extensions: no file of `docs/` reached the archive (measured above).
  So (a) costs nothing on that path.
- The plugin's own build is different: `stagePacletFiles` in `scripts/paclet_common.wl` copies every top-level item but dotfiles and `build/`.
  Under (a) it would ship `docs/`, its `Archive/` and every provenance file in each archive.
  One more excluded name fixes it.
- Edits to a paclet repo go through a worktree on `work/<Item>` (`skills/backlog-run/paclet-worktree.md`), so a revision round on a guide is a paclet commit there.

**How the build takes the latest version.**
A round writes `Name_2.md` beside `Name.md` in the same folder ([round.md](../../skills/document-revise/round.md) § *Names*).
InfraGeometry's build cannot take that as it stands: it requires `URI` to end in the file name, and it globs every `*.md`.
The build therefore needs four rules:

- group the sources into stems by the round rule (`Name_k.md` is round `k` only when `Name.md` is beside it), and convert the highest round only;
- write the output to `<kind>/<Name>.nb` with `Name` from the frontmatter, which must equal the last segment of `URI` — the documentation system resolves `guide/<Name>` to `Guides/<Name>.nb`, so the output file name is the URL;
- skip `*.provenance.md`, which sits beside every revised document and matches `*.md`;
- glob one level only, so `Archive/` is skipped.
  PureMath's recursive glob (`FileNames["*.md", dir, Infinity]`) would pick `Archive/` up.

Two stems claiming one `URI` is an error, not a choice.

**Recommendation.** (a), InfraGeometry's layout: it already holds 165 sources there, and the trial needs no migration.
`docs` joins `build` in the plugin's staging exclusions.

## 2. Which deploy path

**The options.**

- (A) Extend `scripts/deploy_paclet_docs.wl`: each page a public cloud notebook, an HTML index, `paclet:` links rewritten.
- (B) The stock paclet resource, InfraGeometry's `publish_docs.wls` after PureMath's `publish.wls`: `PacletBuild`, then a scraped resource definition deployed publicly; the cloud resolves `paclet:` links itself.
- (C) PureMath's full path: (B) plus `build_docs_site.wls`, which re-hosts every page as static HTML from the cloud's `statichtml` endpoint inside one framing page with a guide tree.

| | (A) cloud notebooks | (B) paclet resource | (C) B + site shell |
|---|---|---|---|
| What a reader sees | the **authoring** notebook — Metadata, Categorization, Keywords and History sections, authoring stylesheet; a plain list of pages | the **built** page inside a shingle: a rail of every guide, tutorial and symbol, the install command, the paclet description | the built pages as static HTML, a collapsible guide tree, no shingle chrome |
| Guides and tutorials | guides only; `Tutorials/` is not read | both | both |
| Links | rewritten by the script; whether the viewer makes them clickable was never checked | resolved by the cloud; a chip on a guide opens the symbol's page (the DocsSite T3 test, accepted) | rewritten to the re-hosted pages |
| Front end | none | `PacletBuild` drives one | the same, plus 16 parallel fetches |
| Cost | not timed; 21 pages for MathNotebook | build 203 s for 165 pages; deploy 11–16 min and an HTTP check of 4 min for 216–239 pages | (B) plus the re-host |
| Fragility | none known | five private functions redefined (`htmlFragmentExport`, `codeInspectFileQ`, `prefetchURL`, `setDNCProgress`, `pacletDeclaredSymbols`) and two called; two of three deploys at 1.9.0 lost a page or two to a network timeout, and the retry wrapper that fixed it lives only in a scratch copy; each run replaces the site, which is 404 for the minutes it takes | (B)'s, plus its own |
| Evidence it works | the only deployment, MathNotebook's, no longer exists | live; 199 to 239 URLs `200` anonymously at every publish since 2026-09-28 | live for PureMath, 1,480 pages |

Three facts settle most of the table:

- **(A) publishes the wrong notebook.** The plugin builds with `CreatePacletArchive`, which runs no `DocumentationBuild`, so both the archive and the deployment carry authoring notebooks.
  The measured style difference above is what a reader of (A) would see.
  Fixing that means running `PacletBuild` anyway, which is (B)'s front-end cost without (B)'s navigation.
- **Seats are not the constraint.** The front end that `PacletBuild` drives is not a license process, and `PacletBuild` ran inside the MCP kernel in 203 s.
  The Technical details' "takes a seat" was a guess.
  This machine's licence has no process cap at all, so the kernel policy's headroom check passes here whatever the path.
- **(C) answers a problem InfraGeometry has not shown.** PureMath built its shell because the stock embed waits one second for the cloud to render a page and heavy pages came back empty.
  The anonymous fetches above got InfraGeometry's heaviest tutorial rendered in full, but they ask for the `.nb` directly, not through the shingle's script.
  Whether a reader's browser shows the shingle's embed in time is unverified.

**Recommendation.** (B), which InfraGeometry runs today and which the user chose for it on 2026-09-28.
(C)'s shell is a later item, if a browser check shows the embed coming back empty.
(A) is retired; reference pages ship built either way.

The deploy step was not run here (no public deploy in T1).
Whether a 16-minute deploy fits the MCP evaluator's time limit is untested; InfraGeometry runs it as `wolframscript`, which on this licence costs nothing.

## 3. What the pinned converter still needs

The Technical details assumed the 55 % workaround share of PureMath's `build_notebooks.wls` was still open.
It is not:

- `afd7c1e` ("fill paclet/guide/tutorial template slots natively") and `6350620` (frontmatter `Links`, #127) are ancestors of the pin `204db7c`, 14 and 38 minutes before it.
- PureMath removed its template shims itself on 2026-07-28 (PR #134: guide `RelatedTutorials`, legacy tutorial categorization, description and empty examples, external links — each "fixed upstream").
  Its `build_notebooks.wls` is 258 lines at `6e9d9c55`, against 356 at `17baf04`.
- InfraGeometry's `build_docs.wls` calls `MarkdownToNotebook[src, out]` at the pin with no shim, and the archive built today holds a page for every one of its 165 sources.

What is left, and who needs it:

| Still needed | Why | Where it lives today |
|---|---|---|
| link check | a guide's `` `Sym` `` chip links to `ref/Sym` whether a page exists or not, so a missing page is a dead link on the site, never a build error | `build_docs.wls` |
| metadata check | a page without `Categorization` cells is `Skip[MissingEntityType]` and silently left out of the archive | `build_docs.wls` |
| unevaluated-example check | a wrong call returns unevaluated and is baked in as the answer | `build_docs.wls` |
| source check | `Template` must match the folder, `URI` the kind and name | `build_docs.wls`; the name half changes under § 1 |
| two message suppressions | `System`AllowKernelInitialization` created first, `General::shdw` off, or message cells are baked into outputs | `build_docs.wls` |
| a clean `build/` | `PacletBuild`'s staging is additive: a deleted page ships anyway | `check_docs_package.wls` |
| one scratch directory per worktree | two checks sharing `$TemporaryDirectory/si-docs-package` deleted each other's staged paclet on 2026-10-03 | `check_docs_package.wls`, by environment variable |
| the `ResourceDefinition` normalisation | the `Paclet` template still emits an empty Examples group | PureMath only; (B) needs it only for the shingle |

The batch shims — the `ResourceObject` wrap, `TimeConstrained[…, 240]`, the straggler retry, the tolerated-failure exit — protect a parallel cloud batch of 1,480 pages and do not apply to a local clone.

Two limits of the converter shape the guides rather than the build: the `## Abstract` is one paragraph (a longer introduction goes as plain list items under `## Functions`), and `\mathbb` is dropped when the `Wolfram/Parser` paclet is absent.

The pin itself is a question.
Upstream `3462fc5`, seven commits past it, makes `CellID` and `ExpressionUUID` deterministic; at the pin a full rebuild changes every notebook's UUIDs and has to be reverted by hand.
This repo's own clone already sits on `01f0e30`, past the pin ([MarkdownToNotebook](../Resources/MarkdownToNotebook.md)).

## 4. One guide or several

**The evidence.**

- InfraGeometry has seven guides, and their names are exactly the seven subfolders of `Kernel/`: `EuclideanInfrageometry`, `RiemannianInfrageometry`, `InfraTopology`, `InfraAnalysis`, `InfraFiberBundles`, `InfraSubstrates`, `Experimental`.
  Together they list 255 functions in 63 sections: 169 chips to a page, 86 names in bold with no page yet.
- The rules there (`EuclideanGuideScheme`, `DocsSiteRelease`, `PacletBlueprint`): a symbol sits on **one** guide, and whatever no category claims goes on `Experimental` (both the user's); a category is a kernel folder and does not reach into another (the LLM's, under the user's delegation).
- One guide is the main page (`MainGuide` in `docs/ResourceDefinition.md`), and every guide lists the others in `RelatedGuides`.
  The shingle's rail orders guides by file name, which the user accepted.
- PureMath has 108 guides by mathematical domain, written flat; the navigation tree comes from the guide-to-guide links, not from folders.
- MathNotebook has 21 exports and no subfolders: one guide.

**Recommendation.** One guide per subfolder of `Kernel/` when there are subfolders, else one guide.
Every export on exactly one guide, a catch-all for the rest, one main guide that links the others.
The rule is structural, so the plugin can apply it without judging the mathematics; the topics within a guide are the drafting, and the user's revision.

## What T2 rules on

1. The deploy path: (B) proposed.
2. Where the sources live: `<pacletDir>/docs/` proposed, with the latest-version rules of § 1.
3. How many guides: one per kernel subfolder proposed.
4. Reference pages.
   The item requires them to stay on the official MCP doc tools.
   Against it: those tools are not attached in the default MCP profile (they attach only under `MCP_SERVER_NAME -> "WolframPacletDevelopment"`, per the InfraGeometry article); InfraGeometry dropped them for MarkdownToNotebook on 2026-08-12; and a page made by the tools has no Markdown source, so no revision round can work on it.
   A tree mixing the two engines was not tried.
5. The converter pin: stay on `204db7c`, or move to a SHA with deterministic IDs.
6. InfraGeometry after T4: keep its own scripts, or switch to the plugin's.

## See also

- [Generating Wolfram paclet documentation](PacletDocumentation.md) — the reference-page path this item extends
- [PureMath](../Resources/PureMath.md) — the reference implementation
- [MarkdownToNotebook](../Resources/MarkdownToNotebook.md) — the converter, its pin and its clone
- `Work/Active/DocumentationSite.md` — the item
