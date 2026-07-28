# PureMath

*[ LLM Generated ]*

`WolframInstitute/PureMath`, https://github.com/WolframInstitute/PureMath (**private**).
Read at `17baf04`.

Harvested 2026-07-28 from the closed items `PacletDocumentation` and `AdoptMarkdownToNotebook` — see [Progress Harvest](../Concepts/ProgressHarvest.md).

## Why it is in this wiki

It is the **reference implementation** the `PacletDocumentation` item was pointed at, and it is the existence proof for the MarkdownToNotebook pipeline at scale.
It is not a dependency of this plugin — nothing here calls it. It is read for design.

## The single most important thing about it

**PureMath does not author `.nb` documentation at all.**
It authors **Markdown** — 1,480 pages, 100 guides plus 1,380 symbol pages — and converts them with the deployed [MarkdownToNotebook](MarkdownToNotebook.md) resource function before running `DocumentationBuild`.
`scripts/build_notebooks.wls` calls the resource function directly by its cloud URL.

It also ships `.agent-skills/wolfram-guide-page/` and `.agent-skills/wolfram-symbol-page/` — specialised forks of two of MarkdownToNotebook's own 12 personal skills, one of which says outright "build it with MarkdownToNotebook".

So the reference implementation named in the origin of `PacletDocumentation` *is* the MarkdownToNotebook pipeline. This plugin nevertheless took the official MCP doc tools — see [Paclet Documentation](../Concepts/PacletDocumentation.md#the-engine-choice-and-what-it-cost).

## Layout

`docs/en/{Guides,ReferencePages/Symbols,Tutorials}/`, nested by mathematical domain (`Guides/Geometry/DifferentialGeometry/`, `ReferencePages/Symbols/Algebra/LieTheory/`), plus a parallel `docs/dev/en/` tree for the dev paclet.

Frontmatter on every page: `Template`, `Name`, `Title`, `Context`, `Paclet`, `URI`, `Description`, `Keywords`, `SeeAlso`, `RelatedGuides`, `RelatedTutorials`.
`URI` is the in-product address, e.g. `WolframInstitute/PureMath/ref/ConjugatePriorQ`.

The guide shape is literally "function list first, then examples": `## Abstract`, then `## Functions` with `###` subsections of one-line `` `Symbol` `` bullets, `(WL)` marking built-ins folded in alongside the paclet's own, and `<!-- SUGGESTED: … -->` marking planned symbols.
Symbol pages run `## Usage`, `## Details & Options`, `## Basic Examples`, `## Possible Issues`.
Links to symbols are written `<code>[Symbol]()</code>` (MarkdownToNotebook's inferred-link form), expected results as `<!-- => True -->` comments, and design-review notes as `<!-- #| annotation: … -->`.

## Build

`lint_docs.wls` (house-style lint — notably every ` ```wl ` cell must satisfy `SyntaxQ` **without evaluation**), `build_notebooks.wls` (the conversion), `run_doc_examples.wls`, `publish.wls`, `build_docs_site.wls`, `clean_deployed_docs.wls`.

CI lints and tests on a hosted runner, then does the heavy build on a **provisioned 16–32 vCPU Prime Intellect pod**, because hosted runners cap at 2–4 vCPUs and, in the workflow's own words, that "barely parallelizes the Wolfram doc build".

`build_docs_site.wls` deploys the documentation to a public URL and CI prints it, with `clean_deployed_docs.wls` maintaining it.
That "publish the docs twice" pattern is what made retiring `demo-notebook` safe here.

## The shim tax, and why it did not transfer

`build_notebooks.wls` is 356 lines of which **197 are workarounds for MarkdownToNotebook's behaviour** — 55 % by line, across twelve blocks: `markdownSection`, the template-group helpers, the `Links:` frontmatter re-parse with its `Hash[url]` CellID trick, the eight vestigial scaffolded `Subsection`s, `normalizePacletNotebook`, "Tech Note" → `Tutorial`, the Guide `RelatedTutorials` slot, the normalizer `Scan`s, the `ResourceObject[url]` wrap that makes the function resolve on a fresh subkernel, a `TimeConstrained[…, 240]` hang bound, a serial straggler retry, and a tolerated-failure exit policy.

That number is real and does **not** transfer, for a structural reason rather than a lucky one:

- **160 of the 197 repair DocumentationTools template slots** (`Paclet` / `Symbol` / `Guide` / `TechNote`). Every one is a repair to a *filled template* — a slot left empty, filled wrong, or scaffolded when it should not be. `Template: Default` has no slots: `defaultNotebook[data]` returns a bare `Notebook[cells, StyleDefinitions -> "Default.nb"]`. There is nothing to repair, and the shims are inert by construction — measured, with zero shim triggers on a representative source.
- **37 buy batch reliability** for 1,480 pages driven through the *cloud* resource on `Max[16, $ProcessorCount]` subkernels. Locally at N=1 a warm conversion is 0.05 s with zero variance over five runs (1.4 s on the first call, which is `ensureParser[]`). There is no straggler population to retry and no batch to tolerate failures in.

The honest statement of the cost is therefore not "55 %" but **"55 % of a doc-build script we are not writing"**.

This is worth keeping as a method note: a dependency's shim tax measured in someone else's integration prices *their* code paths, not yours. Check which paths your own usage can even reach before reading the percentage as a cost.

## Recover

Clone: git@github.com:WolframInstitute/PureMath.git
Target: PureMath
Commit: 17baf04

Private — clone over SSH with an account that has access.
The clone sits at the project root, gitignored, alongside `MathNotebook/` and `MarkdownToNotebook/`.

```bash
git clone git@github.com:WolframInstitute/PureMath.git
```

## See also

- [MarkdownToNotebook](MarkdownToNotebook.md) — the converter PureMath drives at scale
- [Paclet Documentation](../Concepts/PacletDocumentation.md) — what this plugin built instead
- [Progress Harvest](../Concepts/ProgressHarvest.md) — where this article came from
