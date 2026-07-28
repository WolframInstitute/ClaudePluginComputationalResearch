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

All tasks are done.

### Done

- [x] T5 — Harvest the durable content out of the `Work/Done/` Progress blocks that predate `Wiki/` into wiki articles. (S8)
- [x] T9 — Apply T6's must-be-resident test to the `CLAUDE.md` this plugin generates. (S8)
- [x] T8 — Trial the pipeline supervised on one real item; confirm the stop conditions fire as specified. (S7)
- [x] T7 — Implement the autonomous pipeline: driver, command, `revise` mode, markers. (S6)
- [x] T6 — Audit the auto-loaded preamble and decide what a session needs resident. (S5)
- [x] T4 — Specify the autonomous pipeline: item selection, stop conditions, failure handling, the `revise`-protocol question, the per-run digest, and the harness mechanism. (S4)
- [x] T3 — Decide and document the target format for Spec / Progress / Decisions, including the pruning question, and revise `work` + `next-session` to match. (S3)
- [x] T2 — Audit the Progress-vs-Wiki split: classify the "Learned" notes as durable or session-local and price the misplacement. (S2)
- [x] T1 — Measure the real per-session information budget from git history across the closed items. (S1)

## Hand-off

The item is complete; both of its questions are answered.

Is the system efficient — measured, in [SessionInformationBudget](../../Wiki/Concepts/SessionInformationBudget.md) and [ProgressWikiSplit](../../Wiki/Concepts/ProgressWikiSplit.md); the format that follows is in force ([ItemFileFormat](../../Wiki/Concepts/ItemFileFormat.md)), both auto-loaded preambles are audited ([PreambleAudit](../../Wiki/Concepts/PreambleAudit.md), [GeneratedPreambleAudit](../../Wiki/Concepts/GeneratedPreambleAudit.md)), and T5's harvest cleared the legacy backlog ([ProgressHarvest](../../Wiki/Concepts/ProgressHarvest.md)).
Can it run unattended — yes; built, trialled live, and documented in [AutonomousPipeline](../../Wiki/Concepts/AutonomousPipeline.md) and [AutoRunOperations](../../Wiki/Concepts/AutoRunOperations.md).

The two loose ends this item's hand-off had been carrying — the untested failure paths and the empty MCP allowlist — are filed as `Work/Backlog/HardenAutoRun.md`.

