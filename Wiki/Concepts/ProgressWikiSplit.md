# Progress vs Wiki: where the knowledge actually is

*[ LLM Generated ]*

Whether the `Work/` ↔ `Wiki/` split — execution state vs durable knowledge — holds in the artifacts, and what the misplacement costs to read.
Measured 2026-07-27 over all 25 `## Progress` blocks of the seven items in `Work/`, for `EvaluateWorkItemsEfficiency` T2.
The corpus includes T2's own Progress block, so the numbers move as this article lands; the script is the authority, not the figures quoted here.
Companion to [Session Information Budget](SessionInformationBudget.md), which measured the *size* of the read; this measures its *content*.

## Method, and what it does not support

Every claim-line of every Progress block was classified by **destination** — where the line would live if the split were right:

| | class | destination |
|---|---|---|
| **D** | durable | a fact about an external tool, artifact, or this plugin, true regardless of which task ran → `Wiki/` |
| **X** | decision | a choice and its rationale, or a reconciliation with the Spec → `## Decisions` / `## Spec` |
| **H** | hand-off | a pointer aimed at one named next task ("T3 must …") → live for exactly one session |
| **N** | narration | headers, counts ("four things."), meta-commentary on the Spec's framing, verification records, process maxims → nowhere |

The unit is the claim-**line**, not the note: the sources use `Semantic line breaks: on`, so one line is one sentence is near enough one claim, and every note audited mixes classes internally.

Three limits, all of which bias the same way:

- **D is a lower bound.** A bold `**lead sentence.**` on its own line is counted `N` even when it states the finding, because the elaboration that follows is counted separately.
- **`Learned` is classified exhaustively (132 lines); `Did` is sampled.** 60 kB is more than one session can classify honestly. The sample is the *median-sized* `Did` block of each item with ≥ 4 sessions — 11.1 kB, 18 % of all `Did`, chosen by size so there is no cherry-picking. Median selection excludes the largest blocks, which are the S1 repo surveys and the densest in durable fact, so the extrapolated rate is likely an undercount.
- **Bytes, not tokens**, for comparability with T1. Prose runs ~4 B/token; the tables inside `Did` do not.

The classification is one reading, hand-encoded in `CLASS` and `DID_SAMPLE` in `Wiki/Concepts/audit_learned_notes.py`, and contestable line by line — `python3 Wiki/Concepts/audit_learned_notes.py` prints the verdict against every claim-line.

## `Learned` was the wrong thing to audit

T2 was scoped to the `Learned` notes. `Learned` is 23 % of Progress:

| field | bytes | share of Progress |
|---|---|---|
| `Did` | 60,445 | **68 %** |
| `Learned` | 20,772 | 23 % |
| `Next` | 3,527 | 4 % |
| `Prompt` | 1,615 | 2 % |

And `Did` is not what its name suggests.
It is not a record of actions — it is where the measurement tables live.
`MathNotebookIntegration` S2's `Did` carries the `StyleDefinitions` → `CounterIncrements` discriminator table and the referenced-vs-embedded cloud comparison; `PacletDocumentation` S1's carries PureMath's directory layout and its full frontmatter field list; `PacletDocumentation` S6's carries the two-form `paclet:` link-rewriting rule.
Classified at the same granularity, the two fields have **the same durable density**:

| field | D | X | H | N |
|---|---|---|---|---|
| `Learned` (132 lines, exhaustive) | **62.1 %** | 6.1 % | 14.8 % | 17.0 % |
| `Did` (73 lines, 18 % sample) | **66.8 %** | 2.7 % | 0.0 % | 30.5 % |

So the `Did` / `Learned` field boundary does not track the durable / session-local boundary at all.
It splits by *when the fact was obtained* — during the work, or on reflection afterwards — which is not a distinction any reader cares about.
**The field structure is not the axis on which the content should be split.**
That is the finding T3 has to act on, and it means the answer is not "write better `Learned` notes".

## The bill

**~53 kB of durable knowledge is in `Work/`. `Wiki/` holds 6.6 kB of it.**

| | bytes |
|---|---|
| durable in `Did` (extrapolated at 66.8 %) | ~40.4 kB |
| durable in `Learned` (classified) | 12.7 kB |
| **total durable content living in `## Progress`** | **~53.1 kB** |
| `Wiki/Resources/MarkdownToNotebook.md` — the only article harvested from a work item | 6.6 kB |
| `Wiki/Concepts/SessionInformationBudget.md` + this article — `EvaluateWorkItemsEfficiency`'s own output, not harvested | 21.5 kB |
| `Wiki/Index.md` + `Wiki/Status.md` | 4.9 kB |

