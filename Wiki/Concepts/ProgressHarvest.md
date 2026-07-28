# The Progress harvest

*[ LLM Generated ]*

What moved out of the closed work items' `## Progress` blocks into `Wiki/`, what deliberately did not, and what the pass cost.
Done 2026-07-28 for `EvaluateWorkItemsEfficiency` T5 — the backlog [Progress vs Wiki](ProgressWikiSplit.md) identified and [Item File Format](ItemFileFormat.md) unblocked.

## Why there was a backlog

T2 measured ~53 kB of durable knowledge sitting in `## Progress` against 6.6 kB harvested, and then established that this was **not** a broken skill: `Wiki/` was first committed during the third-to-last session of the whole corpus, so 21 of the 24 committed Progress blocks were written before there was anywhere else to put a durable fact.
All three blocks that *could* harvest did.

So the pass owed was a one-time legacy harvest, not a repair.
T3 set its terms: closed items are **not pruned or rewritten**, because git already holds every version and a closed item is read at most once more — rewriting the audit trail costs the human record and saves no read. A claim that is false today gets a one-line `> Superseded:` marker instead.

## What moved

| destination | new | note |
|---|---:|---|
| [MathNotebook](../Resources/MathNotebook.md) | 11.8 kB | new — the paclet, its stylesheet, both counter rules, the embed rule, the render-only verification, the referencing contract |
| [Paclet Documentation](PacletDocumentation.md) | 8.5 kB | new — the five doc-page defects, the staging fix, the deploy path, what needs a human |
| [PureMath](../Resources/PureMath.md) | 5.8 kB | new — the reference implementation, its layout and build, the shim tax and why it does not transfer |
| [MarkdownToNotebook](../Resources/MarkdownToNotebook.md) | +4.8 kB | existing article — gained the MCP-transport finding, four pipeline traps, the Claude-side answer, cadence correction |
| | **30.9 kB** | |

Source: 97.1 kB of `## Progress` across the seven closed items.

Five `> Superseded:` markers were added where a closed item states something false today:

| item | claim | now |
|---|---|---|
| `EvaluateMarkdownToNotebook` S1 | licence is absent, vendoring hard-stopped | the user confirmed the licence is fine |
| `EvaluateMarkdownToNotebook` S1 | "actively-moving target", daily commits | an artefact of June; July is bursty |
| `EvaluateMarkdownToNotebook` Recommendation | rewrite `PacletDocumentation` as "drive theirs" | not taken; official MCP tools chosen |
| `AdoptMarkdownToNotebook` S1 | expect T2's measurement to be materially stale | wrong; the commits predated the evaluated tip |
| `AdoptMarkdownToNotebook` S3 | `research-notebook`'s sync uses `ExportString[Import[…]]` | there is no sync; generation is one-way |
| `MathNotebookIntegration` S1 | the publish-staging defect is "worth its own work item" | fixed inside `PacletDocumentation` T5 |

The two `AdoptMarkdownToNotebook` markers and the third `EvaluateMarkdownToNotebook` one are the cases T2 predicted structurally: the refutation already existed in a later Progress block of the same item, or in another item entirely, and a reader had to reconstruct the order to know which won.
The marker does not delete the wrong claim — it stops the reader having to.

Each harvested item also carries a one-line `> Harvested:` pointer under its `## Progress` heading, naming the article that is now the version to read.

## What was deliberately not harvested

**`DeclutterReadme` and `MarketplaceReadme`** (3.1 kB of Progress between them) are almost entirely session-local: what was rewritten, that a length target was overshot, that a link resolved.
Two facts in them are durable and both are already recorded elsewhere — the marketplace repo's Conventional-Commits history with no hook of its own, and that `marketplace.json`'s description is a 90-word keyword sentence with no sub-clause that stands alone as a summary. Neither earns an article.

**`AutoRunTrial`** postdates the format and was wiki-synced as it went.

**The `## Recommendation` section of `EvaluateMarkdownToNotebook`** is a decision record, not durable knowledge — and three of its verdicts have since been overtaken. It keeps its supersede markers and stays where it is.

**Narration, hand-offs, and verification records** are the residue T2 said should not be squeezed: they are the audit trail a human wants when skimming what happened.

## Bytes are the wrong measure of this

30.9 kB of wiki against ~53 kB of durable Progress content is **not** a 42 % loss.
The Spec's own warning applies in reverse here: the target is fewer *bytes carried per fact*, not fewer facts.
Three effects account for most of the gap, and all three are the point of the exercise:

- **Deduplication.** The same finding appears in a `Did` block, again in that session's `Learned`, and again in a later session's recap. The stylesheet-embedding decision was stated four times across two items; the article states it once, with the measurement.
- **Narration is dropped.** "Verified through the MCP against a 10-cell probe" becomes the assertion the probe established, not the fact that a probe was run.
- **Contradictions collapse.** Where Progress holds both a claim and its refutation, the article holds the survivor.

What is genuinely lost is *chronology* — which session learned what, and in what order.
That is exactly what the unpruned Progress blocks still hold, which is why T3 chose not to prune them.

## Whether the backlog can recur

It cannot recur for the same reason, because the destination now exists.
It can recur for the forward reason T2 identified and T3 fixed: writing to `Wiki/` used to *add* bytes to a session's output rather than move them — the best case in the corpus filed its findings to the wiki and still restated 83 % of the article in its own `Learned` note.
The one-line `## Progress` rule is what stops that, and it holds only as long as the line stays a pointer rather than a précis.

## See also

- [Progress vs Wiki](ProgressWikiSplit.md) — the measurement that identified this backlog and priced it
- [Item File Format](ItemFileFormat.md) — the pruning decision that set this pass's terms
- [MathNotebook](../Resources/MathNotebook.md), [MarkdownToNotebook](../Resources/MarkdownToNotebook.md), [PureMath](../Resources/PureMath.md), [Paclet Documentation](PacletDocumentation.md) — the four destinations