This file predates the format it decided: S1 and S2 keep their multi-paragraph Progress blocks under the migration rule, and S3 onward is one line.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | Filed as `investigation`, in `Backlog/`, with measurement before redesign. | The efficiency claim is currently unmeasured in both directions, and an autonomous loop multiplies whatever the per-task overhead is — so measuring first is what makes the second question answerable. |
| 2026-07-27 | T1's findings go in `Wiki/`, and Progress carries only a pointer plus the notes the next session needs. | The item's own measurement says Progress is the least-read section, so writing the findings there would have reproduced the defect being measured. This item follows the split it is proposing. |
| 2026-07-27 | The measurement script ships at `Wiki/Concepts/measure_session_budget.py`, not in `scripts/`. | `scripts/` is skill-invoked plugin surface with a table in `CLAUDE.md` to keep current; a one-off analysis instrument for T2/T3 re-measurement belongs next to the article it regenerates. |
| 2026-07-27 | T2 widened its own scope from `Learned` to `Learned` + a sampled `Did`. | `Learned` is 23 % of Progress and `Did` 69 %, at the same durable density — the literal scope would have priced a quarter of the misplacement and produced a confidently wrong answer for T3. |
| 2026-07-27 | The classification is hand-encoded in the script and asserted against the live corpus, rather than described in prose. | It is a judgement call per line, so it has to be contestable and re-runnable; the assertion means an edit to any item file fails the script instead of silently misaligning the table. |
| 2026-07-27 | Harvesting the pre-`Wiki/` backlog is a separate task (T5), sequenced after T3, not folded into T2. | T3 decides whether a harvested Progress block is then pruned; harvesting first would mean writing articles against a format that is about to change. |
| 2026-07-27 (S3) | Five sections and no others, with `## Progress` cut to one line per session and carry-forward moved to an overwritten `## Hand-off`. | T2 showed the `Did`/`Learned` axis does not track durability and that "write pointers" was already available and ignored, so the line limit is the enforcement — a one-line entry cannot be a précis; a hand-off is live for one session and needs a mutable home. See [ItemFileFormat](../../Wiki/Concepts/ItemFileFormat.md). |
| 2026-07-27 (S3) | `## Spec` and `## Decisions` are bounded too — Spec corrected in place, a reversal editing the row it reverses. | Measured: once Progress leaves the read path those two are 70–95 % of what a session opens, and 20.4 kB of `AdoptMarkdownToNotebook`'s 21.4 kB — the item the Spec cited as the example of Progress bloat. |
| 2026-07-27 (S3) | Closed items are not pruned or rewritten; a false archived claim gets a one-line `> Superseded:` marker. | Answers T2's open question. git already holds every version and a closed item is read at most once more, so rewriting the audit trail costs the human record and saves no read. |
| 2026-07-27 (S3) | `next-session`'s paclet branch/worktree/PR procedure moved to a read-on-demand sibling file. | It was 38 % of a file read unconditionally every session and serves only paclet-dev repos changing a submodule — the same pay-for-what-you-read rule the format applies to Progress. |
| 2026-07-27 (S4) | The loop is driven by headless `claude -p`, one process per task; `CronCreate`, `/loop`, and background tasks are rejected as drivers. | All three enqueue into the running session, so context accumulates — the Spec's "compaction is not clearing" risk. Cron may still trigger a run without being the loop. |
| 2026-07-27 (S4) | `revise`'s human gate is **deferred**, not dropped: work lands on `auto/<Item>`, the per-run digest is the "present" step, and the merge is the "approve". | The protocol's purpose is that nothing lands unreviewed, not that a human is present at generation time. Restricting the loop to sign-off-free tasks was the alternative and leaves it almost nothing to run. |
| 2026-07-27 (S4) | Eligibility is opt-in and fail-closed — `> Autonomous: allowed` per item, `(human)` per task, and a hard stop unless exactly one eligible item is active. | An unattended wrong pick is invisible until the digest; the cost of the restriction is a human typing one item name. Priority ordering was rejected, not solved. |
| 2026-07-27 (S4) | The driver verifies each run (new commit + a newly checked box) rather than trusting its exit status, and never cleans up after a failure. | Measured: an unprefixed plugin slash command headless is a zero-cost no-op reporting `is_error: false`, so exit status alone cannot detect a run that did nothing. An unattended `git reset --hard` can destroy work no human has seen. |
| 2026-07-27 (S4) | T6 resequenced ahead of T7/T8. | The cold start measured at 31.5 k input tokens in this repo, so the fixed preamble — 60 % of it `CLAUDE.md` — is the pipeline's dominant cost line and decides whether implementing it is worthwhile. |
| 2026-07-28 (S5) | Inventory and reference leave the auto-loaded `CLAUDE.md` for a read-on-demand `ARCHITECTURE.md`, and the Skills table is **deleted** rather than moved. | Inventory was 47 % of the file, and the harness already injects 9.6 kB of skill descriptions unconditionally with `README.md` carrying a second copy — a third was lossy and paid every turn. The tables also drifted (headings said 20 skills / 21 commands against 21 / 22) while taking 18 of the file's 26 commits. |
| 2026-07-28 (S6) | The driver excludes `Work/Runs/` from its own dirty-tree check rather than relying on a `.gitignore` entry. | Writing the digest dirties the tree, so condition 4 would halt the second task of every run in any repo that has not ignored the path — and the plugin scaffolds repos whose `.gitignore` it does not control. The entry is still added, for the human's `git status`. |
| 2026-07-28 (S6) | The driver passes the prompt **before** its flags and treats `terminal_reason: completed` as success. | Both were found by running `claude -p` rather than reading the help: `--allowedTools` is variadic and eats a trailing prompt (fatal), and a clean run reports `completed` where `stop_reason` reports `end_turn` — checking both against `end_turn` would have halted every successful task. |
| 2026-07-28 (S6) | T7 verified the stop conditions against a stub `claude` in a fixture repo and left the live run to T8. | Every condition needs a specific failure to fire, and only a stub can produce them on demand — a live run exercises one path per ~31.5 k tokens. The stub cannot fail the way a session does, which is exactly what T8 is for. |
| 2026-07-28 (S7) | The trial ran against a new throwaway item, `AutoRunTrial`, whose tasks are wiki prose. | The hand-off forbade trialling on the item that owns the driver; wiki prose is the one deliverable class `revise` exempts from sign-off, so a first unattended run could not land anything a human had not agreed to see generated. |
| 2026-07-28 (S7) | The driver **tells** the session it is autonomous (`--append-system-prompt`) instead of `revise` asking it to infer it. | The first live run did its task correctly and still recorded that it had run interactively: a session with no user is indistinguishable from one whose user has not spoken. Any "behave differently when unobserved" rule has to be told. |
| 2026-07-28 (S7) | Backstop caps are checked before the `(human)` gate, reversing T7's order. | Both fired on the same iteration, and gate-first reported `task-gated` — exit 1, *you are needed* — for a run that had merely finished its allotment. |
| 2026-07-28 (S5) | The 1.5 kB Wolfram kernel policy stays resident, though most sessions never spawn a kernel. | It is the largest surviving block and the obvious next cut, but a license error is unfindable after the fact and the section is what tells a session the MCP-first rule exists at all — the test is "must be known before you know to look", and this passes it. |
| 2026-07-28 (S8) | The 7.2 kB `code_style_template.md` stays whole in the generated `CLAUDE.md`, despite being two thirds of it. | It classifies as policy end to end by the same test that kept the kernel policy: nothing prompts a session to look up a style guide, and a violation is invisible afterwards because the code works. Size made it the suspect; the test exonerates it. See [GeneratedPreambleAudit](../../Wiki/Concepts/GeneratedPreambleAudit.md). |
| 2026-07-28 (S8) | The four code-style bullets that duplicate the user's global `~/.claude/CLAUDE.md` are **kept**, while the one that contradicts it is fixed. | The plugin cannot read a user's global file or assume one exists, so deleting the overlap is correct on this machine and lossy on every other. A contradiction is a bug regardless of who has a global file; duplication is only a cost. |
| 2026-07-28 (S8) | T9 closes as *audited, cuts justified as correctness not cost* — no further byte-trimming of the generated preamble. | The two duplicate sections were worth 230 B / 582 B, and T7 measured an 11.6 kB cut moving cold start ~1 %; a saving this size is below the noise of an MCP-schema-dominated floor. |
| 2026-07-28 (S8) | The harvest produced four articles, not one per closed item. | Durable content clusters by *subject* (a paclet, a converter, a doc pipeline) and not by the item that happened to discover it — MathNotebook facts came from two separate items, and `DeclutterReadme`/`MarketplaceReadme` yielded nothing that earns an article. One-article-per-item would have reproduced the duplication the harvest exists to remove. |
| 2026-07-28 (S8) | `> Harvested:` pointers were added to the closed items alongside the `> Superseded:` markers T3 authorised. | Same class of edit — a one-line marker, no pruning or rewriting — and without it a reader landing in a closed block has no way to know a corrected version exists. |
| 2026-07-28 (S8) | The two open `/auto-run` gaps left this item as `Work/Backlog/HardenAutoRun.md` rather than becoming T10/T11. | This item's two questions are answered; the gaps are maintenance on the artifact it produced. Keeping them here would hold an answered investigation open indefinitely. |

