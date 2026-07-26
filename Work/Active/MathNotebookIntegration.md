# MathNotebookIntegration

*[ LLM Generated ]*

> Type: investigation

## Spec

Origin: "we need another work item to incorporate https://github.com/WolframInstitute/MathNotebook to create research notebooks with proper references, math, and theorem etc. environments" / "I think that research notebooks could use MathNotebook."

Make `research-notebook` actually produce a typeset mathematical document: numbered theorem-family environments, properly typeset displayed math, and real citations resolving to a References section.

The starting point is not greenfield — it is a **reconciliation**.
`skills/research-notebook/SKILL.md` already instructs the LLM to use MathNotebook (lines 88–113, 144) and asserts specifics that have never been checked against the repo:

- `Needs[ "WolframInstitute`MathNotebook`" ]`, installed via `PacletInstall[ "WolframInstitute/MathNotebook" ]`
- stylesheet at `FrontEnd`FileName[ { "MathNotebook" }, "AMSArticle.nb" ]`
- cell styles `Definition`, `Conjecture`, `Question`, `Observation`, `Remark`, `Citation`
- the stylesheet supplying automatic numbering

Every one of those is an assumption.
This item verifies them, corrects the skill where they are wrong, and implements the parts that are merely described — above all the Markdown-marker → environment-cell post-processing and the citation → References path, neither of which exists as code today.

### Requirements

- Clone the repo to a gitignored path; record license, recency, and whether it is a paclet, a stylesheet-only repo, or something else.
- Establish the **real** install path. Confirm whether `PacletInstall["WolframInstitute/MathNotebook"]` resolves at all, or whether it needs a GitHub URL / local build / submodule. If it does not resolve, the skill's install snippet is broken and must be replaced.
- Enumerate the **actual** stylesheet file name and cell-style names. Produce a correction list against the six styles the skill currently names, plus whatever theorem-family styles exist that it doesn't use (`Theorem`, `Lemma`, `Proposition`, `Corollary`, `Proof`, …).
- **Theorem environments:** implement the post-processing that converts a `**Definition.**`-style opening marker in a Text cell into the matching environment cell with the marker stripped. Verify through the Wolfram MCP that numbering is produced by the stylesheet and increments correctly.
- **Math:** reconcile the skill's current displayed-equation convention (a `wolfram` fence starting with `FormBox[…]` → `DisplayFormula` cell) with whatever the stylesheet expects. If MathNotebook defines its own equation environment, prefer it and update the skill.
- **References:** determine what `Citation` actually does — whether there is a bibliography mechanism or only a text style. Implement the `[tag]` → References-section path and tie it to the `cite` skill and `Paper/references.bib` when the project has one.
- End-to-end: build one real research notebook using the environments, cloud-deploy it, and **confirm in a browser that the styles survive deployment**.
- Rewrite the affected parts of `research-notebook/SKILL.md` to match verified reality, and tick its line-320 checklist item only once it is true.

### Design / risks

- **Custom stylesheet vs. `CloudDeploy` is the main technical risk.** Cloud-published notebooks routinely lose private/paclet stylesheets, which would leave every environment cell unstyled and unnumbered in the one place readers actually look. Test this early — it may force embedding the style definitions in the notebook rather than referencing the paclet.
- If the paclet must be installed for the notebook to render, a cloud reader has no paclet. Embedded `StyleDefinitions` is then the only correct answer, not the fallback.
- Numbering that depends on front-end evaluation may not survive headless build; check whether numbers are static or dynamic.

### Kernel execution (license-aware)

All evaluation goes through the official Wolfram MCP's persistent kernel.
Check `$MaxLicenseProcesses - $LicenseProcesses > 0` before any `wolframscript`.

### Edge cases & out of scope

- `demo-notebook` is **out of scope** — it moves to documentation pages instead (see `PacletDocumentation`).
- Lean export of the resulting statements stays with the `lean` skill.
- If the repo is private or empty, stop and report rather than inferring an API from the name — and note that the skill is currently shipping instructions for a paclet that may not be installable.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T2 — Test the `CloudDeploy` styling risk first: deploy a throwaway notebook using the stylesheet and confirm environments render for a reader without the paclet. Decide referenced vs. embedded `StyleDefinitions`.
- [ ] T3 — Implement marker → environment-cell post-processing; verify rendering and numbering via the MCP.
- [ ] T4 — Reconcile the displayed-math convention with the stylesheet; verify typeset output.
- [ ] T5 — Implement the citation → References path, tied to `cite` and `references.bib`.
- [ ] T6 — End-to-end build of one real research notebook; update `research-notebook/SKILL.md` to verified reality.

### Done

- [x] T1 — Clone and inspect MathNotebook; verify installability; enumerate the real stylesheet and cell-style names; write the correction list against `research-notebook/SKILL.md`. *(Session 1)*

## Progress

### Session 1 — 2026-07-27 — T1

- **Prompt:** "Continue working on research items until done. Commit and push after each. I am going to bed."
- **Did:** cloned and verified everything the Spec listed as an assumption.

  **The repo is private, and it is the user's own.**
  An https clone fails for credentials; the GitHub API reports `private: true`, created 2026-07-26, last push 2026-07-26, and the last commit is authored by Pavel Hajek.
  It clones over SSH (`gh auth` here has `repo` scope, git protocol `ssh`), so the Spec's "if private, stop and report" branch does not apply — access exists.
  Cloned to the gitignored `MathNotebook/`.
  It is a serious paclet, not a stylesheet drop: `PacletInfo.wl`, `Kernel/` in `Package[]` format (10 files), `FrontEnd/Palettes/`, `FrontEnd/StyleSheets/MathNotebook/` (5 sheets), `Assets/`, 9 `.wlt` test files, `Scripts/Build*.wls` generators, its own `Work/` tree using this plugin's own convention, and a `CLAUDE.md` of unusually dense hard-won front-end knowledge.
  **License MIT** (`PacletInfo.wl`), version **0.1.11** in the repo, `WolframVersion` **14.3+** — the MCP kernel is 15.0.0, so that is satisfied.

  **Correction list against `skills/research-notebook/SKILL.md`.**

  | # | Skill asserts (line) | Reality | Verdict |
  |---|---|---|---|
  | 1 | `PacletInstall["WolframInstitute/MathNotebook"]` (94) | `PacletFindRemote["WolframInstitute/MathNotebook"]` returns `{}` — it is **not on the Paclet Repository**, and cannot be, since the source repo is private | **Broken.** Replace with `PacletInstall["https://www.wolframcloud.com/obj/hajek_pavel/MathNotebook.paclet", ForceVersionInstall -> True]`, or `UpdateMathNotebook[]` once a copy is installed |
  | 2 | `Needs["WolframInstitute`MathNotebook`"]` (93) | matches `PrimaryContext` in `PacletInfo.wl` | **Correct** |
  | 3 | stylesheet is `FrontEnd`FileName[{"MathNotebook"}, "AMSArticle.nb"]` (98) | the file exists at exactly that path in the installed paclet layer | **Correct as a file name, unsafe as a strategy** — see below |
  | 4 | styles `Definition`, `Conjecture`, `Question`, `Observation`, `Remark`, `Citation` (18) | all six exist | **Correct but badly incomplete** — the sheet declares 32 styles, 12 of them numbered environments |
  | 5 | "the stylesheet supplying automatic numbering" (20) | true, and the mechanism is now known | **Correct** |

  **The 12 numbered environments**, all carrying `CounterIncrements -> "Theorem"`, in declaration order:
  `Theorem`, `Lemma`, `Proposition`, `Corollary`, `Conjecture`, `Claim` (Plain class — bold label, roman body);
  `Definition`, `Example`, `Construction` (Definition class);
  `Remark`, `Question`, `Observation` (Remark class — plain-weight italic label).
  The skill uses five of these and does not mention the other seven.

  The remaining 20 styles: `Notebook`, `Title`, `Author`, `Date`, `Abstract`, `Section`, `Subsection`, `Subsubsection`, `Text`, `Item`, `ItemNumbered`, `ItemParagraph`, `DisplayFormula`, `DisplayFormulaNumbered`, `DisplayFormulaEquationNumber`, `Proof`, `Hyperlink`, `Citation`, `URL`, `Reference`.

  **How numbering actually works** — worth recording, because it decides T3.
  Each environment style sets
  `CellDingbat -> Cell[TextData[{env <> " ", CounterBox["Section"], ".", CounterBox["Theorem"], "."}]]`
  with `CounterIncrements -> "Theorem"`, and `Section` carries `CounterAssignments -> {…, {"Theorem", 0}}`.
  So the visible label *is* the dingbat, rendered as `Definition 2.3.`, produced entirely by front-end `CounterBox`es with no kernel involvement, and it renumbers itself when cells move.
  All twelve environments share **one** counter, amsthm-style: a Definition followed by a Theorem in section 1 numbers 1.1 then 1.2, not 1.1 and 1.1.
  The consequence for post-processing is that the marker must be *stripped*, never rewritten as text — the number is not ours to write.

  **There is no bibliography engine.**
  `Citation` is a character style inheriting from `Hyperlink`, and `Reference` is a `Text`-derived paragraph style; neither generates anything.
  What `Referencing.wl` exports is cross-referencing: `InsertCitation`, `CopyCellReference`, `TagSelectedCell`, `LabelReferences`, `InsertEnvironment`, `GoBack`.
  Per the paclet's `CLAUDE.md`, a citation to a numbered environment is a `CounterBox[counter, tag]` resolved at the cell tagged `tag`, with the target's style looked up at insert time and an unknown tag falling back to `[tag]`.
  That is a cross-reference mechanism, not a bibliography — so T5's References section has to be authored and kept in sync by us, and the `[tag]` → References path is genuinely new code, as the Spec suspected.

  **The `CloudDeploy` risk in the Spec's Design section is already answered by the paclet's own `CLAUDE.md`, and more sharply than the Spec guessed.**
  Referencing a paclet stylesheet by name has been observed to fall back to `Default.nb` *silently* in headless runs; the sheet reliably applies only as a document-level `StyleDefinitions -> Get[<absolute path>]`; and there is an explicit, expensive warning never to stage a sheet into `$UserBaseDirectory/SystemFiles/FrontEnd/StyleSheets/` to make name resolution work, because it wedges every subsequent front-end launch on the machine.
  Under `Default.nb` a reference renders as `2.0`, which looks like a broken cross-reference and is not one.
  So embedding is not the fallback for cloud readers — it is the only correct answer, exactly as the Spec's second Design bullet suspected, and T2 should confirm rather than discover it.

  **Version drift:** the installed paclet is **0.1.10** while the repo is at **0.1.11**, so any measurement taken through `PacletObject[…]` is one version behind the source being read.
- **Learned:** the paclet's `CLAUDE.md` is the single most valuable artifact in the repo for this work — it already documents the stylesheet-resolution traps, the `Rasterize`-strips-counters problem (a single-cell rasterize reads every `CounterBox` as 0 and every tagged one as `XXX`, so numbering can only be asserted by rendering the whole notebook), the `CellDingbat`-cannot-read-its-own-cell limitation, and the publishing path.
  Read it before each remaining task rather than rediscovering any of it.
  Its warning that `Scripts/PublishPaclet.wls` must be used instead of this plugin's generic `publish-paclet` — because the generic recipe copies only `Kernel/` and `Tests/` and would ship a paclet with no palette and no stylesheets — is a defect report against *our* skill, and is worth its own work item.
- **Next:** T2 — confirm the embedded-vs-referenced `StyleDefinitions` decision for cloud readers.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | Proceed despite the repo being private, rather than stopping as the Spec's edge case directs. | That edge case exists to prevent inferring an API from a name. Access is real here — an SSH clone succeeds with the authenticated account — so nothing is being guessed; every claim above is read off the source or measured in the kernel. |
