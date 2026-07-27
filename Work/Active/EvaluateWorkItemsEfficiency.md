# EvaluateWorkItemsEfficiency

*[ LLM Generated ]*

> Type: investigation

## Spec

Origin: "Put as a work item to evaluate the efficiency of the work items system.
Especially if there can be some long running pipeline clearing contexts and doing work items autonomously.
The amount of information transfered has to be optimized." (2026-07-27, immediately after `AdoptMarkdownToNotebook` closed on its fifth session.)

Evaluate whether the `Work/` + `next-session` system is actually efficient, and whether it can run **autonomously** as a long-running pipeline that clears context between tasks and works items unattended.
The measurable objective is the **information transferred per task**: what a fresh session must read to do useful work, and what it must write so the next session can start cold.
Today that budget is unmeasured, and there is reason to think it is bad — `AdoptMarkdownToNotebook` grew to roughly 15 kB of Spec, Progress, and Decisions across five sessions, so its last session paid to read a file mostly about sessions that had already finished.

Two questions, in order.
First, **is the current system efficient** — where does the context actually go, and what fraction of it changed the work?
Second, **can it run unattended** — what has to be true for a scheduled pipeline to pick up an item, do one task, commit, clear context, and repeat, without a human in the loop.
The second question is only worth answering if the first has a good answer, because an autonomous loop multiplies whatever the per-task overhead already is.

### Requirements

- **Measure before redesigning.** Instrument the real cost of a session: tokens read from `Work/`, `Wiki/`, `CLAUDE.md`, and the skill files, against tokens of durable output produced. The five sessions of `AdoptMarkdownToNotebook` and the four of `PacletDocumentation` are the available sample — reconstruct from git history rather than guessing.
- **Test the partial-read rule.** `next-session` step 2 says to read the full Spec and Tasks but only the tail of Progress. Establish whether that rule is followed in practice and whether it is *sufficient* — a task whose context lives in Session 2's "Learned" is invisible to a tail read, and S5 of `AdoptMarkdownToNotebook` shows the failure is real (S4's Spec text used the wrong div spelling, which a tail read carried forward unchallenged).
- **Decide where knowledge belongs.** Progress accumulates "Learned" notes that are really durable facts and belong in `Wiki/`. If the split were right, Progress would be short and skimmable and the Wiki would carry the transferable content. Measure how far from that the current items are.
- **Cost the autonomous loop honestly.** A scheduled pipeline needs: item selection with no human present, a stop condition, a way to fail safely mid-task, and a rule for what happens when a task genuinely needs a decision. The `revise` protocol currently *requires* a human for anything that is not wiki prose — so either the pipeline only runs tasks that need no sign-off, or `revise` needs an explicit autonomous mode. Resolve this rather than working around it.
- **Check what already exists before building.** `/loop`, `CronCreate`-based scheduling, and background tasks are available in the harness; the answer may be configuration rather than new plugin code.

### Design / risks

- **The obvious failure mode is silent drift.** An unattended loop that makes a wrong call at task 2 will build four more tasks on top of it before anyone looks. Whatever is proposed needs a cheap human review surface — a digest per run, not a per-task prompt.
- **Compaction is not the same as clearing.** The point of one-task-per-session is a *clean* context, not a summarized one; a pipeline that leans on auto-compaction gets the rot back. Verify that whatever mechanism is used actually starts cold.
- **Optimizing transfer can degrade it.** Shorter Progress entries are cheaper to read and easier to get wrong — S5's two most useful findings (`CreateCellID` does not stamp built cells; fingerprint after the round-trip, not in memory) are exactly the kind of detail a terser format would have dropped. The target is fewer *bytes carried per fact*, not fewer facts.
- Item files are user-editable and sometimes user-edited, so any format change has to stay hand-writable and diff-friendly. Do not propose a machine-only format.

### Edge cases & out of scope

- Do not redesign the folder-is-status convention; it works and costs nothing.
- Do not fold `Wiki/` and `Work/` together — the separation (durable knowledge vs execution state) is the thing that makes a partial read possible at all.
- This item evaluates the system; it is not licence to rewrite `next-session` before the measurement is in.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T3 — Decide and document the target format for Spec / Progress / Decisions given T1 and T2 — including whether Progress should be pruned or archived once its facts are in the Wiki — and revise `work` + `next-session` to match.
- [ ] T4 — Specify the autonomous pipeline: item selection, stop conditions, failure handling, the `revise`-protocol question (autonomous mode vs sign-off-free tasks only), the per-run digest, and what harness mechanism drives it. Present it for approval before implementing anything.
- [ ] T5 — Harvest the ~50 kB of durable content out of the 21 `Work/Done/` Progress blocks that predate `Wiki/` into wiki articles. *Added by S2; delete if you would rather leave the closed items alone. Sequence after T3, since T3 decides whether a harvested block then gets pruned.*

