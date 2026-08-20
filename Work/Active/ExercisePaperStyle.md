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

- [ ] T3 — reconcile: correct `style.md` in place for what T1 and T2 exposed, and re-check the three suspect numbers above against real passages rather than against the flooding they were written to stop.
- [ ] T4 (human) — the operator reads both documents end to end and rules on what remains: the three numbers, and whether the tier boundaries sit in the right place.

### Done

- [x] T1 (S1) — build one real research notebook end to end under the new rules; keep a note of every passage where a rule and the mathematics disagreed.
- [x] T2 (S2) — write and compile one scaffolded LaTeX paper under the same guide, exercising the `\thanks` footnote, `macros.sty` and the Ruliology split.

## Hand-off

Two documents now exist and **neither is deployed or committed in the dev repo**: the notebook at `NotebooksLLM/EquidistanceOddGirth.{md,nb}` and the paper at `ResearchNotebooks/EquidistanceOddGirth/Paper/` (7 pages, compiles clean with `latexmk`). Both wait on the operator's read; the operator ruled at the start of S1 that nothing leaves the machine unasked.

T3 reconciles. Read [the findings](../../Wiki/Concepts/PaperStyleExercise.md) — it is now organised for exactly that: five findings that reproduce on both paths and are therefore `style.md`'s, four that only the LaTeX path exposes, and six defects in the shipped template plus one in `scaffold-paper.sh`. The three suspect numbers have a verdict from each path.

Two things T3 should not have to rediscover. The `macros_template.sty` cross-reference fix has been worked out and verified in the paper's local copy — `aliascnt` **and** `nosort`, where `nosort` alone is what stops cleveref silently dropping entries from a multi-reference list; copy that copy rather than re-deriving it. And the notebook carries one forward reference that T3's edit to `style.md` should not paper over: the fix belongs in the checklist, since the rule was already there and was simply not checked.

T4 is the operator's `(human)` task and reads both documents.

The blog post at `~/Library/CloudStorage/OneDrive-Personal/Web/p135246.github.io/Wolfram/_posts/2026-03-04-ai-assisted-computational-research.md` carries an unstaged 4.13 entry and a bumped *Last updated*. That is deliberate: the author syncs and publishes that repo. Do not commit it.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-18 | The paper carries only settled statements; experiments go to a Ruliology section and everything below that tier to the journal | Hedged `Claim`s at body weight were the main source of unreadability, and the fix is structural rather than stylistic |
| 2026-08-18 | Results are stated at the generality the proof reaches, never smaller | A first draft preferred "the smallest statement you can prove", which reads as a preference for triviality — corrected by the operator |
| 2026-08-18 | No proof-length quota, and no factoring into tiny lemmas | An eight-sentence cap manufactured lemma chains that read worse than the proof they replaced — corrected by the operator |
| 2026-08-18 | Sections are not prescribed: a head, an introduction stating the results, and the references are all a paper needs | A required section list is a slot-filling instruction, and the mathematics should decide the shape — corrected by the operator |
| 2026-08-18 | The author is the model; the operator and the **bold** freedom level ride in a footnote | A reader of a machine-written paper asks first how much of the direction was the machine's, and that must not be left to be guessed |
| 2026-08-20 | The exercise paper lives at `ResearchNotebooks/EquidistanceOddGirth/Paper/` in the dev repo, not at its root | `scaffold-paper.sh` writes `<dir>/Paper/main.tex` with no collision check, and the root `Paper/` is the author's own paper; `ResearchNotebooks/` is git-ignored there and already holds an LLM-authored `.tex` |

## Progress

- **S0** 2026-08-18 — item filed out of the 4.13.0 session; nothing worked yet. → [style.md](../../skills/research-notebook/style.md)
- **S1** 2026-08-20 T1 — built the first real notebook under the 4.13.0 rules and measured it; 7 writing rules and 3 build defects recorded, 2 of the 7 being guide rules that contradict each other. → [the findings](../../Wiki/Concepts/PaperStyleExercise.md)
- **S2** 2026-08-20 T2 — re-set the same mathematics as a scaffolded LaTeX paper and compiled it; 5 findings confirmed as the guide's, 4 new to the LaTeX path, 7 defects in the build path, one of them silent reference loss. → [the findings](../../Wiki/Concepts/PaperStyleExercise.md#the-latex-path--the-same-document-re-set)
