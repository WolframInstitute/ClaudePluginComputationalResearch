# ExercisePaperStyle

*[ LLM Generated ]*

> Type: investigation
<!-- Status is the folder: Active/ Backlog/ Done/ Dropped/. Move the file to change it. -->

## Spec

Origin: "The goal of all this is to make the MathNotebooks and the skaffolded papers much more readabale. They are now overflooded with some information, all messed up, long texts, nothing done properly." (2026-08-18, and the four corrections that followed).

The writing rules shipped in 4.13.0 have **never been run against a real document**.
`skills/research-notebook/style.md` was written from a diagnosis of why past output flooded, and the four generator passes behind it are kernel-tested, but no paper or notebook has been produced under the tiers, the budgets, the Ruliology split or the freedom footnote.
This item builds one of each, reads the result as a reader would, and corrects `style.md` in place where a rule fought the mathematics instead of helping it.

The point is not to validate the guide.
It is to find where it is wrong while it is still cheap to change.

### Requirements

- One research notebook built end to end from real project material, not a toy — the pipeline, the tiers, the footnote, the whole path through to a deployed `.nb`.
- One scaffolded LaTeX paper written under the same guide and compiled.
- Both read start to finish by a human, against the question the guide claims to serve: can a reader check this, and would they want to.
- Every rule that got in the way recorded with the passage that exposed it, then corrected in `style.md`.

### Design / API

Nothing to build. The artefacts under test are:

- `skills/research-notebook/style.md` — the guide, shared by both paths
- `skills/research-notebook/{SKILL.md, build.md}` — the notebook path
- `skills/scaffold-paper/SKILL.md` + `skills/new-project/assets/main_template.{tex,typ}` — the paper path
- `scripts/mathnotebook_post.wl` — `ReadCellTags` / `FoldExampleGroups` / `AssignCellIDs` / `ResearchHeadCells`

Three numbers were left deliberately hard and are the most likely to be wrong, since they were set to counter flooding rather than measured:

| Rule | Current | Suspicion |
|---|---|---|
| examples | one per result | may still be too many for a definition-dense section |
| example length | 3–10 lines | fine for graphs, untested for anything needing setup |
| sentences | ≤ 25 words | may fight ordinary mathematical phrasing |

### Edge cases & out of scope

- Not a rewrite of the guide's structure — the tiers and the certainty split are the design, and only their *thresholds* are under test here.
- The freedom-label vocabulary (Directed / Guided / Open exploration) is the operator's call, not this item's to change unasked.
- Formalisation stays out: Lean runs only on explicit request.

## Tasks

- [ ] T4 (human) — the operator reads both documents end to end and rules on what remains: the three numbers, and whether the tier boundaries sit in the right place.

### Done

- [x] T3 (S3) — reconcile: correct `style.md` in place for what T1 and T2 exposed, and re-check the three suspect numbers above against real passages rather than against the flooding they were written to stop.
- [x] T1 (S1) — build one real research notebook end to end under the new rules; keep a note of every passage where a rule and the mathematics disagreed.
- [x] T2 (S2) — write and compile one scaffolded LaTeX paper under the same guide, exercising the `\thanks` footnote, `macros.sty` and the Ruliology split.

## Hand-off

T4 is the operator's `(human)` task: read both documents end to end and rule on the three numbers and the tier boundaries.
The documents are where T1 and T2 left them — the notebook at `NotebooksLLM/EquidistanceOddGirth.{md,nb}` and the paper at `ResearchNotebooks/EquidistanceOddGirth/Paper/` in the SyntheticInfrageometry dev repo — **neither deployed and neither committed**, per the operator's ruling that nothing leaves the machine unasked.

