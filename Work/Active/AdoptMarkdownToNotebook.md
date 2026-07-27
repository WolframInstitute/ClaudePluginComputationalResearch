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
  Plugin-wide was never coherent, since there is no shared conversion layer to swap — that part stands.
  The "exactly one skill" part is **superseded as of 2026-07-27 (after T4)**: the user reopened `research-notebook` as a generation surface, so the adopted set is `new-notebook` (done, T4) plus `research-notebook` pending T5.
  See *Design / risks → `research-notebook`, reopened*.
- ~~If anything is adopted, register the repo in `Wiki/` via `add-resource` with recovery info — noting that this project has no `Wiki/` yet, so `init-wiki` comes first.~~ **Done 2026-07-27 (T4).**
  `Wiki/` initialized at minimal scope — `Index.md`, `Status.md`, `Concepts/`, `Resources/` — and the repo registered at `Wiki/Resources/MarkdownToNotebook.md` with a `Clone:` / `Target:` / `Commit:` Recover section.
  The clone stays at the project root rather than under `Resources/`, matching the gitignored siblings `MathNotebook/` and `PureMath/`.

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

### `research-notebook`, reopened (user direction, 2026-07-27, after T4)

S3 dropped `research-notebook` permanently; the user reversed that: *"If MarkdownToNotebook is so good then use this preferably… Perhaps research-notebook is a good candidate to generate using that. It has to be nice. Research notebook does not have to be MathNotebook. But I like the Definition, Proposition, … and the referencing. But it could have the default style."*

So MathNotebook is **not** a requirement — the requirements are the theorem-like environments, the referencing, and that it look good.
Probed at `204db7c` during T4, three facts constrain the options:

- The converter **does** have theorem environments, via Pandoc-style fenced divs — `::: theorem` / `::: proof`, with `numbered: true`.
  Cell styles produced: `Theorem`, `TheoremStatement`, `Proof`, `ProofContent`, `ProofTheoremEndCap`.
- **The label is free text, the style is not.** `theoremCells` takes the head cell's text from the div's first prose block, defaulting to `"Theorem"`.
  So `Definition`, `Proposition`, `Lemma`, `Corollary` are all expressible as labels — but every one carries cell style `"Theorem"`.
  There are no `Proposition` / `Lemma` / `Corollary` styles in the converter at all.
  Authoring detail: the title and the statement must be separated by a **blank line**, or the whole thing collapses into the head cell and no `TheoremStatement` is emitted.
  Numbering is `CounterBox["Section"].CounterBox["Subsection"]` — section-derived, not a per-environment counter.