## Progress

Append-only, one line per session; nothing reads it.
S1 and S2 predate the format and keep their blocks.

- **S8** 2026-07-28 T5 — harvested 30.9 kB of durable content out of 97 kB of closed-item Progress into three new articles plus an extended one, with six `> Superseded:` markers and a `> Harvested:` pointer per item; filed the leftover `/auto-run` gaps as `Backlog/HardenAutoRun.md` and closed the item. → [ProgressHarvest](../../Wiki/Concepts/ProgressHarvest.md), [MathNotebook](../../Wiki/Resources/MathNotebook.md), [PacletDocumentation](../../Wiki/Concepts/PacletDocumentation.md), [PureMath](../../Wiki/Resources/PureMath.md)
- **S8** 2026-07-28 T9 — audited the generated project `CLAUDE.md` against T6's test: 82 % policy before any cut, the code-style block exonerated, and a contradiction between two auto-loaded files found and fixed; `## Work` and the math template's skills listing cut as third copies. → [GeneratedPreambleAudit](../../Wiki/Concepts/GeneratedPreambleAudit.md), `Wiki/Concepts/measure_generated_preamble.py`
- **S7** 2026-07-28 T8 — trialled the pipeline live on the throwaway `AutoRunTrial`: two real tasks landed, three defects found and fixed in `05cdc45`, both fixes re-verified, and all eight fail-closed paths checked against this repo. → [AutonomousPipeline § The supervised trial](../../Wiki/Concepts/AutonomousPipeline.md#the-supervised-trial--what-two-real-runs-cost-and-changed), [AutoRunOperations](../../Wiki/Concepts/AutoRunOperations.md)
- **S6** 2026-07-28 T7 — built the autonomous pipeline: `scripts/auto-run.sh`, `/auto-run`, `revise` § *Autonomous mode*, the two eligibility markers, and the `ARCHITECTURE.md` / `README.md` rows; every stop condition fired against a stub, and the cold start re-measured at 31,187 tokens. → [AutonomousPipeline § Implementation](../../Wiki/Concepts/AutonomousPipeline.md#implementation)
- **S5** 2026-07-28 T6 — split `CLAUDE.md` 16.9 → 5.3 kB, taking the fixed preamble to 16.3 kB; inventory and reference moved to a new root `ARCHITECTURE.md`. → [PreambleAudit](../../Wiki/Concepts/PreambleAudit.md), `Wiki/Concepts/measure_preamble.py`
- **S4** 2026-07-27 T4 — specified the autonomous pipeline against measured harness behaviour; added T7/T8 and moved T6 ahead of them. → [AutonomousPipeline](../../Wiki/Concepts/AutonomousPipeline.md)
- **S3** 2026-07-27 T3 — decided the item file format and revised `work`, `next-session` (−613 B), both item templates, `provenance`, `CLAUDE.md`, and this file to match. → [ItemFileFormat](../../Wiki/Concepts/ItemFileFormat.md), `Wiki/Concepts/measure_item_sections.py`

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
