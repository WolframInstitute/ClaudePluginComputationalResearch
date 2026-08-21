# ExampleEveryDefinition

*[ LLM Generated ]*

> Type: investigation
<!-- Status is the folder: Active/ Backlog/ Done/ Dropped/. Move the file to change it. -->

## Spec

Origin: `ExercisePaperStyle` T4 (2026-08-21).
The operator's ruling overturned § *Examples* — a definition now gets an example, whose picture shows the phenomenon — which leaves the two documents that produced the ruling failing it: § *Primitives* carries five definitions with no example among them, on both paths, and § *Radius* two more.

This item brings both documents into line, which is also the first exercise of the corrected rule on a real page.
It is the same instrument as before: a finding that appears on both paths is the guide's, a finding on one is that generator's.

### Requirements

- Six examples, one per definition that has an object to show, in both documents: `Def:Betweenness`, `Def:Segment`, `Def:Equidistant`, `Def:Midpoint`, `Def:Radius`, `Def:Sigma`.
  The base *substrate* definition takes none — a picture of a graph illustrates nothing about it.
- Each two lines, no options, no annotation, no labels; the picture verified on a kernel before it is written in.
- The notebook regenerated through the normal build path, with the fingerprint gate reporting zero drift.
- The paper's six figures exported from exactly the calls shown, and `latexmk` clean.
- The forward reference at `EquidistanceOddGirth.md:37` dropped while the file is open anyway.

### Design / API

The six instances, approved by the operator on 2026-08-21 from a rendered contact sheet:

| Definition | Instance | What the picture shows |
|---|---|---|
| `Def:Betweenness` | `GridGraph[{3,3}]`, the middle-row pair | of the seven other vertices only the centre lies between them |
| `Def:Segment` | the same grid, opposite corners | the segment is the whole grid — a segment is not a path |
| `Def:Equidistant` | Petersen, a pair at distance 2 | four equidistant vertices, one of them between |
| `Def:Midpoint` | Petersen, the same pair | the intersection with the segment leaves one of the four |
| `Def:Radius` | dodecahedron, a pair at distance 3 | four equidistant vertices at distances 2, 2, 3, 3 |
| `Def:Sigma` | 7-cycle with one chord | σ = 1, attained only on the triangle the chord makes |

Petersen carries two definitions in a row deliberately: the midpoint picture is visibly the equidistant-set picture minus the vertices that are not between, which two different graphs would lose.

### Edge cases & out of scope

- The exercise documents stay undeployed and uncommitted in the dev repo, as they were.
- The instances are deliberately small, which the guide now advises against for a real paper (§ *Examples*, *Err large rather than small*) — this is an exercise, and the operator approved these six for it.
- The paclet's interactive QED half is a separate concern, recorded in [PaperStyleExercise](../../Wiki/Concepts/PaperStyleExercise.md#the-qed-square-was-cell-furniture) and belonging to the paclet's own session.

## Tasks

All done.

### Done

- [x] T1 (S1) — the notebook: six examples in, the forward reference dropped, rebuilt with 84 top-level cells, 9 example groups, 93 cells fingerprinted and zero drift.
- [x] T2 (S1) — the paper: the same six with figures exported from exactly those calls, compiled to 9 pages with no unresolved references.

## Hand-off

Both documents are in line with the corrected rule and both are built; neither is deployed and neither is committed, as before.
The three findings the exercise produced are [in the wiki](../../Wiki/Concepts/PaperStyleExercise.md#exercising-the-corrected-rule), and all three are already fixed in the shipped files.

Two things a later session may want.

**The paper has one underfull vbox** where it had none, the cost of six more unbreakable example blocks on a 9-page paper.
It is a page-breaking artefact rather than a defect, and the block binding that causes it is the guide's own rule (§ *Examples*, the typeset path).

**The pictures are deliberately small**, which the guide now advises against for a real paper (§ *Examples*, *Err large rather than small*).
The operator approved these six for an exercise; a real paper written under the rule should take larger instances.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-21 | The base *substrate* definition takes no example | A picture of a graph shows nothing about the definition of a graph; six examples for seven definitions |
| 2026-08-21 | Petersen carries `Def:Equidistant` and `Def:Midpoint` on one pair | The second picture is the first minus the vertices that are not between, so the reader sees the intersection act |

## Progress

- **S1** 2026-08-21 T1+T2 — both documents brought into line: six examples per path, verified on a kernel and approved from a contact sheet before they were written in. Three build-path findings, all fixed in the shipped files. → [what the exercise found](../../Wiki/Concepts/PaperStyleExercise.md#exercising-the-corrected-rule)