### Done

- [x] T2 — Audit the Progress-vs-Wiki split: classify the "Learned" notes as durable or session-local and price the misplacement. (S2)
- [x] T1 — Measure the real per-session information budget from git history across the closed items. (S1)

## Progress

### Session 1 — 2026-07-27 — T1
- **Did:** Measured the bookkeeping budget across all six closed items from git history and wrote the result to [Wiki/Concepts/SessionInformationBudget.md](../../Wiki/Concepts/SessionInformationBudget.md), with `Wiki/Concepts/measure_session_budget.py` to regenerate every number.
  Promoted this item from `Backlog/` to `Active/`.
- **Learned:** The findings live in the wiki article, deliberately — see below.
  Three things that only matter to the next session:
  `git log --follow --reverse` silently collapses to a single commit, so walk without `--reverse` and reverse in Python.
  Commits do not map 1:1 to sessions — `14c8981` created four items at once and two `PacletDocumentation` sessions also amended `AdoptMarkdownToNotebook`, so T2 must attribute "Learned" notes by Progress block, not by commit.
  The headline: the largest term is the unconditional 27.7 kB of `CLAUDE.md` + skill preamble, not the item file, which was smaller than that in 21 of 22 measured session starts — so T3 must not confine itself to the item format.
- **Next:** T2 — audit the Progress-vs-Wiki split: classify each "Learned" note as durable or session-local and quantify the read cost of the misplacement.

### Session 2 — 2026-07-27 — T2
- **Did:** Classified all 127 claim-lines of every `Learned` note plus an 18 % sample of `Did`, by destination, and priced the misplacement.
  Findings in [Wiki/Concepts/ProgressWikiSplit.md](../../Wiki/Concepts/ProgressWikiSplit.md); `Wiki/Concepts/audit_learned_notes.py` regenerates every number and prints the class assigned to each line, so the classification can be argued with rather than taken on trust.
- **Learned:** Two notes about this session; every finding is in the article, and this block is deliberately a pointer rather than a précis.
  I widened T2's scope from `Learned` to `Learned` plus a sampled `Did` — reason in Decisions.
  My first draft of the article blamed step 7's `update-wiki` for firing once in six items, and the fairness check killed it: `Wiki/` postdates 21 of the 24 Progress blocks, and all 3 blocks that could harvest did.
  The finding survived inverted — duplication, not omission — but only because the check ran before the commit.
  Carry forward: date the destination before blaming the mechanism.
- **Next:** T3 — decide the target format for Spec / Progress / Decisions and revise `work` + `next-session`.
  T2 constrains it to one question: what makes a Progress entry a pointer rather than a précis.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | Filed as `investigation`, in `Backlog/`, with measurement before redesign. | The efficiency claim is currently unmeasured in both directions, and an autonomous loop multiplies whatever the per-task overhead is — so measuring first is what makes the second question answerable. |
| 2026-07-27 | T1's findings go in `Wiki/`, and Progress carries only a pointer plus the notes the next session needs. | The item's own measurement says Progress is the least-read section, so writing the findings there would have reproduced the defect being measured. This item follows the split it is proposing. |
| 2026-07-27 | The measurement script ships at `Wiki/Concepts/measure_session_budget.py`, not in `scripts/`. | `scripts/` is skill-invoked plugin surface with a table in `CLAUDE.md` to keep current; a one-off analysis instrument for T2/T3 re-measurement belongs next to the article it regenerates. |
| 2026-07-27 | T2 widened its own scope from `Learned` to `Learned` + a sampled `Did`. | `Learned` is 23 % of Progress and `Did` 69 %, at the same durable density — the literal scope would have priced a quarter of the misplacement and produced a confidently wrong answer for T3. |
| 2026-07-27 | The classification is hand-encoded in the script and asserted against the live corpus, rather than described in prose. | It is a judgement call per line, so it has to be contestable and re-runnable; the assertion means an edit to any item file fails the script instead of silently misaligning the table. |
| 2026-07-27 | Harvesting the pre-`Wiki/` backlog is a separate task (T5), sequenced after T3, not folded into T2. | T3 decides whether a harvested Progress block is then pruned; harvesting first would mean writing articles against a format that is about to change. |