- **The environments and the default style are mutually exclusive off the shelf.**
  Under `Template: Default` the divs are **silently dropped entirely** — a probe with two `::: theorem` divs and one `::: proof` returned only the `Title` cell, 3 divs → 0 cells, no message.
  That is silent content loss, the worst failure mode, and it must be guarded against however T5 goes.
  `Default.nb` defines none of `Theorem` / `TheoremStatement` / `Proof` anyway.
  Under `Template: Chapter` all six cells appear correctly, but `StyleDefinitions` becomes `FrontEnd`FileName[{"Wolfram"}, "BookToolsStyles.nb"]` — the WolframBookTools stylesheet, not Default.

The four routes, for T5 to choose between:

1. **`Template: Chapter`, accept BookTools styling.** Environments and numbering work as shipped, nothing to maintain. Not the Default look the user floated, and it adds a WolframBookTools dependency for the stylesheet to resolve.
2. **Chapter cells, `StyleDefinitions -> "Default.nb"`.** Gets the requested combination on paper, but the styles are undefined in `Default.nb`, so the cells render unstyled. Cheap to test, likely ugly — test before arguing about it.
3. **`Default` plus a small local stylesheet** defining `Definition` / `Proposition` / `Lemma` / `Corollary` / `Proof`. The only route that gives genuinely distinct environments and per-environment counters, and the only one that satisfies the request literally. Costs a stylesheet to own.
4. **Keep MathNotebook for this skill.** The status quo; already satisfies environments and referencing.

Open, unmeasured: **referencing.** The user named it as a requirement and T4 did not probe it. Establish what the converter supports (cross-references to numbered environments, a bibliography) before choosing a route — route 3 in particular would have to reimplement whatever is missing.

Also unresolved and independent of the route: `research-notebook` is specced for **two-way md↔nb sync**, and its sync uses `ExportString[Import[path], "Markdown"]`, not `NotebookToMarkdown`. Whether that still round-trips once the notebook carries `Theorem` / `2ColumnTableMod` / boxed-math cells is unmeasured, and S3's finding that the reverse direction loses frontmatter and table headers is a warning, not an answer. Measure the sync before committing.

### Edge cases & out of scope

- Do **not** run `install-skills.sh`. Symlinked personal skills track the repo's `main` — a live feed — and their trigger descriptions compete with `build-paclet` / `publish-paclet` with nothing to arbitrate. If those genres are wanted, reimplement them as `computational-research:` skills.
- Do not revisit the `demo-notebook` retirement; that is settled and executed.
- **Abandon condition (revised 2026-07-27, T1):** the licence leg is spent — it cannot fire.
  What is left to abandon on is value, not permission: if T2's re-measurement and T3's shim-tax costing show the remaining candidate surfaces (`new-notebook` rich mode, `research-notebook` md↔nb sync) do not clear their cost, cap the relationship at reading `docs/` for design ideas and keep the official tools.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T5 — Reopen `research-notebook` as a generation surface (user direction, 2026-07-27). Decide the stylesheet/environment route from the four options in *Design / risks → research-notebook, reopened*, then implement it. Measure the md↔nb sync direction before committing to anything.

### Done

- [x] T4 — Implement `new-notebook`'s rich mode against the pinned local clone (`Default` template, `"Evaluate" -> False`, built-in fallback) and register the resource in `Wiki/`. *(Session 4)*

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

### Session 4 — 2026-07-27 — T4

- **Prompt:** `/next-session`, then "research notebook skill we need, do not delete" and "explain the rich mode what is the difference".
- **Did:** implemented `new-notebook`'s rich mode, initialized `Wiki/`, and registered the resource.

  **Measured the engine difference at `204db7c` before writing anything.**
  Converted a representative source — frontmatter, `**[LLM Generated]**`, inline and display math, a `## Setup` fence, a `GraphPlot` fence, a pipe table — and read the cell expressions rather than trusting the evaluation's summary.
  Six differences from the built-in importer turned out to be load-bearing, and two of them are traps: `##` is already `"Section"` so the existing heading down-shift must **not** run, and `ExportString[Notebook[cells], "NB"]` silently drops the converter's `CreateCellID` / `StyleDefinitions` options, so the pipeline has to rebuild via `ReplacePart[nb, 1 -> cells]`.
  Also found an unrecorded wart: the converter stamps `CellLabel -> "In[n]:= "` on cells even under `"Evaluate" -> False`, so rich mode strips it.

  **Wrote two sections into `skills/new-notebook/SKILL.md`.**
  *Conversion engine — built-in vs rich* gives the three-step selection rule, the difference table, the fixed settings, and the `PacletFind["Wolfram/Parser"]` probe that surfaces the silent `ImportString[…, "TeX"]` degradation.
  *The rich-mode Wolfram MCP call* gives the full pipeline, annotated with the five deltas from the built-in call.

  **Smoke-tested the documented block verbatim.**
  9 cells, `Title / Subtitle / Text / Section / Input / Section / DisplayFormula / Input / 2ColumnTableMod`; frontmatter not leaked, 0 `CellLabel`, `InitializationCell` on the `## Setup` input only, notebook options kept, `FractionBox` in the `DisplayFormula`, no `Defer` anywhere.

  **`Wiki/` initialized at minimal scope** and `Wiki/Resources/MarkdownToNotebook.md` written with the pin, the recovery command, and the reasons the reverse direction and `install-skills.sh` are out.
  Added a *Knowledge Base (Wiki)* section to `CLAUDE.md` recording the two-engine design and the wiki's narrow scope.