Counting only what was harvested *from* the work, the ratio is **8 : 1** against the Wiki.
The script's aggregate ratio is lower and falling, but only because this item keeps adding its own articles to the denominator — that is not harvesting.

This is a **backlog, not a verdict on `update-wiki`** — see the next section before reading it as one.

**~30 kB of that durable content is structurally invisible at the moment it matters.**
`next-session` step 2 reads the tail of Progress. At each item's final session, durable content in blocks below the tail:

| item | `Did` below tail × 67 % | + `Learned` below tail | hidden |
|---|---|---|---|
| `MathNotebookIntegration` | 13,284 B | 2,005 B | **~10.9 kB** |
| `PacletDocumentation` | 11,680 B | 309 B | ~8.1 kB |
| `AdoptMarkdownToNotebook` | 4,103 B | 3,472 B | ~6.2 kB |
| `EvaluateMarkdownToNotebook` | 6,488 B | 732 B | ~5.1 kB |
| | | | **~30.3 kB** |

Paid for once, then skipped by the rule that makes the read affordable.
The Spec's worry was that a fact in Session 2's "Learned" is invisible to a tail read; the measurement says the exposure is four times larger than that, because `Did` is where most of the facts are.

**~8.7 kB is a second copy of something the same session wrote elsewhere.**
14.3 % of the `Did` sample restates what that session had just put into `CLAUDE.md`, a skill file, or a wiki article — `AdoptMarkdownToNotebook` S4 spends four of twelve lines describing the two `SKILL.md` sections, the wiki article, and the `CLAUDE.md` section it had just written.
The duplicate is not free, and it is the copy that rots: that item's S3 records that `research-notebook`'s md↔nb sync "uses `ExportString[Import[path], "Markdown"]`", which its own T5 then replaced with one-way generation plus a fingerprint.
The sentence is false today and still sits in `Work/Done/`.

## The destination did not exist for 21 of the 24 committed blocks

`Wiki/` was first committed in `f2c5aaa` — `AdoptMarkdownToNotebook` T4, the third-to-last session in the whole corpus.
**21 of the 24 committed Progress blocks were written before there was anywhere else to put a durable fact.**
So the 8 : 1 ratio above measures an unharvested legacy, and says nothing about whether the skill's step-7 `update-wiki` call works.

On the three blocks that *could* harvest, it did, every time:

| block | wrote to `Wiki/` | also wrote |
|---|---|---|
| `AdoptMarkdownToNotebook` S4 | `Index.md`, `Status.md`, `Resources/MarkdownToNotebook.md` (+63) | `CLAUDE.md`, `skills/new-notebook/SKILL.md` |
| `AdoptMarkdownToNotebook` S5 | `Resources/MarkdownToNotebook.md` (+18), `Status.md` | `CLAUDE.md`, `skills/research-notebook/SKILL.md` |
| `EvaluateWorkItemsEfficiency` S1 | `Concepts/SessionInformationBudget.md` (+132), `Index.md`, `Status.md` | — |

Three for three.
The forward mechanism is not the failure — and that inverts what T3 has to fix.

Because the block **did not get smaller.**
`AdoptMarkdownToNotebook` S4 wrote the wiki article and then spent 654 B of its 1,979 B `Did` — 33 % — describing the article, the two `SKILL.md` sections, and the `CLAUDE.md` section it had just written.
`EvaluateWorkItemsEfficiency` S1 deliberately routed its findings to the Wiki, said so in its own Decisions table, and still restated 572 B of the article's content in a 688 B `Learned` note — **83 %**.
That block is the best case in the corpus, written by a session whose whole subject was this problem, and it still duplicated four fifths of what it had just filed.

So the defect is not that facts fail to reach `Wiki/`.
It is that reaching `Wiki/` does not **discharge** the obligation to narrate them again in Progress, and nothing in the format or the skill says a pointer is sufficient.
Two things follow for T3, in this order:

1. A **harvest pass** over `Work/Done/` is owed — ~50 kB of durable content in 21 blocks written before the destination existed, none of which has moved since.
2. The forward rule needs to make Progress a **pointer**, not a précis. Today writing to the Wiki *adds* bytes to the session's output instead of moving them.

## Append-only prose gets contradicted; an article gets corrected

1,031 B of `Learned` — 5.0 % — exists only to reverse a claim in an earlier Progress block of the same item.
378 B was read as true by at least one session before the reversal landed.

