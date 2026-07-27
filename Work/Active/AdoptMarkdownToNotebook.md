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
  Re-confirmed unchanged at T2 (2026-07-27).
- **It does not, in fact, move daily** (corrected at T2). The Spec previously called this a daily-moving target on the strength of June's cadence.
  Over the 66 days since the first commit (2026-05-22, 277 commits total) there are 39 active days, but July is bursty rather than daily: 12 active days in 26, with 4- and 5-day gaps (07-16 → 07-20, 07-21 → 07-26).
  Authorship is no longer single-author (96 of the last 100 commits by Nikolay Murzin, 4 by Mads Bahrami).

### Requirements

- ~~**Phase 0 first, and it is external.**~~ **Done 2026-07-27 (T1).** The licence question — the one that gated everything else — is answered: fine.
  A standing, non-blocking ask remains open with Nikolay Murzin for an in-tree `LICENSE` (MIT would match ours), so a vendored copy has something to point at.
  The Function Repository review is still pending and no tag exists; neither blocks adoption, since the current tip pins by SHA.
- ~~Re-measure before trusting the earlier evaluation: the repo moves daily, so the feature diff, the deployed-resource URL, and the shim list below may all have changed.~~ **Done 2026-07-27 (T2). Nothing changed.**
  `origin/main` is still `204db7c` (0 ahead / 0 behind the local clone), and every measured quantity is identical to the evaluation's: 5273 + 1505 lines, 12 skills, 12.7 MB, 0 stars, 0 forks, 0 tags, 0 releases, `license: null`, README still saying Function Repository publication "is pending review".
  The T3 feature diff therefore stands verbatim and needs no re-run.
- ~~Cost the **shim tax** honestly.~~ **Done 2026-07-27 (T3). It is 197 of 356 lines — and 160 of those 197 cannot fire on our surfaces.**
  `PureMath/scripts/build_notebooks.wls` is 55% workaround by line, but the workarounds are not general converter defects: 160 lines repair the **DocumentationTools template** code paths (`Paclet`/`Symbol`/`Guide`/`TechNote`) and 37 lines buy reliability for a 1,480-page batch driven through the *cloud* resource on 16 parallel subkernels.
  Measured against the `Default` template on the pinned local clone, every template shim is inert and the batch shims have nothing to protect.
- ~~Decide whether adoption is **per-skill or plugin-wide**.~~ **Decided 2026-07-27 (T3): per-skill, and exactly one skill — `new-notebook`.**
  `research-notebook` is dropped as a candidate; plugin-wide was never coherent, since there is no shared conversion layer to swap.
- If anything is adopted, register the repo in `Wiki/` via `add-resource` with recovery info — noting that this project has no `Wiki/` yet, so `init-wiki` comes first.

### Design / risks

- **The reverse direction is worse than a line-break problem — it loses content.** Re-measured at `204db7c` in T3 on a round-trip of a representative source.
  Reflow is real (soft line breaks join into one line, breaking `Semantic line breaks: on`), but three further losses are silent and not fixable by a re-wrap post-step: the YAML frontmatter is **dropped entirely**, the `>` blockquote marker is dropped so a callout degrades to plain prose, and a pipe table comes back with an **empty header row** and its real header demoted to a body row.
  A fourth is cosmetic: the ` ```wolfram ` fence normalises to ` ```wl `.
  Running this over a `research-notebook` source would delete its frontmatter and corrupt its tables on every sync, so the sync direction is abandoned rather than deferred.
- The deployed resource lives at a personal `obj/nikm/` cloud path that can disappear without notice. Phase 0 is closed without securing a tag, so this risk stands: any adoption should call the local `MarkdownToNotebook.wl` at a pinned SHA rather than the deployed resource URL.
  T2 verified the cloud resource **does** resolve and convert correctly today (first time it was exercised — T3 only tested the local file via `Get`), which makes the arm's-length option real rather than assumed.
  But it is **unversioned**: `ResourceObject[url]["Version"]` is `None` and there is no `"LatestUpdate"` property, so there is no way to tell which SHA it was deployed from, or to detect that it has drifted. That is a second, independent reason to prefer the pinned local file.
