# Cutting with no journal

*[ LLM Generated ]*

Where material below the settled tier goes when the journal — its named destination — is switched off.
Decided 2026-08-21 for [`JournalAsPaperSink`](../../Work/Active/JournalAsPaperSink.md) T1.

## The gap, and how it got there

The [four tiers](../../skills/research-notebook/style.md) route hedged assertions, verification ranges, heuristics, alternate proofs, failed attempts and unresolved `[lookup]` items to the journal, and promise that *cutting is a transfer, never a deletion*.
The journal is **off by default** and `new-project` asks about it with a default of *no*.

So the promise was conditional on a toggle most projects never set, and the tier design (4.13.0, 2026-08-18) did not notice — the gap was filed the same day it was introduced, by the session that introduced it.
One line handled the off case, `research-notebook/SKILL.md` step 8: *"(or the Wiki when the journal is off)"*.
That routes marginal material to a store `update-wiki` describes as an encyclopedia, *"not a journal"*.
A failed attempt has no honest shape as an encyclopedia article, so the fallback either distorted the Wiki or dropped the material — the one outcome the tier rule names and forbids.

## The rule: refuse to cut *silently*

With the journal off, the generator does not choose.
It stops, lists what has no home, and puts three options to the operator — turn the journal on now, keep the material in the paper marked, or drop it explicitly.

The load-bearing word is *silently*, not *refuse*.
Deletion stays available; what is removed is the generator's ability to do it unasked.
That is what makes *a transfer, never a deletion* true rather than aspirational — **silence cannot delete anything**, because silence is no longer a code path.

It costs one prompt, once per document, and only when something is actually below the settled tier.
That last clause is why the cost is near zero in practice: see *the data point that never arrived* below.

**Unattended, retain and report.**
An autonomous run has no one to ask, so the choice is fixed to the second option and the list goes in the run digest.
The operator meets it at the merge, which is where [the autonomous pipeline](AutonomousPipeline.md) already defers every other `revise` gate — so this needed no new mechanism, only a named default.
None of the three filed candidates addressed unattended mode at all.

## Why the three filed candidates were rejected

Each failed on one objection, and in each case the objection was a rule the plugin already had.

| Candidate | Objection |
|---|---|
| **Auto-scaffold on first cut** — create `Journal/` and set the toggle | `new-project` *asks* whether to keep a journal, default no. Auto-scaffolding overrides an answer the user was explicitly invited to give, and writes their `CLAUDE.md` to do it. Breaking "do not nag" is the lesser fault; flipping a user-owned toggle unprompted is the greater one. |
| **A terminal overflow section in the paper** | Puts hedges and failed attempts in the user-owned deliverable, the one destination `style.md` names with *never*. Also needs a prescribed section, against the 2026-08-18 decision that sections are not prescribed and the mathematics decides the shape. |
| **Refuse to cut** (as filed) | The material *stays in the paper*, so it floods exactly as the overflow section does, without even a section to contain it. |

The adopted rule is the third narrowed until the objection goes away: keep its honesty, drop its assumption that the generator must decide the destination itself.

## What "no nagging" survives on

`journal/SKILL.md` says that when off it must *"stay silent — do not nag the user to turn it on"*, which reads at first like a prohibition on this prompt.
It is not, and the distinction is worth keeping straight because it is the whole reason the rule is admissible.

The journal skill never speaks.
The prompt comes from the **paper generator**, which is holding material it cannot place, and it fires only when that material exists.
An offer to turn the journal on is one of three rulings on a concrete list — not advocacy for a feature.
A skill advertising itself would fire on schedule; this fires on a condition, and in most projects the condition is never met.

## The surface was four files, not three

The Spec named `style.md`, `journal/SKILL.md` and `research-notebook` step 8.
`scaffold-paper/SKILL.md` carries the same unconditional promise in two places (§ *Tiers*, and *Move, do not drop*) and was missed, because the guide is shared by both paths while each path restates it.

The rule is therefore written **once**, in `style.md` § *When the journal is off*, and the other four sites link to it rather than restating it — the same one-fact-one-destination discipline the [item file format](ItemFileFormat.md) applies to work items.
Two checklist lines that asserted *"everything cut is in the journal"* were also unconditional and now name the off case.

A fifth site was left alone deliberately: `research-notebook`'s frontmatter `description:`, which is auto-loaded into every session and where added length has [a measured cost](PreambleAudit.md).
It says marginal material goes to the journal, which is incomplete rather than wrong.

## The data point that never arrived

`ExercisePaperStyle` T1 was filed as the cheap way to see which candidate was right: build a real document and watch what it cuts.
It cut nothing — [recorded there](PaperStyleExercise.md) as *"the journal never came up: nothing in the session fell below the settled tier, so the gap did not bite"*.

So the decision was made on design grounds with zero observations, and that absence is itself the strongest argument for keeping the toggle **off** by default: turning it on would create `Journal/` in every project to serve a case that did not arise once in the only exercise built to produce it.
The same absence is why the rule's cost is bounded — a prompt that never fires costs nothing — and why T2 has to construct a document that genuinely has material to cut rather than wait for one to turn up.