`AdoptMarkdownToNotebook` is the worked example.
S1 concluded that upstream commit `afd7c1e` postdated the evaluated tip and told T2 to expect a stale measurement.
S2 established it was two commits *below* the pin, and spent four lines saying so.
Both the wrong claim and its refutation are in the file, permanently, and a reader must reconstruct the order to know which won.
The same pattern recurs at S4 → S3 ("dropped `research-notebook`" meant dropped as an adoption surface, not deleted) and S5 → S4 (the `::: theorem numbered` spelling S4's own Spec text got wrong).

Had those facts been in `Wiki/Resources/MarkdownToNotebook.md`, S2 would have **edited the line** and the wrong version would have left the read path entirely — the `revise` protocol explicitly allows this: "if an article becomes wrong because code changed, just fix it."
This is the structural argument, independent of byte counts: **`## Progress` is append-only, so it can only accumulate contradictions, while `Wiki/` is the one surface in the system where a fact can be corrected rather than debated.**
An unattended pipeline inherits this directly — it would read the file and have no user to arbitrate.

## What is genuinely session-local is small

Removing the durable content leaves a third of the current volume:

| item | sessions | `## Progress` today | projected | per session |
|---|---|---|---|---|
| `MathNotebookIntegration` | 6 | 25.1 kB | 9.1 kB (36 %) | 4,187 → 1,519 B |
| `PacletDocumentation` | 6 | 22.7 kB | 8.7 kB (38 %) | 3,780 → 1,449 B |
| `AdoptMarkdownToNotebook` | 5 | 21.6 kB | 9.9 kB (46 %) | 4,329 → 1,972 B |
| `EvaluateMarkdownToNotebook` | 4 | 13.5 kB | 5.1 kB (37 %) | 3,382 → 1,265 B |
| all 25 blocks | 25 | 88.6 kB | 35.3 kB | 3,542 → 1,412 B |

The residue is real and should not be squeezed further: hand-offs (~15 % of `Learned`, and the whole point of the `Next` field), decisions, and the audit-trail sentence a human wants when skimming what happened.
Note the projection is a **floor on the item file, not on the session** — the durable bytes do not vanish, they move to a surface that is read on demand, deduplicated, and editable in place.
Against T1's 27.7 kB unconditional preamble, a 1.4 kB/session Progress block is no longer the term worth optimising.

## What T2 concludes

1. **~53 kB of durable knowledge sits in `## Progress`, against 6.6 kB harvested — but this is a backlog, not a broken skill.** `Wiki/` postdates 21 of the 24 committed blocks; all 3 blocks that could harvest did. A harvest pass over `Work/Done/` is owed as its own task.
2. **Writing to `Wiki/` does not shrink the Progress block.** In the three harvesting sessions the durable content was filed *and* re-narrated — 33 % of one `Did`, 83 % of one `Learned`. The forward defect is duplication, not omission, and no format change that leaves this unaddressed will help.
3. **The `Did` / `Learned` fields are the wrong axis.** Both are ~63–67 % durable. `Did` is 68 % of Progress and holds the measurement tables. Tightening the prose inside these fields cannot fix the misplacement; T2's own scoping to `Learned` addressed 23 % of the problem.
4. **The tail-read rule hides ~30 kB of durable content**, four times more than the `Learned`-only exposure the Spec anticipated.
5. **Append-only is the load-bearing structural defect**, not verbosity: 1,031 B of pure correction scaffolding, 378 B read as true before reversal, and at least one sentence that is false today with no mechanism to fix it. `Wiki/` is the only surface in the system where a fact can be corrected instead of contradicted.
6. **The floor is ~1.4 kB per session**, a third of today's 3.5 kB — worth having, but small next to T1's 27.7 kB fixed term.

T3 owns the format decision. This article does not make it, but it constrains it: the question is not how to write shorter Progress entries, nor how to force facts to the Wiki — that already happens — it is **what makes a Progress entry a pointer rather than a précis**, and, given (5), whether a closed item's Progress should be pruned to its decisions and hand-offs once its facts are harvested.

## Reproduce

```bash
python3 Wiki/Concepts/audit_learned_notes.py
```

Prints the corpus split, both class tables, the per-item bill, the hidden-below-tail estimate, the projection, and the class assigned to every one of the 127 `Learned` claim-lines so the classification can be argued with.
The two hand-encoded tables `CLASS` and `DID_SAMPLE` are asserted against the live corpus, so an edit to any item file that adds or removes a claim-line fails the script rather than silently misaligning.

## See also

- [Session Information Budget](SessionInformationBudget.md) — T1: the size of the per-session read, and the 27.7 kB fixed term that dominates it
- `Work/Active/EvaluateWorkItemsEfficiency.md` — the item this serves; T3 decides the format
- [Status](../Status.md)