- `ensureParser[]` installs the `Wolfram/Parser` paclet at call time when absent, so a first conversion on a fresh machine does network I/O; it degrades to `ImportString[…, "TeX"]` rather than failing, with worse math fidelity.
- No package boundary: `MarkdownToNotebook.wl` is one 5273-line file of interdependent private definitions, so there is no way to patch a bug locally short of a fork.

### Edge cases & out of scope

- Do **not** run `install-skills.sh`. Symlinked personal skills track the repo's `main` — a live feed — and their trigger descriptions compete with `build-paclet` / `publish-paclet` with nothing to arbitrate. If those genres are wanted, reimplement them as `computational-research:` skills.
- Do not revisit the `demo-notebook` retirement; that is settled and executed.
- **Abandon condition (revised 2026-07-27, T1):** the licence leg is spent — it cannot fire.
  What is left to abandon on is value, not permission: if T2's re-measurement and T3's shim-tax costing show the remaining candidate surfaces (`new-notebook` rich mode, `research-notebook` md↔nb sync) do not clear their cost, cap the relationship at reading `docs/` for design ideas and keep the official tools.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T4 — Implement `new-notebook`'s opt-in rich mode against the pinned local clone (`Default` template, `"Evaluate" -> False`, MCP fallback) and register the resource in `Wiki/` — which means `init-wiki` first.

### Done

- [x] T1 — Phase 0: ask upstream for a licence, the FR review status, and a pinnable tag; record the answers. Blocks the rest. *(Session 1)*
- [x] T2 — Re-measure the repo against the 2026-07-27 evaluation; note what changed. *(Session 2)*
- [x] T3 — Cost the shim tax from `PureMath/scripts/build_notebooks.wls` and decide per-skill vs plugin-wide adoption. *(Session 3)*

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

### Session 2 — 2026-07-27 — T2