T3 answered every finding in the shipped files; [what it corrected](../../Wiki/Concepts/PaperStyleExercise.md#what-t3-corrected) is a table of finding → fix.

**The read has started and is not finished.**
It produced two build-path defects, [both now fixed](../../Wiki/Concepts/PaperStyleExercise.md#what-the-t4-read-found): the QED square was centred vertically against the whole proof cell in all seven MathNotebook stylesheets, and three of the notebook's fingerprint entries were stale in a way that would have made the drift gate refuse to regenerate any notebook carrying a picture.
The notebook was rebuilt and carries the square inline at the end of each proof's last paragraph, 74 cells, zero drift.
The stylesheets turned out to be **generated** by the paclet's `Scripts/BuildStyleSheets.wls`, so the fix sits there and all seven were regenerated from it.
One half is deliberately unfinished: the palette's *Proof* button and the LaTeX importer still read the square as cell furniture, so an interactively inserted proof now carries none — front-end behaviour, untestable headlessly, and left for the paclet's own session.
What T4 still owes is the ruling it exists for — **the three numbers and the tier boundaries** — on which nothing has been decided.

Three things T4 should know before reading on.

**Nothing that failed was a threshold.**
On both paths it was a rule's *scope*, so the three numbers stand unchanged for the ruling, with the example budget corrected in meaning only: it counts rendered lines, not source lines.

**One known defect is still in the notebook T4 reads.**
`NotebooksLLM/EquidistanceOddGirth.md:37` cites `[Lem:Subpath]` six lines before the lemma is stated — the forward reference T2 found and dropped from the paper.
It was left in place deliberately: the rule was already in the checklist and went unchecked, so T3's fix is the checklist line, and editing the `.md` would leave the generated `.nb` stale until a full regeneration.
Fixing the document is the operator's call at T4.

**The plugin is not bumped and the marketplace is not synced.**
The guide is still under test until T4 rules, so shipping it as a release would ship rules nobody has signed off.
A `chore(release)` commit after T4 is the right place.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-18 | The paper carries only settled statements; experiments go to a Ruliology section and everything below that tier to the journal | Hedged `Claim`s at body weight were the main source of unreadability, and the fix is structural rather than stylistic |
| 2026-08-18 | Results are stated at the generality the proof reaches, never smaller | A first draft preferred "the smallest statement you can prove", which reads as a preference for triviality — corrected by the operator |
| 2026-08-18 | No proof-length quota, and no factoring into tiny lemmas | An eight-sentence cap manufactured lemma chains that read worse than the proof they replaced — corrected by the operator |
| 2026-08-18 | Sections are not prescribed: a head, an introduction stating the results, and the references are all a paper needs | A required section list is a slot-filling instruction, and the mathematics should decide the shape — corrected by the operator |
| 2026-08-18 | The author is the model; the operator and the **bold** freedom level ride in a footnote | A reader of a machine-written paper asks first how much of the direction was the machine's, and that must not be left to be guessed |
| 2026-08-20 | The proof's closing □ is a `QED` character style ending the last paragraph, not cell furniture and not its own cell | A frame label is centred vertically by the front end, so it sat mid-proof; a separate right-aligned cell was tried first and rejected on sight, leaving the paclet's own Complex Systems convention — inline at the end — which is also Wolfram's |
| 2026-08-20 | The exercise paper lives at `ResearchNotebooks/EquidistanceOddGirth/Paper/` in the dev repo, not at its root | `scaffold-paper.sh` writes `<dir>/Paper/main.tex` with no collision check, and the root `Paper/` is the author's own paper; `ResearchNotebooks/` is git-ignored there and already holds an LLM-authored `.tex` |

## Progress

- **S0** 2026-08-18 — item filed out of the 4.13.0 session; nothing worked yet. → [style.md](../../skills/research-notebook/style.md)
- **S1** 2026-08-20 T1 — built the first real notebook under the 4.13.0 rules and measured it; 7 writing rules and 3 build defects recorded, 2 of the 7 being guide rules that contradict each other. → [the findings](../../Wiki/Concepts/PaperStyleExercise.md)
- **S2** 2026-08-20 T2 — re-set the same mathematics as a scaffolded LaTeX paper and compiled it; 5 findings confirmed as the guide's, 4 new to the LaTeX path, 7 defects in the build path, one of them silent reference loss. → [the findings](../../Wiki/Concepts/PaperStyleExercise.md#the-latex-path--the-same-document-re-set)
- **S3** 2026-08-20 T3 — reconciled every T1/T2 finding into the shipped guide, generators and templates; the three numbers keep their values and gain a scope, and two findings changed under re-measurement. → [what T3 corrected](../../Wiki/Concepts/PaperStyleExercise.md#what-t3-corrected)
- **S4** 2026-08-20 T4 — the operator's read found the QED square centred vertically in every proof; fixed in all seven MathNotebook stylesheets plus a new generator pass, and the notebook rebuilt. Three stale fingerprint entries turned up on the way. → [what the T4 read found](../../Wiki/Concepts/PaperStyleExercise.md#what-the-t4-read-found)