- **Learned:** four things.

  **Rich mode removes a workaround rather than adding a feature.**
  The built-in pipeline's `boxifyInputCells` exists only because the importer returns `BoxData["raw string"]`, and its `vizCellQ` blocklist exists only because the `ToBoxes[ToExpression[…, Defer]]` fix strands graphics cells.
  The rich parser emits the structural tree directly, so **both** the workaround and its exception disappear — and the cells the blocklist used to give up on are the ones that improve most.
  Verified on `GraphPlot[ CycleGraph[ 6 ] ]`: fully structural `RowBox`, with the house style's spaces-inside-brackets preserved as `" "` leaves.

  **The user changed the opt-in mechanism, and it is a real narrowing.**
  The Spec said "opt-in rich mode"; the chosen design is auto-detection from the source (frontmatter or LaTeX math) with no toggle.
  That means a plain prose-plus-code source keeps the built-in engine and therefore keeps needing the boxify workaround — the code-fidelity gain above does **not** reach sources without math.
  If that turns out to matter, the fix is to widen the predicate to "has a `wolfram` fence", not to add a toggle.

  **`research-notebook` stays — the user said so explicitly, and T3's wording invited the misreading.**
  T3 "dropped `research-notebook` as a candidate", which means dropped as an *adoption surface*, not deleted as a skill.
  Nothing in T4 touches it; the wiki article and `CLAUDE.md` both now say in prose why it does not use this engine, so the distinction survives the next fresh session.

  **A nested `.gitignore` cost a wrong read.** `cd`-ing into `MarkdownToNotebook/` persists across Bash calls, so a later bare `cat .gitignore` read the *clone's* ignore file, not the project's.
  The project root already gitignores `MarkdownToNotebook/`, so no ignore change was needed at all.
- **Next:** T5 — the user reopened `research-notebook` mid-session, so the item stays Active rather than moving to `Work/Done/`.

  **The reversal, and what it costs.** After T4's implementation was written, the user directed: use MarkdownToNotebook preferentially, and generate `research-notebook` with it — MathNotebook is not required, but the Definition/Proposition environments and the referencing are, and the Default style would be acceptable.
  That reverses S3's "drop `research-notebook` — both directions, permanently".
  S3's *forward* argument was that `Default` emits no `Author`/`Abstract` cells and none of the theorem environments; the first half stands but the second half was **incomplete** — I had only measured the `Default` template, and the converter does have theorem environments on the `Chapter` path.
  S3's *reverse* argument (round-trip content loss) is untouched and still applies to the sync direction.
  So the reopening is legitimate on the forward direction and not on the reverse.

  **Probed far enough to make T5 sound, no further.** Recorded in *Design / risks → `research-notebook`, reopened*: the `::: theorem` / `::: proof` div syntax, that the environment label is free text over a single `Theorem` style, and the blocking constraint — the environments exist only under `Chapter`, which forces the BookTools stylesheet, while under `Default` the divs are **silently dropped**, 3 divs → 0 cells with no message.
  "Definition/Proposition with the Default style" is therefore the one combination that does not exist off the shelf, which is a decision for the user rather than something to pick unilaterally.
  Referencing — explicitly named as a requirement — is **not** probed; T5 does that first.

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
| 2026-07-27 (S4) | Engine choice in `new-notebook` is auto-detected from the source, not toggled. | User decision, overriding the Spec's "opt-in" wording. Rich mode fires when the source has YAML frontmatter or LaTeX math — the constructs the built-in importer demonstrably gets wrong — and only when the clone is present. Accepted cost: a plain prose-plus-code source keeps the built-in engine and so keeps needing the `boxifyInputCells` workaround, even though the code-fidelity gain would apply to it. If that bites, widen the predicate to "has a `wolfram` fence"; do not add a toggle. |
| 2026-07-27 (S4) | Never clone MarkdownToNotebook silently; fall back to the built-in engine and say so. | Cloning is unrequested network I/O. The fallback keeps `new-notebook` working on a machine that has never seen the dependency, which is the normal case for a plugin user. |
| 2026-07-27 (S4) | S3's "drop `research-notebook` permanently" is **reversed** for the forward direction; the reverse direction stays dropped. | User direction. S3's forward argument was incomplete — it measured only the `Default` template and concluded the converter has no theorem environments, but they exist on the `Chapter` path (`::: theorem` / `::: proof`). The reverse-direction argument (round-trip drops frontmatter and empties table headers) is unaffected and still disqualifies the sync direction. |
| 2026-07-27 (S4) | The environment/stylesheet route for `research-notebook` is the user's call, deferred to T5, not picked in S4. | The request — theorem environments *and* the Default style — is not satisfiable off the shelf: environments exist only under `Chapter`, which forces `BookToolsStyles.nb`, and under `Default` the divs are silently dropped (3 → 0 cells, no message). The four routes and their costs are recorded in the Spec; referencing is still unmeasured and gates the choice. |
| 2026-07-27 | The guide-page gap is no longer a reason to adopt. | Guide pages left scope the same day. What remains in favour is `new-notebook`'s rich mode (Phase 1) — the constructs the MCP append-cell transport cannot carry — and nothing else urgent. This item is now genuinely low priority. |
