# Guide pages and tutorials, deployed like PureMath

*[ LLM Generated ]*

> Type: feature
> Autonomous: allowed
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

- `paclet-docs` writes reference pages only, through the official MCP doc tools, into `Documentation/English/ReferencePages/Symbols/`; its § *Guide pages are out of scope — Critical* forbids guides (`skills/paclet-docs/SKILL.md:25`). The official set has no guide or tutorial tool ([PacletDocumentation](../../Wiki/Concepts/PacletDocumentation.md)), and it is not attached in the default MCP profile.
- `paclet-publish` step 3 deploys the pages as public cloud notebooks with an HTML index (`scripts/deploy_paclet_docs.wl`); it already picks up `Guides/*.nb`, not `Tutorials/`. What it ships and deploys is the **authoring** notebook: the build is `CreatePacletArchive`, which runs no `DocumentationBuild`. Its one deployment, MathNotebook's, no longer exists.
- **InfraGeometry already runs PureMath's path** ([T1](../../Wiki/Concepts/PacletGuidesAndTutorials.md#infrageometry-already-runs-the-whole-pipeline)): sources in `<pacletDir>/docs/{Symbols,Guides,Tutorials}/`, `Scripts/build_docs.wls`, `check_docs_package.wls`, `publish_docs.wls`; 7 guides, 4 tutorials and 154 symbol pages live as a public paclet resource since 2026-09-28. It dropped the official doc tools for MarkdownToNotebook on 2026-08-12.
- PureMath ([resource](../../Wiki/Resources/PureMath.md)) keeps Markdown sources in `docs/en/{Guides,ReferencePages/Symbols,Tutorials}/` with frontmatter (`Template`, `Name`, `Title`, `URI`, `SeeAlso`, `RelatedGuides`, `RelatedTutorials`, …), builds them with MarkdownToNotebook's `Guide` and `TechNote` templates (`scripts/build_notebooks.wls`), runs `DocumentationBuild` and deploys a paclet resource whose pages are shingles embedding the built notebooks (`scripts/publish.wls`), plus a site shell that re-hosts them as static HTML because the stock embed came back empty for heavy pages (`scripts/build_docs_site.wls`).
- PureMath's guide rules are `PureMath/.agent-skills/wolfram-guide-page/SKILL.md`: sections in the order of the mathematics, every important function on one line, built-ins interspersed and marked `(WL)`.
- The template workarounds of `build_notebooks.wls` are gone: the upstream fixes (`afd7c1e`, `6350620`) are below the pin `204db7c`, and PureMath removed the shims on 2026-07-28. What the pinned converter still needs is [measured](../../Wiki/Concepts/PacletGuidesAndTutorials.md#3-what-the-pinned-converter-still-needs).

### Requirements

- Reference pages stay on the official MCP tools; guide pages and tutorials are built from Markdown by the pinned MarkdownToNotebook, the one engine that has templates for them. (T1's evidence questions the first half; T2 rules on it.)
- The guide rules are lifted from PureMath into a sibling file of `paclet-docs`, adapted to one paclet; a guide carries every exported function of the paclet.
- A tutorial follows the notebook content rules of `notebook-create`: a discovery walkthrough, one picture per concept, examples as self-contained snippets, `[[ LLM Generated ]]` under the title.
- The sources are documents in progress under the folder rule: numbered versions beside each other, earlier ones in `Archive/`; the page name comes from the frontmatter, never from the file name, so `_2` does not reach a URL. The converter already takes `URI` and `Entity Type` from the frontmatter; the build must write `<kind>/<Name>.nb` from the frontmatter `Name`, convert only the highest round of a stem, and skip `*.provenance.md` and `Archive/`.
- Building and deploying follow the kernel policy. `DocumentationBuild` drives a front end, which is not a license process: `PacletBuild` ran inside the MCP kernel with no extra one.
- A public cloud deploy is outward-facing: only a `(human)` task makes one; design sessions deploy privately or not at all.

### Design questions for T1

T1 answers each with evidence; T2 is your ruling.
The answers: [PacletGuidesAndTutorials](../../Wiki/Concepts/PacletGuidesAndTutorials.md).

1. Where the sources live in a paclet project (`Code/Docs/`, beside the paclet, or in it), and how the build picks the latest version.
2. Which deploy path: extend `deploy_paclet_docs.wl` (cloud notebooks, no front end), or PureMath's (HTML through `DocumentationBuild`, a Paclet resource and a site shell), compared on what a reader sees, on cost and on seats.
3. Which of PureMath's build workarounds the pinned converter still needs.
4. One guide per paclet, or a guide per area for a large one.

### Edge cases & out of scope

- A paclet driven by the front end cannot carry evaluated examples ([PacletDocumentation](../../Wiki/Concepts/PacletDocumentation.md)); its tutorials say so rather than show a failed evaluation.
- Out of scope: PureMath's tree of hub and root guides, submission to the Paclet Repository, other languages.

## Tasks

- [ ] T2 (human) — rule on the design.
- [ ] T3 (model: opus, effort: high — protocol writing) — `paclet-docs` drafts the guide page and tutorials from Markdown, the guide rules in a sibling file, revision rounds on the sources; lift the *out of scope* section.
- [ ] T4 (model: opus, effort: high — cross-cutting) — `paclet-publish` and its scripts build and deploy guide pages, tutorials and reference pages as one site, links between them rewritten.
- [ ] T5 (human) — trial on InfraGeometry: draft the guide page and one tutorial, one revision round each, publish, read the site in a browser.
- [ ] T6 (model: sonnet, effort: high — doc pass) — README, ARCHITECTURE, the `PacletDocumentation` article, the blog post, a version bump.

### Done

- [x] T1 (S1, model: opus, effort: xhigh — design-critical) — answer the four design questions on InfraGeometry with evidence, in `Wiki/Concepts/PacletGuidesAndTutorials.md`; correct Technical details where they guessed; no public deploy.
  - **Test:** read [PacletGuidesAndTutorials](../../Wiki/Concepts/PacletGuidesAndTutorials.md): one section per design question, each with the options, the evidence and a proposal, and § *What T2 rules on* with six rulings.
  - **Test:** open <https://www.wolframcloud.com/obj/hajek_pavel/DeployedResources/Paclet/WolframInstitute/InfraGeometry/Documentation/tutorial/MetricTensorTutorial.html> logged out. You should see the rail of guides, tutorials and symbols and the tutorial's text and pictures in the page; an empty page is the PureMath embed problem of § 2, which T1 could not check without a browser.
  - **Test:** open <https://www.wolframcloud.com/obj/hajek_pavel/MathNotebook/Documentation/index.html> logged out. It asks you to sign in: the plugin's one docs deployment is gone.
  - **Test:** run `git -C MarkdownToNotebook rev-parse --short HEAD` in the main checkout. It prints `01f0e30`, not the documented pin `204db7c`.

## Hand-off

T2 (human) is next: rule on the six questions in [§ *What T2 rules on*](../../Wiki/Concepts/PacletGuidesAndTutorials.md#what-t2-rules-on).
The proposals: the stock paclet resource (InfraGeometry's `publish_docs.wls`), sources in `<pacletDir>/docs/`, one guide per kernel subfolder.
Two findings touch your text, not only the design, and are left as written:

- "InfraGeometry has a deployed guide page and one deployed tutorial" is already true through InfraGeometry's own scripts; T5 shows the plugin's work only if it runs the plugin's path.
- The first requirement keeps reference pages on the official MCP tools, which InfraGeometry dropped and the default MCP profile does not attach.

InfraGeometry, the trial paclet, is at `~/Library/CloudStorage/Dropbox-WolframInstitute/Pavel Hajek/Infrageometry/FromPavel/SubProjects/SubProjectsMain/InfraGeometry`; read it, never write it before T5.
Its paclet is the submodule `InfraGeometry/InfraGeometry/`; its docs scripts are in the dev repo's `Scripts/`, and its pinned converter clone is `SubProjectsMain/DiscreteGeometry/MarkdownToNotebook/` at `204db7c`.
PureMath is the gitignored clone `/Users/pavel/Library/CloudStorage/OneDrive-Personal/Programming/ClaudePlugins/ComputationalResearch/PureMath`, absent from a worktree; read it there, never write it.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-10-05 | The plugin drafts guide pages; you revise them (reverses `PacletDocumentation`'s 2026-07-27 row) | Revision rounds keep the editorial judgement with you, and a human reader needs the overview; your call |
| 2026-10-05 | Tutorials are walkthroughs in pictures under the notebook content rules, not papers | your call |

## Progress

- **S0** 2026-10-05 — item filed from the operator's request; refined in the same sitting and moved to Ready.
- **S1** 2026-10-05 T1 — the four questions answered on InfraGeometry, which already runs PureMath's path; Technical details corrected. Opus tier, `/backlog-autolab` worker. → [PacletGuidesAndTutorials](../../Wiki/Concepts/PacletGuidesAndTutorials.md), [PacletDocumentation](../../Wiki/Concepts/PacletDocumentation.md), [MarkdownToNotebook](../../Wiki/Resources/MarkdownToNotebook.md), [MathNotebook](../../Wiki/Resources/MathNotebook.md), [PureMath](../../Wiki/Resources/PureMath.md)
