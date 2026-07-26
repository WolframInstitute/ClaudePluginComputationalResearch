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


### Done

- [x] T1 — Clone and inspect MathNotebook; verify installability; enumerate the real stylesheet and cell-style names; write the correction list against `research-notebook/SKILL.md`. *(Session 1)*
- [x] T2 — Test the `CloudDeploy` styling risk first: deploy a throwaway notebook using the stylesheet and confirm environments render for a reader without the paclet. Decide referenced vs. embedded `StyleDefinitions`. *(Session 2)*
- [x] T3 — Implement marker → environment-cell post-processing; verify rendering and numbering via the MCP. *(Session 3)*
- [x] T4 — Reconcile the displayed-math convention with the stylesheet; verify typeset output. *(Session 4)*
- [x] T5 — Implement the citation → References path, tied to `cite` and `references.bib`. *(Session 5)*
- [x] T6 — End-to-end build of one real research notebook; update `research-notebook/SKILL.md` to verified reality. *(Session 6)*

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

### Session 2 — 2026-07-27 — T2

- **Did:** built one probe notebook body — Title, Section, then a `Definition`, `Theorem`, `Conjecture`, `Remark` and a `DisplayFormula` — and wrapped it three ways to separate the variables cleanly.

  **Established the discriminator first.**
  Measured through a real front end (`UsingFrontEnd` + `NotebookPut`), reading `{Title FontSize, Definition CounterIncrements, Conjecture has a dingbat}`:

  | `StyleDefinitions` | Title `FontSize` | `Definition` `CounterIncrements` |
  |---|---|---|
  | `FrontEnd`FileName[{"MathNotebook"}, "AMSArticle.nb"]` | 26 | `"Theorem"` |
  | `Get[<absolute path to AMSArticle.nb>]` (embedded) | 26 | `"Theorem"` |
  | `"Default.nb"` (the failure case) | 45 | `{}` |

  Note that "has a dingbat" is `True` in all three rows and is therefore **not** a usable discriminator — `Default.nb` resolves a generic `CellDingbat` too.
  `CounterIncrements` is the one to assert on: `"Theorem"` means the sheet loaded, `{}` means it silently did not.
  Both forms resolve correctly *on this machine*, which is exactly why a local check proves nothing about a reader.

  **The cloud test settles it.**
  Deployed both variants public and read each back with `CloudGet`:

  | Deployed variant | `StyleData` cells in the file | `StyleDefinitions` head | Size |
  |---|---|---|---|
  | referenced | **0** | `FrontEnd`FileName` | 2.9 kB |
  | embedded | **57** | `Notebook` | 49.8 kB |

  The referenced notebook travels with **no style definitions at all** — only a file name pointing into a paclet layer on the author's disk.
  A reader without the paclet therefore gets the `Default.nb` row of the first table: no `Theorem` counter, so every environment renders as unnumbered body text, and the labels are gone entirely because the label *is* the `CellDingbat` the sheet supplies.
  The embedded notebook carries all 57 `StyleData` cells (32 style names plus their `"Printout"` variants) inside the file and is self-contained.

  Public probe URLs, left up for the browser confirmation the Requirements ask for — **both are throwaway and should be deleted afterwards**:
  - referenced: `https://www.wolframcloud.com/obj/hajek_pavel/MathNotebookProbe/referenced.nb`
  - embedded: `https://www.wolframcloud.com/obj/hajek_pavel/MathNotebookProbe/embedded.nb`

  **Decision: embed, unconditionally.**
  The cost is about 47 kB per notebook, which is nothing next to a single rasterized plot, and it buys a notebook that renders correctly for a reader with no paclet, no install, and no front-end menu reset.
- **Learned:** the paclet's `CLAUDE.md` was right that embedding is the answer, but its stated reason — silent fallback in headless runs — is the weaker one.
  The stronger reason is measurable and unconditional: a referenced sheet is simply *not in the deployed file*, so its resolution is a property of the reader's machine rather than of the document.
  Also worth carrying to T3: numbering is dynamic, not baked.
  The numbers are `CounterBox`es evaluated by the reader's front end, so they are correct in the deployed notebook *provided* the definitions travel with it — the two findings are the same finding.
