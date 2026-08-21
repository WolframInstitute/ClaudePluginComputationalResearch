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

## What T2 found by building one

T1 ruled on design grounds with no observations at all (§ *the data point that never arrived*).
T2 built the missing document — `NotebooksLLM/SidonBound.md`, a short paper on Sidon sets in $\mathbb{Z}_n$ carrying one theorem proved by counting differences, one attainment proposition whose negative half is a finite enumeration, a *Ruliology* table, one `Question`, and **three items below the settled tier**: a hedged claim quantified over all $k$ with evidence to $k = 7$, a dead route via Mian–Chowla prefixes, and Singer's theorem cited from memory as an unresolved `[lookup]`.

The rule survived the exercise; its **placement, its form and its unattended channel did not**.
All three faults are invisible from the design side, which is the argument for building a document rather than reasoning about one.

### The ruling sat at the wrong step

`research-notebook` step 8 handed cut material to the journal *after* steps 4–7 — convert, evaluate, deploy, link from the README.
Option 2 rewrites the source, so a ruling taken at step 8 arrives after the document it changes has been published.
The prompt now fires at the tier sort, step 2, where the cut is actually made, and step 8 only carries out a ruling already taken.

### "Marked" named no marker

Option 2 said *keep this material in the paper, marked* and stopped there.
With no form fixed, retained material is indistinguishable from paper content, and no later pass — human or generator — can find it to move it once a journal exists.
Worse, each of the three items is a thing the guide bans outright: the checklist forbids hedges and verification ranges in the body, and § *Citations* says `[lookup]` must not survive into a finished paper.
So option 2, taken literally, put the document in breach of two other rules.

The form is now fixed and the exemption is explicit: one terminal section before *Initialization*, one `Remark` per item opening with the literal `[ Retained — no journal ]`, and a first sentence saying the block is not paper content and is removable in one pass.
It is the only section the guide prescribes, on the grounds that it is build metadata rather than mathematics — written in order to be deleted.

### The unattended channel did not exist

*Retain and report in the run digest* was unimplementable, not merely vague.
`scripts/auto-run.sh` writes the digest entirely from driver-side state: `LOG_LINES` that only the driver emits, `git log`, `git diff --stat`, and the item's `## Hand-off` quoted before and after as the *Hand-off delta*.
A session has no write path into the digest at all, so the one channel from a headless session to the operator is `## Hand-off` — which is where the retained list now goes.

Verified end to end: with the list in `## Hand-off`, the driver's own digest reproduces it verbatim under *Hand-off delta*.
What has still never run is a headless session *writing* such a list — the reporting side is proved, the producing side is a trial for whichever item next builds a paper autonomously.

### Two build-path findings, incidental to the rule

- **The drift fingerprint does not see inside cell groups.** Implemented as [fingerprint.md](../../skills/research-notebook/fingerprint.md) specified it — level `{1}` — the stamp covered 38 of the document's cells and missed 11: every Example's `Input` and `Output`, folded into groups by `FoldExampleGroups`, and the whole folded *Initialization* section. The drift check reported clean because both sides used the same level, so all of the document's code sat outside drift detection and nothing said so. The spec now requires the walk to enter `CellGroupData`.
- **Initialization is last in the document and first in the build.** The Examples call functions defined in the folded *Initialization* section at the end, so the build has to evaluate that section before any Example output can be embedded. Nothing in the pipeline documentation says so, and a build that follows document order silently embeds four `$Failed`s.

### The document is kept

`ExercisePaperStyle`'s two documents were deleted once their findings were harvested, and that is precisely why T2 opened with no case to test: the only exercise built to produce marginal material had produced none, and the artifacts were gone.
`SidonBound.md` is therefore committed and kept as the standing fixture for this rule — the `.nb` beside it is generated and gitignored.

## The data point that never arrived

`ExercisePaperStyle` T1 was filed as the cheap way to see which candidate was right: build a real document and watch what it cuts.
It cut nothing — [recorded there](PaperStyleExercise.md) as *"the journal never came up: nothing in the session fell below the settled tier, so the gap did not bite"*.

So the decision was made on design grounds with zero observations, and that absence is itself the strongest argument for keeping the toggle **off** by default: turning it on would create `Journal/` in every project to serve a case that did not arise once in the only exercise built to produce it.
The same absence is why the rule's cost is bounded — a prompt that never fires costs nothing — and why T2 had to construct a document that genuinely has material to cut rather than wait for one to turn up.
It did, and § *What T2 found by building one* is what the constructed case returned.
