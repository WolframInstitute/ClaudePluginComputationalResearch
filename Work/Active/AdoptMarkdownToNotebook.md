# AdoptMarkdownToNotebook

*[ LLM Generated ]*

> Type: investigation

## Spec

Origin: "keep the official tools then for the time being, but the evaluation for later task" — deferring the MarkdownToNotebook engine question out of `PacletDocumentation` (2026-07-27).

`EvaluateMarkdownToNotebook` (see `Work/Done/2026-07-27-EvaluateMarkdownToNotebook.md`) recommended depending on `WolframInstitute/MarkdownToNotebook` at arm's length, in four phases.
`PacletDocumentation` then chose the **official MCP doc tools** instead, for the time being, so that recommendation is live but unexecuted.
This item carries it.

Three things happened after that evaluation; as of T1 (2026-07-27) none of them blocks the item any longer:

- **PureMath is the existence proof.** `WolframInstitute/PureMath` authors 1,480 Markdown doc pages — 100 guides, 1,380 symbol pages — and converts them with the deployed MarkdownToNotebook resource function before running `DocumentationBuild`. It ships forks of the `wolfram-guide-page` and `wolfram-symbol-page` skills to do it.
- ~~**The official tools have no guide-page tool.**~~ **This argument is void as of 2026-07-27.** It was the strongest technical case for MarkdownToNotebook, and it died when the user removed guide pages from scope entirely: "You dont have to do guide pages then. This is anyway better for humans." A guide page is now a human deliverable, so the gap in the official set costs nothing. Do not re-open this item on the guide-page argument.
- ~~**It still has no licence and no pinnable release.**~~ **Partly resolved as of 2026-07-27 (T1).** The licence objection is cleared — the user confirmed the licence is fine, so vendoring stays available as a fallback and the abandon condition below cannot fire on licence grounds.
  What remains is cosmetic rather than blocking: the repo still carries no `LICENSE` file (`license: null`), and there are still no tags or releases — but pinning by SHA works today, so "no pinnable release" was never really a blocker either.
  Commits still land near-daily, though no longer from a single author (96 of the last 100 by Nikolay Murzin, 4 by Mads Bahrami).

### Requirements

- ~~**Phase 0 first, and it is external.**~~ **Done 2026-07-27 (T1).** The licence question — the one that gated everything else — is answered: fine.
  A standing, non-blocking ask remains open with Nikolay Murzin for an in-tree `LICENSE` (MIT would match ours), so a vendored copy has something to point at.
  The Function Repository review is still pending and no tag exists; neither blocks adoption, since the current tip pins by SHA.
- Re-measure before trusting the earlier evaluation: the repo moves daily, so the feature diff, the deployed-resource URL, and the shim list below may all have changed.
- Cost the **shim tax** honestly. `PureMath/scripts/build_notebooks.wls` carries roughly ten documented workarounds for MarkdownToNotebook's behaviour — the frontmatter parser mangling `Links: [...]`, eight bare scaffolded `Subsection`s from the Paclet template, tutorials still categorised as legacy "Tech Note" instead of the modern `Tutorial` entity, and `guideNotebook` having no code path for `RelatedTutorials`. Any adoption inherits these.
- Decide whether adoption is **per-skill or plugin-wide**. The remaining candidates are `new-notebook`'s rich mode (Phase 1 of the original recommendation — the constructs the MCP append-cell transport cannot carry) and `research-notebook`'s md↔nb sync (Phase 2, still blocked on line-break preservation). The guide page is no longer a candidate.
- If anything is adopted, register the repo in `Wiki/` via `add-resource` with recovery info — noting that this project has no `Wiki/` yet, so `init-wiki` comes first.

### Design / risks

- **The line-break problem is a hard blocker for the sync direction.** `NotebookToMarkdown` reflows soft line breaks into single lines, which breaks this project's `Semantic line breaks: on` rule and would put a whole-file diff into every `research-notebook` sync. It needs either an upstream option that preserves line breaks or a re-wrap post-step on our side.
- The deployed resource lives at a personal `obj/nikm/` cloud path that can disappear without notice. Phase 0 is closed without securing a tag, so this risk stands: any adoption should call the local `MarkdownToNotebook.wl` at a pinned SHA rather than the deployed resource URL.
- `ensureParser[]` installs the `Wolfram/Parser` paclet at call time when absent, so a first conversion on a fresh machine does network I/O; it degrades to `ImportString[…, "TeX"]` rather than failing, with worse math fidelity.
- No package boundary: `MarkdownToNotebook.wl` is one 5273-line file of interdependent private definitions, so there is no way to patch a bug locally short of a fork.