- **Next:** T3 — marker → environment-cell post-processing.

### Session 3 — 2026-07-27 — T3

- **Did:** implemented the post-processing as `scripts/mathnotebook_post.wl` — a plain `.wl` file the skill `Get`s through the MCP kernel, matching the plugin's MCP-first pattern (registered in `CLAUDE.md`, script count 26 → 27).

  It exports `$MathNotebookEnvironmentStyles` (all 12), `$MathNotebookStyleSheetName`, `ConvertEnvironmentCells` (the pure core, operating on a cell list or a whole `Notebook`), `MathNotebookStyleSheet[]` (reads the sheet out of the installed paclet layer), and `MathNotebookDocument[cells]` which wraps the converted cells with the **embedded** sheet per T2's decision.

  Both marker spellings are handled, because the new-notebook pipeline can produce either: a parsed bold run `TextData[{StyleBox["Definition.", FontWeight -> Bold], " …"}]`, and an unparsed literal `"**Definition.** …"`.
  The marker is deleted and the leading space trimmed; a marker naming no environment is left alone.

  **Verified through the MCP against a 10-cell probe** spanning two sections, both marker spellings, plain prose and a bogus `**Nonsense.**` marker.
  Styles came out `Title, Section, Definition, Theorem, Conjecture, Remark, Section, Question, Text, Text` — every intended conversion, no false positives, and the bogus marker preserved verbatim as `Text`.

  **Numbering verified by rendering the whole notebook to a raster and reading it.**
  `CurrentValue[cell, {CounterValue, "Theorem"}]` answers `$Failed`, so a counter cannot be read as a value; and per the paclet's `CLAUDE.md` a single-cell `Rasterize` reads every `CounterBox` as 0.
  `Export[png, notebookObject]` inside `UsingFrontEnd` is what works.
  The render shows:
  `Definition 1.1.`, `Theorem 1.2.`, `Conjecture 1.3.`, `Remark 1.4.`, then under section 2, `Question 2.1.` —
  so the shared counter increments across environment kinds and `Section` resets it, both confirmed visually rather than inferred from the style options.

  Two rendering facts worth carrying forward:
  the Plain-class environments (`Theorem`, `Conjecture`, …) set their **body** in italic, amsthm-style, while the Definition- and Remark-class bodies are roman — so prose written for a `Theorem` cell will be italicised whether the author expects it or not;
  and the exported raster came out **dark** even though the sheet declares `LightDark -> Light` and `Background -> GrayLevel[1]` on `Notebook`, meaning a headless raster follows the front end's own appearance rather than the sheet.
  That matters for T6: a light/dark check on the published artifact cannot be done from the raster alone.
- **Learned:** the verification method is the deliverable as much as the code is.
  Numbering in this stylesheet is unreadable by every obvious kernel-side route — it is not a cell option, not a counter value, and invisible to a single-cell rasterize — and the only honest assertion is a whole-notebook render.
  Any future test of numbering has to go through `Export[file, notebookObject]`, and any future *regression* test should assert on the rendered image, not on style names, because correct style names with a missing stylesheet look identical in the cell expression and blank on the page.
- **Next:** T4 — reconcile the displayed-math convention with the stylesheet.

### Session 4 — 2026-07-27 — T4

