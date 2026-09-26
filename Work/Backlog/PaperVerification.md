# PaperVerification

*[ LLM Generated ]*

> Type: feature
<!-- Status is the folder: Active/ Backlog/ Done/ Dropped/. Move the file to change it. -->

## Spec

Origin: "We should create a new work item that will deal with computational scaffolding and verification of math papers. Similarly as in here /Users/pavel/Library/CloudStorage/Dropbox-Personal/shared/s1paper. but more thoughtful (we should work on that)" (2026-09-26, operator.)

A mathematician brings a LaTeX paper.
The plugin builds a computational scaffold beside it and then reviews the paper one labelled statement at a time.
Each statement ends with an honest status: what a machine checked, how far the check reaches, and what a reader must still take on trust.

The s1paper repo did this by hand for one paper, over three months.
It works, and it is the evidence for this item.
This item turns it into a plugin feature any paper can use, and fixes what grew there by accident.

### What s1paper got right — keep

- **The paper label is the key.** Every test carries `TestID -> "<label>"`, so a check names the statement it certifies.
- **Coverage is not certification.** A finite check is `partial` and says how far it reaches; `certified` is an explicit claim.
- **The queue is generated.** A coverage census over every label, rebuilt each session, is the work list. No task list copies it.
- **One statement per session.** The proof is rewritten as numbered steps flagged algebraic, structural or analytic. Each algebraic step is pinned by a test, and a verdict page says what is left.
- **Discrepancies are reported, never silently fixed.** A mistake in the paper is the author's to correct.
- **The submission PDF is unchanged.** Certificate marks print only in a review mode.

### What s1paper got wrong — fix

- **Built for one paper.** Six scripts parse `circle8.tex` by name. The review skill still names `circle7.tex`, one draft behind, and nothing noticed.
- **Facts written twice.** Notebook prose narrates its own coverage in three places, and a wiki page keeps the same census. Every new test makes that prose false.
- **It edits the author's paper.** A script writes `\cert{...}` after each registered `\label` in the paper. This plugin's rule is that nothing outside `Artifacts/` is written.
- **The reach taxonomy grew one case at a time.** There are now nine truncation regimes, several added mid-review because the existing ones would print a false claim.
- **Two copies of the engine.** The kernel is synced into the paclet, and a test fails when they drift.
- **Fragile keys.** A renamed label orphans its certificate. An unlabelled statement cannot be certified at all.

### Requirements

- Works on any LaTeX paper in `Paper/` or elsewhere; the paper is read, never written.
- One small status vocabulary and one reach taxonomy, designed once, before the first paper uses them.
- Every count, census and index is generated; prose never restates one.
- A review loop of one statement per session, whose queue `autolab` can work.
- Checks run through the Wolfram MCP (`TestReport`), with `wolframscript` as the fallback, per the kernel policy.
- Cross-links with the existing skills: `lean` can supply a `formalized` status, `new-paper` owns the document, and `journal` receives what a verdict cannot settle.

### Design questions for T1

- Where the layer lives, given the `Artifacts/` rule: a new top-level folder, or an artifact of its own.
- How certificate marks reach the PDF without editing the paper — a package that hooks `\label`, a pretex, a wrapper document.
- How keys survive a renamed label, and what an unlabelled statement gets.
- The registry format: a human-readable table the author can edit, or Wolfram data.
- Where the paper-specific engine lives: a paclet, `Code/`, or both without a copy.
- How the generated queue becomes `autolab` work without a second copy of it.

### Out of scope

- Typst papers — later, once LaTeX works.
- Proving statements. The layer checks and reports; mathematical repair is the author's.
- Publishing certificates to the Wolfram Cloud; the anchors are designed for it, the upload is not built here.

## Tasks

- [ ] T1 (model: opus, effort: xhigh — design-critical) — study s1paper's certificate layer end to end, answer the design questions in a `Wiki/Concepts/PaperVerification.md` article with evidence, and correct this Spec where it guessed.
- [ ] T2 (human) — operator rules on the design.
- [ ] T3 (model: opus, effort: xhigh — API contract) — the scaffold: a skill that reads a paper and generates the label inventory, the empty registry, the coverage census, a test-suite skeleton per section and a certification-notebook skeleton, from templates in the plugin.
- [ ] T4 (model: opus, effort: xhigh — design-critical) — the review loop: generalize s1paper's `verify-statement` into a plugin skill, one statement per session, with pin, register, regenerate and verdict.
- [ ] T5 (model: opus, effort: xhigh — cross-cutting) — the `autolab` bridge: the generated queue becomes backlog work, one statement per task.
- [ ] T6 (human) — trial on a second real paper chosen in T1: scaffold it, verify three statements, compare the effort against s1paper.
- [ ] T7 (model: sonnet, effort: high — doc pass) — rewrite the README's *Computational scaffold of papers and verification* section from *In design* to what shipped, with a table of its skills; then ARCHITECTURE, the blog post, and a version bump.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Fresh item; nothing in flight.
The source to study is `~/Library/CloudStorage/Dropbox-Personal/shared/s1paper`, which is a live repo that other sessions edit.
Read it, never write it.
Start at its `README.md`, `Verification/Certificates/`, `.claude/skills/verify-statement/SKILL.md`, `Wiki/Verification/Registry.md` and `Work/Active/I-StatementReview.md`.

## Decisions

| Date | Decision | Rationale |
|---|---|---|

## Progress

- **S0** 2026-09-26 — item filed from the operator's request; draft Spec awaiting approval.