- **Prompt:** `/next-session AdoptMarkdownToNotebook`.
- **Did:** re-measured `WolframInstitute/MarkdownToNotebook` against the 2026-07-27 evaluation.
  **Nothing changed.**
  `git ls-remote` puts `origin/main` at `204db7c` — byte-identical to the evaluated clone, 0 ahead and 0 behind — and every quantity the evaluation recorded reproduces exactly: `MarkdownToNotebook.wl` 5273 lines, `NotebookToMarkdown.wl` 1505, 12 skills under the same names, 12.7 MB, 0 stars, 0 forks, 0 tags, 0 releases, `license: null` with no `LICENSE` file, README line 29 still saying Function Repository publication "is pending review".
  One open issue upstream (#43, captured kernel messages render as plain text rather than the styled banner).
  Revised the Spec: the re-measure requirement is struck as done, the cadence claim corrected, and the deployed-resource risk sharpened with what the probe found.
- **Learned:** three things worth carrying.

  **T1's staleness warning was wrong, and the correction matters.**
  T1 read `afd7c1e` ("fill paclet/guide/tutorial template slots natively so build shims can drop") as upstream movement postdating the evaluation and told T2 to expect a materially stale measurement.
  It is not new: `afd7c1e` landed 2026-07-26 17:36, two commits *below* the evaluated tip `204db7c` (17:50).
  The same holds for the fidelity fixes T1 flagged — `74cbfe2` (#59), `9efde62` (#62), `55f13a3` (#61), `6350620` (#127, #64), `fe4abc2` (#63) — all shipped 2026-07-26 before the clone.
  So T3's smoke test already ran against the tree with native template slots, and T3's shim-tax costing must not assume the shims are about to become unnecessary — that change is already in the measured baseline.

  **The cloud resource works, and is unversioned.**
  T3 only ever exercised the local file via `Get`; T2 called the deployed resource itself through the MCP for the first time.
  `ResourceFunction["https://www.wolframcloud.com/obj/nikm/DeployedResources/Function/MarkdownToNotebook"]` resolved and converted a probe with inline math and a hyperlink into a 2-cell `Notebook` — `Title` + `Text` with a nested `InlineFormula`, one `SuperscriptBox`, one `ButtonBox`.
  So "depend at arm's length on the cloud URL" is a live option, not a theoretical one.
  But `ResourceObject[url]["Version"]` returns `None` and `"LatestUpdate"` is not a known property, so the deployed artifact carries no version marker at all: you cannot tell which SHA it came from, nor detect drift after the fact.

  **"Moves daily" was an artefact of June.**
  277 commits since 2026-05-22 across 39 active days, but July runs 12 active days in 26 with 4- and 5-day gaps.
  The tip's only change to executable behaviour since the earlier fixes is a `wolfr.am` short-link swap in `ensureParser[]` (`1ECIxdqhB` → `1ENEqrOlP`), the last-resort branch of the parser install chain — confirming that the `ensureParser[]` risk the Spec records sits on a code path the author is still touching.
- **Next:** T3 — cost the shim tax from `PureMath/scripts/build_notebooks.wls` and decide per-skill vs plugin-wide adoption.

### Session 3 — 2026-07-27 — T3

- **Prompt:** `/next-session`.
- **Did:** costed the shim tax by line against `PureMath/scripts/build_notebooks.wls` (356 lines, at PureMath `17baf04`), then tested empirically which shims can fire on our candidate surfaces, then decided the adoption scope.

  **The tax is 197 of 356 lines — 55% of the script is workaround.**
  Twelve blocks, comments included: `markdownSection` (14), the `templateGroupQ`/`fillTemplateGroup` helpers (8), the `Links:` frontmatter re-parse with its `Hash[url]` CellID trick (30), the eight vestigial `Subsection` names (13), `normalizePacletNotebook` (29), "Tech Note" → "Tutorial" (11), the Guide `RelatedTutorials` slot (41), the `Scan`s that apply the normalizers (14), the `ResourceObject[url]` wrap that makes the function resolve on a fresh subkernel (4), the `TimeConstrained[…, 240]` hang bound (8), the serial straggler retry (9), and the tolerated-failure exit policy (16).

  **But 160 of the 197 repair DocumentationTools templates, and 37 buy batch reliability. Neither bucket touches us.**
  Converted a representative source — YAML frontmatter, H1/H2, inline and display math, a hyperlink, a blockquote, a pipe table, a nested list, a `wolfram` fence — through the pinned local clone (`204db7c`) with `Template: Default` and `"Evaluate" -> False`.
  Result: 10 flat top-level cells, `Title / Text / DisplayFormula / Text / Section / Item×3 / 2ColumnTableMod / Input`, and **zero** of the shim triggers — no `TemplateGroupName` anywhere, 0 `Categorization` cells, 0 vestigial `Subsection`s, 0 `XXXX` placeholders, and no frontmatter leaked into a cell.
  So the 160 template lines are dead code on the `Default` path by construction: `defaultNotebook[data]` returns a bare `Notebook[cells, StyleDefinitions -> "Default.nb"]` with no template to fill or repair.
  The 37 reliability lines are a function of PureMath's scale and transport, not of the converter: they exist because 1,480 pages go through the *cloud* resource on `Max[16, $ProcessorCount]` subkernels.
  Locally at N=1 a warm conversion takes **0.05 s with zero variance over five runs** (1.4 s on the first call, which is `ensureParser[]`), so there is no straggler population to retry and no batch to tolerate failures in.

  **Decided: per-skill, and exactly one skill.** Adopt in `new-notebook` as Phase 1's opt-in rich mode; drop `research-notebook` as a candidate; plugin-wide is not a coherent option.
  Revised the Spec's two requirements and the line-break risk accordingly, and narrowed T4 to the one surface.
- **Learned:** four things.

  **The shim tax does not transfer, and the reason is structural rather than lucky.**
  Every PureMath shim is a repair to a *filled template* — a slot left empty, a slot filled wrong, a scaffolded section that should not be there.
  `Default` has no slots, so there is nothing to repair.
  The honest statement of the cost is therefore not "55%" but "55% of a doc-build script we are not writing"; our residual cost is `ensureParser[]`'s first-call paclet install (network I/O on a fresh machine, degrading silently to `ImportString[…, "TeX"]` with worse math fidelity) and the SHA pin.

  **The reverse direction is disqualifying, and worse than the evaluation recorded.**
  `NotebookToMarkdown` on the generated notebook returned 604 characters against a 793-character source, and the losses are not all formatting: the **frontmatter is gone entirely** and the **table header row comes back empty** with the real header demoted into the body.
  Both are silent content loss on a round-trip, which no re-wrap post-step fixes.
  The known reflow and the dropped `>` marker are also confirmed at this SHA.
  This is what removes `research-notebook` from scope — not the line-break rule alone.

  **`research-notebook` was already excluded by its own skill file, which I had not checked before costing.**
  `skills/research-notebook/SKILL.md` states that MarkdownToNotebook "does not produce the AMSArticle + theorem-environment research layout this skill specifies, so it does not replace the research generator", and the `Default` template confirms it: 0 `Author` and 0 `Abstract` cells, where that skill needs `[LLM Generated]` / `Title` / `Author` / `Abstract`.
  Its md↔nb sync also does not use `NotebookToMarkdown` today — it uses `ExportString[Import[path], "Markdown"]`.
  So both directions were already out; T3 only measured how far.

  **Two incidental gains for `new-notebook` that the evaluation did not name.**
  Frontmatter is *consumed as metadata* rather than leaked as a literal `Text` cell — the exact defect `research-notebook` documents in the built-in importer and hand-strips around.
  And a `wolfram` fence becomes `BoxData` that preserves the source formatting verbatim, spaces-inside-brackets and the newline after `:=` included, so the house code style survives conversion.
- **Next:** T4 — implement `new-notebook`'s opt-in rich mode against the pinned local clone and register the resource in `Wiki/` (`init-wiki` first).

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | Deferred out of `PacletDocumentation` rather than dropped. | The evaluation's recommendation was to depend, and PureMath proves the approach works at 1,480 pages, but the missing licence makes it a bad dependency to take on today. The official MCP tools are good enough for symbol pages. |
| 2026-07-27 (S1) | The licence blocker is cleared; keep a standing, non-blocking ask for an in-tree `LICENSE`. | The user confirmed the licence is fine, which is what Phase 0 needed — vendoring survives as a fallback and adoption is no longer gated on permission. The file itself is still worth having so a vendored copy has something to point at, but waiting on it would block nothing. |
| 2026-07-27 (S1) | "No pinnable release" is dropped as a risk. | The absence of tags was conflated with the absence of a pin. Pinning by SHA works today (`204db7c`, 2026-07-26), and the local clone is already on it. |
| 2026-07-27 (S2) | The 2026-07-27 evaluation is current, not stale; T3 and T4 may rely on it without re-measuring. | Upstream has not moved a byte since the clone (`origin/main` = `204db7c`, 0/0), and every recorded metric reproduces. The commits T1 read as new movement all predate the evaluated tip. |
| 2026-07-27 (S2) | Prefer the pinned local file over the deployed cloud resource, for a second reason. | The cloud resource works today, but is unversioned — no `"Version"`, no `"LatestUpdate"` — so drift is undetectable, on top of the personal-path disappearance risk already recorded. |
| 2026-07-27 (S3) | Adopt per-skill, in `new-notebook` only. Plugin-wide is off the table. | The shim tax is 197/356 lines in PureMath but empirically 0 on the `Default` template — 160 lines repair DocumentationTools slots that `defaultNotebook` never creates, and 37 protect a 1,480-page parallel cloud batch we do not run. There is also no shared conversion layer to swap plugin-wide: `new-notebook` owns the MCP append-cell pipeline and `research-notebook` layers on it. |
| 2026-07-27 (S3) | Drop `research-notebook` as a candidate — both directions, permanently. | Forward: the `Default` template emits no `Author`/`Abstract` cells and none of the MathNotebook environments, and the skill file already says it "does not replace the research generator". Reverse: a measured round-trip at `204db7c` drops the frontmatter entirely and returns an empty table header, which is content loss, not formatting drift. Phase 2 is abandoned rather than deferred. |
| 2026-07-27 (S3) | The residual cost to carry into T4 is `ensureParser[]` and the SHA pin, nothing else. | A warm local conversion is 0.05 s with zero variance; the only first-call cost is the `Wolfram/Parser` install, which degrades silently to `ImportString[…, "TeX"]`. Rich mode must surface that degradation in its response rather than swallow it. |
| 2026-07-27 | The guide-page gap is no longer a reason to adopt. | Guide pages left scope the same day. What remains in favour is `new-notebook`'s rich mode (Phase 1) — the constructs the MCP append-cell transport cannot carry — and nothing else urgent. This item is now genuinely low priority. |