- **Did:** reconciled the skill's displayed-math convention against the sheet, and verified the typeset output by rendering.

  **The skill's convention is already correct, and MathNotebook defines no separate equation environment.**
  What the sheet declares is three math styles: `DisplayFormula` (centered, `FontSize` 13, left margin 66), `DisplayFormulaNumbered` (the same plus a number), and `DisplayFormulaEquationNumber` (the number's own character style).
  So the Spec's "if MathNotebook defines its own equation environment, prefer it" branch does not fire — `DisplayFormula` *is* the environment, and the existing `FormBox[…]`-fence → `DisplayFormula` rule stands unchanged.

  Rendered a probe with the `FormBox[ ToBoxes[ expr ], TraditionalForm ]` form the skill prescribes: the Basel sum came out fully typeset — `∑` with both limits, a real built-up fraction, centered — and the integral rendered with proper limits and differential. The convention produces genuine typeset math, not a linearised approximation.

  **What was missing is the numbered variant.**
  `DisplayFormulaNumbered` sets `CounterIncrements -> "DisplayFormulaNumbered"` and puts `("(" CounterBox["DisplayFormulaNumbered"] ")")` in the right-hand `CellFrameLabels`, so the number renders flush right as `(1)`, `(2)`, `(3)` — confirmed in the render.

  **A counter asymmetry the skill needs to state.**
  `Section` carries `CounterAssignments -> {{"Subsection", 0}, {"Subsubsection", 0}, {"Theorem", 0}}` — the equation counter is *not* in that list.
  Verified visually in the same render: entering section 3 reset the theorem counter (the next environment numbered `Theorem 3.1.`) while the following equation continued to `(3)`.
  So **theorem numbers are per-section `⟨section⟩.⟨n⟩` and equation numbers are document-global `(n)`.** An author who assumes equations are numbered per-section will write wrong cross-references.

  **Implemented `NumberTaggedFormulas`** in `scripts/mathnotebook_post.wl` and wired it into `MathNotebookDocument`: a `DisplayFormula` cell that carries `CellTags` is promoted to `DisplayFormulaNumbered`.
  The rule is that an equation gets a number exactly when something can cite it, which keeps the decision in one place and needs no new Markdown syntax — the tags come from T5's citation path, and `CellTags` is also what `CounterBox[counter, tag]` resolves against, so a tagged equation is simultaneously numberable and citable.
  Verified: untagged stays `DisplayFormula`, two tagged cells become `DisplayFormulaNumbered`.
- **Learned:** the numbering asymmetry is the kind of thing that only shows up in a render across three sections — the style options alone read as if both counters behaved the same, since both are plain `CounterIncrements`; it is the *absence* of the equation counter from `Section`'s `CounterAssignments` that distinguishes them, and absences are easy to miss when reading a stylesheet.
- **Next:** T5 — the citation → References path.

### Session 5 — 2026-07-27 — T5

- **Did:** implemented the `[tag]` → References path in `scripts/mathnotebook_post.wl`, reusing the paclet's existing rendering contract rather than inventing one.

  **What `Citation` actually does, settled.**
  `Referencing.wl` already defines `referenceLabel[tag] = "[" <> tag <> "]"`, `citationButton[tag] = ButtonBox[label, BaseStyle -> "Citation", ButtonData -> tag]` — a plain jump-to-tag button — and `referenceDingbat[tags]`, which gives a `Reference` cell a `CellDingbat` of that same label so a bibliography entry reads exactly as the citation pointing at it.
  There is still **no bibliography engine**: nothing collects, sorts, or numbers entries.
  So the answer to the Spec's question is "cross-reference machinery, no bibliography", and the References section has to be generated by us.

  **Three functions added.**
  `ConvertCitations[cells, tags]` walks each cell's `TextData` and replaces a literal `[tag]` with `ButtonBox["[tag]", BaseStyle -> "Citation", ButtonData -> tag]`, built inline in the `TextData` list — the form the paclet's `CLAUDE.md` says is the one that round-trips.
  `ReferenceCells[entries]` emits `Cell[TextData[text], "Reference", CellTags -> tag, CellDingbat -> Cell[TextData["[tag]"]]]`, matching `referenceDingbat`'s rendering exactly.
  `BibTeXReferences[file]` parses a `.bib` into `<|tag -> formatted string|>`.

  **The tag list is the guard against false positives**, and it is why `ConvertCitations` takes `tags` rather than pattern-matching any bracketed word: `[tag]` is also ordinary prose and collides with Markdown link syntax.
  Only keys present in the bibliography are converted.
  Verified on a probe containing a real citation, an existing Markdown hyperlink `ButtonBox`, and a bare `[unknown]`: both citations converted, the hyperlink untouched, `[unknown]` left as plain text.

  **`Import[file, "BibTeX"]` does not exist** — `"BibTeX"` is not in `$ImportFormats` — so the parser is hand-written: entries split on `@type{…\n}`, the key taken as the text before the first comma, fields matched as `key = {value}`, `key = "value"`, or a bare numeric `key = 2011`.

  It is tied to the `cite` skill by construction, and this was checked rather than assumed.
  `scripts/cite_from_id.wls` emits arXiv entries with aligned `author        = {…}` padding and a trailing `abstract` field, and passes Crossref DOI BibTeX straight through; both shapes parse, with the abstract correctly ignored (only `author`, `title`, `journal`, `year` are formatted) and links resolved as `https://doi.org/…` when a `doi`/`DOI` field is present, else `https://arxiv.org/abs/…` from `eprint`.
  The bare-numeric rule exists because the first version silently dropped the year of a Crossref entry written `year = 2011,` with no braces — found by testing against the real `cite` output shape, not the idealised one.

  **Rendered and confirmed:** citations appear in the `Citation` style's dark red as `[ollivier2009]`, the Markdown hyperlink stays blue, `[unknown]` stays plain, and the References section shows each entry with its `[tag]` label hanging in the left margin.
- **Learned:** two things worth carrying to T6.
  The alternation `("{" ~~ value : Shortest[___] ~~ "}" | "\"" ~~ value : Shortest[___] ~~ "\"")` **silently fails** — WL warns that restrictions on a pattern variable are ignored when it is not the first occurrence, and every field parsed as empty while the keys parsed fine, so the association looked structurally correct and was blank.
  This is the same trap the paclet's own `CLAUDE.md` records for `Document.wl`; one rule per delimiter form is the fix.
  Separately, a long citation key overflows the `Reference` style's left margin — `[ollivier2009]` ran to the very edge of the page while `[lin2011]` sat comfortably — so bib keys should be kept short, or the References section needs its own margin override.
- **Next:** T6 — end-to-end build and the skill rewrite.

### Session 6 — 2026-07-27 — T6

- **Did:** built one real research notebook end to end, then rewrote the skill.

  **The notebook.** *Algebraic connectivity of trees* — a topic chosen so that every claim in it is exactly computable and independently checkable, since the point was to exercise the pipeline, not to advance mathematics.
  All trees on 4–8 vertices are generated from Prüfer sequences and reduced up to isomorphism by `CanonicalGraph`; the counts come out 2, 3, 6, 11, 23, which is OEIS A000055 restricted to that range, so the enumeration is self-validating.
  For each of the 45 trees the second-smallest Laplacian eigenvalue is computed, and in every case the minimiser is isomorphic to the path and the maximiser to the star.
  Both extreme values are then stated in closed form and checked against the census: `a(Pₙ) = 2(1 − cos(π/n))` gives 0.152241 at n = 8, matching the computed minimum, and `a(K₁,ₙ₋₁) = 1` is attained exactly.
  The statement is Fiedler's theorem, and the notebook says so rather than presenting it as new.

  It exercises every piece built in T2–T5: Title/Author/Date/Abstract, two `Definition` cells, a `Conjecture` with a status marker, a folded `Example` subsection with evaluated code and an embedded plot, an unnumbered `DisplayFormula` and two tagged numbered ones, three `ItemNumbered` research questions, and a Literature section generated from a `.bib`.
  Style tally of the built notebook: `Title` 1, `Author` 1, `Date` 1, `Abstract` 1, `Section` 5, `Subsection` 1, `Definition` 2, `Conjecture` 1, `Text` 5, `Input` 3, `Output` 3, `DisplayFormula` 1, `DisplayFormulaNumbered` 2, `ItemNumbered` 3, `Reference` 2.

  The two documented failure modes were checked rather than assumed: `ExportString` returned a real string and not the 7-character `"$Failed"`, and the 46 kB file re-imports with head `Notebook`.
  Deployed public, and the deployed file carries all 57 `StyleData` cells:
  `https://www.wolframcloud.com/obj/hajek_pavel/ResearchNotebooks/AlgebraicConnectivityOfTrees.nb`
  The **browser confirmation the Requirements ask for is the one step left to a human** — everything above is a headless render plus a `CloudGet` of the deployed object.

  **The end-to-end test caught a real gap in T5, which is what it was for.**
  The first build rendered `[eq:path]` and `[eq:star]` as literal text, because `ConvertCitations` was given only the bibliography keys — equation tags are a different namespace, and a citation to a numbered equation should read as its *number*, not as its tag.
  Fixed by reproducing the paclet's own `$referenceLabelSpec` and making citations style-aware: `CitationTargets` derives tag → style from the cells themselves, and a target listed in the spec renders as `CounterBox`es — `(1)` for an equation, `Definition 2.3` for an environment, `Section 4` for a section — while a `Reference` target keeps the bare `[tag]`.
  Confirmed in the re-render: the sentence now reads "Equation (1) gives 0.152241 …, and (2) is attained exactly", with both numbers resolved by the front end.
  `MathNotebookDocument` now runs the full pipeline itself in the only correct order — environments, equation numbering, citations — since citations must see an equation cell after it has become `DisplayFormulaNumbered`.

  **Skill rewritten** (`skills/research-notebook/SKILL.md`, 333 → 407 lines):
  the broken `PacletInstall` snippet replaced with the cloud `.paclet` URL plus the `UpdateMathNotebook[]` path;
  a new *embed, never reference* section explaining the zero-`StyleData` measurement;
  the marker list expanded from 5 to all 12 environments in a table by class, flagging that the Plain class italicises the body;
  the two counter facts stated explicitly, with "the number is never yours to write";
  the `CellTags` → `DisplayFormulaNumbered` rule;
  a new *Citations and References* section documenting `BibTeXReferences` / `ReferenceCells` / `ConvertCitations`, the absence of any bibliography engine, the absence of `Import[…, "BibTeX"]`, and the short-keys warning;
  the `Subtitle` correction in two places, since AMSArticle declares no such style;
  and the line-320 checklist item ticked, now that it is true.
- **Learned:** the ordering constraint is the subtlest thing in this item and it only surfaces end to end — each of T3, T4 and T5 passed its own test in isolation while the composition was wrong, because the citation pass silently found no target for a tag whose cell had not yet been promoted.
  Nothing warned; the citation just stayed literal text, which reads as an authoring mistake rather than a pipeline one.
  That is the argument for `MathNotebookDocument` owning the order rather than documenting it.
- **Next:** none — item complete.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | `MathNotebookDocument` owns the pass order (environments → equation numbering → citations) rather than the skill documenting it. | Each pass passed its own test while the composition was wrong: the citation pass found no target for an equation tag whose cell had not yet become `DisplayFormulaNumbered`, and failed silently by leaving the citation as literal text. An order that fails silently should not be the caller's responsibility. |
| 2026-07-27 | Built the end-to-end notebook on a known theorem (Fiedler) rather than a new claim. | The task verifies the pipeline, so every statement in the artifact had to be independently checkable. The tree census self-validates against OEIS A000055 and both closed forms were checked against the computed extremes, which would not be possible with an open question. |
| 2026-07-27 | Embed the stylesheet in every generated notebook (`StyleDefinitions -> Get[<absolute path>]`), never reference it by name. | A deployed notebook using the `FrontEnd`FileName` form carries 0 `StyleData` cells, measured by reading it back with `CloudGet`; its styling is a property of the reader's machine, not of the document. Embedding costs ~47 kB and makes the notebook self-contained. |
| 2026-07-27 | Proceed despite the repo being private, rather than stopping as the Spec's edge case directs. | That edge case exists to prevent inferring an API from a name. Access is real here — an SSH clone succeeds with the authenticated account — so nothing is being guessed; every claim above is read off the source or measured in the kernel. |
