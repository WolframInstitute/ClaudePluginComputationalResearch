# Guide pages and tutorials, deployed like PureMath

*[ LLM Generated ]*

> Type: feature
> Target: `skills/paclet-docs`, `skills/paclet-publish`, `scripts/deploy_paclet_docs.wl`
<!-- Status is the folder: Backlog/ Ready/ Active/ UnderReview/ Done/ Dropped/. Move the file to change it. -->

## Summary

A paclet gets documentation that a person can read without installing it: a guide page for the overview, tutorials that walk through the ideas in pictures, and a reference page for every function.
The plugin drafts the guide pages and the tutorials, and you correct them in revision rounds, as with any other document.
The whole set is deployed as one public site, as PureMath's is.

## Motivation

- Today a paclet has only reference pages; nothing gives the overview or teaches the ideas.
- A reader must install the paclet, or read its source, to see how the functions fit together.
- PureMath shows the shape that works: guide pages, tutorials and reference pages built from Markdown and deployed as one site.
- Guide pages were left to the human on 2026-07-27; revision rounds now keep the judgement with you while the plugin does the writing.

## Acceptance criteria

The README's paragraph on paclet documentation in *Notebooks and paclets* is true:

- The plugin drafts a guide page that lists every exported function by mathematical topic, each with one line.
- It drafts tutorials as walkthroughs in pictures, under the notebook content rules.
- Guide pages and tutorials are documents in progress: `<< … >>` notes and `/document-revise` rounds work on them, and the build takes the latest version.
- Guide pages, tutorials and reference pages link to each other, and resolve in the product after an install.
- Publishing deploys all of them as one public site that needs no install.
- InfraGeometry has a deployed guide page and one deployed tutorial.

## Prompt history

- 2026-07-27 — "You dont have to do guide pages then. This is anyway better for humans" (the decision this item reverses)
- 2026-10-05 — "For human-accessible documentation and overview, PureMath-style deployed documentation, with guide pages and tutorials written as research notebooks."
- 2026-10-05 — "what work items do ia hve to do/refine to eimplement? Can you refine? and run autolab after"
- 2026-10-05 — chose "LLM drafts, you revise" for guide pages, and "Walkthrough in pictures" for tutorials.

## Technical details

### What exists

- `paclet-docs` writes reference pages only, through the official MCP doc tools, into `Documentation/English/ReferencePages/Symbols/`; its § *Guide pages are out of scope — Critical* forbids guides (`skills/paclet-docs/SKILL.md:25`). The official set has no guide or tutorial tool ([PacletDocumentation](../../Wiki/Concepts/PacletDocumentation.md)).
- `paclet-publish` step 3 deploys the pages as public cloud notebooks with an HTML index (`scripts/deploy_paclet_docs.wl`); it already picks up `Guides/*.nb`, not `Tutorials/`.
- PureMath ([resource](../../Wiki/Resources/PureMath.md)) keeps Markdown sources in `docs/en/{Guides,ReferencePages/Symbols,Tutorials}/` with frontmatter (`Template`, `Name`, `Title`, `URI`, `SeeAlso`, `RelatedGuides`, `RelatedTutorials`, …), builds them with MarkdownToNotebook's `Guide` and `TechNote` templates (`scripts/build_notebooks.wls`), runs `DocumentationBuild` and deploys a Paclet resource whose pages are HTML (`scripts/publish.wls`), plus a thin site shell that iframes them (`scripts/build_docs_site.wls`).
- PureMath's guide rules are `PureMath/.agent-skills/wolfram-guide-page/SKILL.md`: sections in the order of the mathematics, every important function on one line, built-ins interspersed and marked `(WL)`.
- `build_notebooks.wls` was 55 % workaround for the converter's documentation templates; upstream commit `afd7c1e` fills those slots natively. What is still needed is unmeasured.

### Requirements

- Reference pages stay on the official MCP tools; guide pages and tutorials are built from Markdown by the pinned MarkdownToNotebook, the one engine that has templates for them.
- The guide rules are lifted from PureMath into a sibling file of `paclet-docs`, adapted to one paclet; a guide carries every exported function of the paclet.
- A tutorial follows the notebook content rules of `notebook-create`: a discovery walkthrough, one picture per concept, examples as self-contained snippets, `[[ LLM Generated ]]` under the title.
- The sources are documents in progress under the folder rule: numbered versions beside each other, earlier ones in `Archive/`; the page name comes from the frontmatter, never from the file name, so `_2` does not reach a URL.
- Building and deploying follow the kernel policy: `DocumentationBuild` drives a front end and takes a seat, so headroom is checked first.
- A public cloud deploy is outward-facing: only a `(human)` task makes one; design sessions deploy privately or not at all.

### Design questions for T1

T1 answers each with evidence; T2 is your ruling.

1. Where the sources live in a paclet project (`Code/Docs/`, beside the paclet, or in it), and how the build picks the latest version.
2. Which deploy path: extend `deploy_paclet_docs.wl` (cloud notebooks, no front end), or PureMath's (HTML through `DocumentationBuild`, a Paclet resource and a site shell), compared on what a reader sees, on cost and on seats.
3. Which of PureMath's build workarounds the pinned converter still needs.
4. One guide per paclet, or a guide per area for a large one.

### Edge cases & out of scope

- A paclet driven by the front end cannot carry evaluated examples ([PacletDocumentation](../../Wiki/Concepts/PacletDocumentation.md)); its tutorials say so rather than show a failed evaluation.
- Out of scope: PureMath's tree of hub and root guides, submission to the Paclet Repository, other languages.

## Tasks

- [ ] T1 (model: opus, effort: xhigh — design-critical) — answer the four design questions on InfraGeometry with evidence, in `Wiki/Concepts/PacletGuidesAndTutorials.md`; correct Technical details where they guessed; no public deploy.
- [ ] T2 (human) — rule on the design.
- [ ] T3 (model: opus, effort: high — protocol writing) — `paclet-docs` drafts the guide page and tutorials from Markdown, the guide rules in a sibling file, revision rounds on the sources; lift the *out of scope* section.
- [ ] T4 (model: opus, effort: high — cross-cutting) — `paclet-publish` and its scripts build and deploy guide pages, tutorials and reference pages as one site, links between them rewritten.
- [ ] T5 (human) — trial on InfraGeometry: draft the guide page and one tutorial, one revision round each, publish, read the site in a browser.
- [ ] T6 (model: sonnet, effort: high — doc pass) — README, ARCHITECTURE, the `PacletDocumentation` article, the blog post, a version bump.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Fresh item; nothing in flight.
InfraGeometry, the trial paclet, is at `~/Library/CloudStorage/Dropbox-WolframInstitute/Pavel Hajek/Infrageometry/FromPavel/SubProjects/SubProjectsMain/InfraGeometry`; read it, never write it before T5.
PureMath is the gitignored clone `/Users/pavel/Library/CloudStorage/OneDrive-Personal/Programming/ClaudePlugins/ComputationalResearch/PureMath`, absent from a worktree; read it there, never write it.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-10-05 | The plugin drafts guide pages; you revise them (reverses `PacletDocumentation`'s 2026-07-27 row) | Revision rounds keep the editorial judgement with you, and a human reader needs the overview; your call |
| 2026-10-05 | Tutorials are walkthroughs in pictures under the notebook content rules, not papers | your call |

## Progress

- **S0** 2026-10-05 — item filed from the operator's request; refined in the same sitting and moved to Ready.
