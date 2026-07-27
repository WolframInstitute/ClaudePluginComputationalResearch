# AdoptMarkdownToNotebook

*[ LLM Generated ]*

> Type: investigation

## Spec

Origin: "keep the official tools then for the time being, but the evaluation for later task" — deferring the MarkdownToNotebook engine question out of `PacletDocumentation` (2026-07-27).

`EvaluateMarkdownToNotebook` (see `Work/Done/2026-07-27-EvaluateMarkdownToNotebook.md`) recommended depending on `WolframInstitute/MarkdownToNotebook` at arm's length, in four phases.
`PacletDocumentation` then chose the **official MCP doc tools** instead, for the time being, so that recommendation is live but unexecuted.
This item carries it.

Two things happened after that evaluation that strengthen the case, and one that still blocks it:

- **PureMath is the existence proof.** `WolframInstitute/PureMath` authors 1,480 Markdown doc pages — 100 guides, 1,380 symbol pages — and converts them with the deployed MarkdownToNotebook resource function before running `DocumentationBuild`. It ships forks of the `wolfram-guide-page` and `wolfram-symbol-page` skills to do it.
- ~~**The official tools have no guide-page tool.**~~ **This argument is void as of 2026-07-27.** It was the strongest technical case for MarkdownToNotebook, and it died when the user removed guide pages from scope entirely: "You dont have to do guide pages then. This is anyway better for humans." A guide page is now a human deliverable, so the gap in the official set costs nothing. Do not re-open this item on the guide-page argument.
- **It still has no licence and no pinnable release.** `license: null`, no `LICENSE` file, no tags, and commits landing daily from a single author.

### Requirements

- **Phase 0 first, and it is external.** Ask Nikolay Murzin for a `LICENSE` (MIT would match ours), the status of the pending Function Repository review, and a tag or pinnable commit. Nothing else in this item is worth doing until at least the licence question is answered, because it decides whether vendoring is even available as a fallback.
- Re-measure before trusting the earlier evaluation: the repo moves daily, so the feature diff, the deployed-resource URL, and the shim list below may all have changed.
- Cost the **shim tax** honestly. `PureMath/scripts/build_notebooks.wls` carries roughly ten documented workarounds for MarkdownToNotebook's behaviour — the frontmatter parser mangling `Links: [...]`, eight bare scaffolded `Subsection`s from the Paclet template, tutorials still categorised as legacy "Tech Note" instead of the modern `Tutorial` entity, and `guideNotebook` having no code path for `RelatedTutorials`. Any adoption inherits these.
- Decide whether adoption is **per-skill or plugin-wide**. The remaining candidates are `new-notebook`'s rich mode (Phase 1 of the original recommendation — the constructs the MCP append-cell transport cannot carry) and `research-notebook`'s md↔nb sync (Phase 2, still blocked on line-break preservation). The guide page is no longer a candidate.
- If anything is adopted, register the repo in `Wiki/` via `add-resource` with recovery info — noting that this project has no `Wiki/` yet, so `init-wiki` comes first.

### Design / risks

- **The line-break problem is a hard blocker for the sync direction.** `NotebookToMarkdown` reflows soft line breaks into single lines, which breaks this project's `Semantic line breaks: on` rule and would put a whole-file diff into every `research-notebook` sync. It needs either an upstream option that preserves line breaks or a re-wrap post-step on our side.
- The deployed resource lives at a personal `obj/nikm/` cloud path that can disappear without notice. That is the main argument for Phase 0's third ask.
- `ensureParser[]` installs the `Wolfram/Parser` paclet at call time when absent, so a first conversion on a fresh machine does network I/O; it degrades to `ImportString[…, "TeX"]` rather than failing, with worse math fidelity.
- No package boundary: `MarkdownToNotebook.wl` is one 5273-line file of interdependent private definitions, so there is no way to patch a bug locally short of a fork.

### Edge cases & out of scope

- Do **not** run `install-skills.sh`. Symlinked personal skills track the repo's `main` — a live feed — and their trigger descriptions compete with `build-paclet` / `publish-paclet` with nothing to arbitrate. If those genres are wanted, reimplement them as `computational-research:` skills.
- Do not revisit the `demo-notebook` retirement; that is settled and executed.
- **Abandon condition:** if the licence request is declined and the Function Repository review stalls, cap the relationship at reading `docs/` for design ideas and keep the official tools.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T1 — Phase 0: ask upstream for a licence, the FR review status, and a pinnable tag; record the answers. Blocks the rest.
- [ ] T2 — Re-measure the repo against the 2026-07-27 evaluation; note what changed.
- [ ] T3 — Cost the shim tax from `PureMath/scripts/build_notebooks.wls` and decide per-skill vs plugin-wide adoption.
- [ ] T4 — If adopting: implement the chosen surface and register the resource in `Wiki/`.

### Done

(completed tasks move here with the session that closed them)

## Progress

(no sessions yet)

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | Deferred out of `PacletDocumentation` rather than dropped. | The evaluation's recommendation was to depend, and PureMath proves the approach works at 1,480 pages, but the missing licence makes it a bad dependency to take on today. The official MCP tools are good enough for symbol pages. |
| 2026-07-27 | The guide-page gap is no longer a reason to adopt. | Guide pages left scope the same day. What remains in favour is `new-notebook`'s rich mode (Phase 1) — the constructs the MCP append-cell transport cannot carry — and nothing else urgent. This item is now genuinely low priority. |