### Edge cases & out of scope

- Do **not** run `install-skills.sh`. Symlinked personal skills track the repo's `main` — a live feed — and their trigger descriptions compete with `build-paclet` / `publish-paclet` with nothing to arbitrate. If those genres are wanted, reimplement them as `computational-research:` skills.
- Do not revisit the `demo-notebook` retirement; that is settled and executed.
- **Abandon condition (revised 2026-07-27, T1):** the licence leg is spent — it cannot fire.
  What is left to abandon on is value, not permission: if T2's re-measurement and T3's shim-tax costing show the remaining candidate surfaces (`new-notebook` rich mode, `research-notebook` md↔nb sync) do not clear their cost, cap the relationship at reading `docs/` for design ideas and keep the official tools.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T2 — Re-measure the repo against the 2026-07-27 evaluation; note what changed.
- [ ] T3 — Cost the shim tax from `PureMath/scripts/build_notebooks.wls` and decide per-skill vs plugin-wide adoption.
- [ ] T4 — If adopting: implement the chosen surface and register the resource in `Wiki/`.

### Done

- [x] T1 — Phase 0: ask upstream for a licence, the FR review status, and a pinnable tag; record the answers. Blocks the rest. *(Session 1)*

## Progress

### Session 1 — 2026-07-27 — T1

- **Prompt:** "licence of markdown to notebook is fine" — the user volunteered the answer to Phase 0's blocking question, which started the item.
- **Did:** Closed Phase 0 by answering its three questions and recording them.
  Moved the item from `Backlog/` to `Active/`.
  The licence question is answered by the user: fine.
  The Function Repository review is still pending — the README at the current tip (`204db7c`, 2026-07-26) still says so, unchanged from the 2026-07-27 evaluation.
  There is still no tag and no release, but the item's framing of that as a blocker was wrong: pinning by SHA works today, and our local clone already sits exactly on the tip.
  Per the user's decision, a standing non-blocking ask for an in-tree `LICENSE` stays open with Nikolay Murzin.
  Revised the Spec accordingly — the licence bullet, the Phase 0 requirement, and the abandon condition, which can no longer fire on licence grounds.
- **Learned:** `ResourceObject[...]` lookups fail from the MCP kernel even for known-published Function Repository entries, so that is not a usable probe for FR publication status.
  Read the upstream README instead.
  Curl against `resources.wolframcloud.com` is equally useless — a published and an unpublished resource both return the same 302 to an OAuth check.
  Upstream has moved in a direction that matters to the tasks still open: commit `afd7c1e` — "fill paclet/guide/tutorial template slots natively so build shims can drop" — attacks the exact shim tax T3 exists to cost, and `#59`/`#61`/`#62` are math and message fidelity fixes.
  T2 should therefore expect the 2026-07-27 measurement to be materially stale rather than confirm it.
  Authorship is also no longer single-author (96 of the last 100 commits Nikolay Murzin, 4 Mads Bahrami), which mildly softens the bus-factor risk the Spec records.
- **Next:** T2 — re-measure the repo against the 2026-07-27 evaluation; note what changed.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | Deferred out of `PacletDocumentation` rather than dropped. | The evaluation's recommendation was to depend, and PureMath proves the approach works at 1,480 pages, but the missing licence makes it a bad dependency to take on today. The official MCP tools are good enough for symbol pages. |
| 2026-07-27 (S1) | The licence blocker is cleared; keep a standing, non-blocking ask for an in-tree `LICENSE`. | The user confirmed the licence is fine, which is what Phase 0 needed — vendoring survives as a fallback and adoption is no longer gated on permission. The file itself is still worth having so a vendored copy has something to point at, but waiting on it would block nothing. |
| 2026-07-27 (S1) | "No pinnable release" is dropped as a risk. | The absence of tags was conflated with the absence of a pin. Pinning by SHA works today (`204db7c`, 2026-07-26), and the local clone is already on it. |
| 2026-07-27 | The guide-page gap is no longer a reason to adopt. | Guide pages left scope the same day. What remains in favour is `new-notebook`'s rich mode (Phase 1) — the constructs the MCP append-cell transport cannot carry — and nothing else urgent. This item is now genuinely low priority. |
