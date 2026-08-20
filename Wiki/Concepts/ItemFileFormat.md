# The work item file format

*[ LLM Generated ]*

The target shape of a `Work/` item file — what each section is for, what may be written where, and why.
Decided 2026-07-27 for `EvaluateWorkItemsEfficiency` T3, from [T1's budget](SessionInformationBudget.md) and [T2's split](ProgressWikiSplit.md).
The normative rules are in [`work`](../../skills/work/SKILL.md) and [`next-session`](../../skills/next-session/SKILL.md); this article carries the rationale, deliberately, because those two files are read unconditionally and this one is read on demand.

## The format

Sections in read order, with `## Progress` last because nothing reads it:

| section | grows with sessions? | how it changes |
|---|---|---|
| `## Spec` | no — it is a contract | **corrected in place**; never appended to |
| `## Tasks` | no — boxes move to `### Done` | checked off |
| `## Hand-off` | no — one block | **overwritten** every session |
| `## Decisions` | one row per real choice | a reversal **edits** the row it reverses |
| `## Progress` | one **line** per session | append-only, never revised, never read |

`## Hand-off` is new and `## Progress` is what changed: from a 3.4–4.5 kB/session block of prose to a single line.
These five are the whole file — see [the section list is closed](#the-section-list-is-closed).

## The one-destination rule

Every fact a session establishes is written **exactly once**:

| the fact is… | it goes to | and it is |
|---|---|---|
| true regardless of which task ran — about a tool, an artifact, or this plugin | a `Wiki/` article | corrected in place when it changes |
| a choice between real alternatives | one `## Decisions` row | edited when reversed |
| the Spec being wrong | the Spec sentence itself | replaced |
| what the next session must know and is not yet true anywhere else | `## Hand-off` | overwritten next session |
| that the session happened | one `## Progress` line | left alone |

Filing a fact in `Wiki/` **discharges** the obligation to state it in Progress.
The Progress line links it.

This is the answer to T2's question — what makes a Progress entry a pointer rather than a précis.
Not a style guideline: a one-line entry *cannot* be a précis.
T2 found that the three sessions which did file to `Wiki/` re-narrated 33 % and 83 % of what they had just filed, so an instruction to "write pointers" was already available and already ignored.
The line limit is the enforcement.

## The per-task routing annotation

A task box may name the model tier and the reasoning effort that task wants:

```text
- [ ] T3 (model: sonnet, effort: high — ~90 % mechanical) — sweep the renames through `Tools.wl`.
```

Added 2026-08-20 for [`ModelRouting`](../../Work/Active/ModelRouting.md) T2, from a hand convention that had already run once in another repo.
It is a contract about **price**, written in the file where the work was divided: the human who split the Spec into sessions is the one who knows which of them needs a frontier tier, and that knowledge used to be thrown away.
An unannotated headless task runs on whatever the operator last typed at `/model` — [measured](HeadlessModelSurface.md#--model-takes-aliases-and-all-four-tiers-resolve) — which is not a property of the task at all.

The normative grammar is in [`work` § *The routing annotation*](../../skills/work/SKILL.md#the-routing-annotation).
What follows is why it has that shape.

### The grammar, and what each part of it defends against

```text
annotation := "(" [ "model:" alias ] [ "," ] [ "effort:" level ] [ "—" reason ] ")"
alias      := haiku | sonnet | opus | fable
level      := low | medium | high | xhigh | max
```

It sits immediately after the task id, before the em dash that opens the body, with `model` first when both fields are present — one fixed order, so a reader and a `sed` see the same thing.

- **Aliases, never dated ids.** `haiku` is the instance that makes the rule concrete: it resolves to `claude-haiku-4-5-20251001`, so an id written into a Spec pins a release date the Spec outlives. The other three currently resolve to undated ids, which is exactly why the rule could not have been inferred from them.
- **The anchoring is load-bearing, not aesthetic.** Extracted as the first `([^)]*)` group after the task id, the annotation cannot be widened by a `)` in the body, and an `effort:` mentioned in the body's prose is not mistaken for a field. Anchored anywhere else, or matched greedily, both happen.
- **The reason is inside the parens, not a comment beside them.** A tier with no reason is a price nobody can audit; the annotation doubles as the documentation of why the task is routed where it is.
- **The five effort levels are the CLI's own** — `low`, `medium`, `high`, `xhigh`, `max` — so the annotation is passed through rather than translated.
- **The parser must validate the effort, and need not validate the model.** The two halves fail in opposite directions: an unrecognised model exits 1 with `is_error` at zero cost, tripping the driver's existing stop condition, while an unrecognised effort *succeeds* at default effort and warns only on stderr. The fail-closed check therefore exists for the effort field's sake; the model field gets its check for free.
- **A comparison is between tiers, never between id strings.** The machine default reports `claude-opus-5[1m]` and `--model opus` reports `claude-opus-5`, and both report a 1,000,000-token window: a session that string-compared its own model against `opus` would see a mismatch that is not there.

### What the parser settled that the grammar had left open

Written for T2, implemented in `scripts/auto-run.sh` for T3 (2026-08-20), which had to decide two cases the grammar above does not name.

**A paren group carrying no `key:` is not an annotation.**
`(human)` and the `(S2)` of a closed box sit in the same anchored position, and the parse leaves them alone rather than treating them as malformed routing.
The converse is the fail-closed half: a group that *does* carry a `key:` must parse completely, so `(modle: sonnet)` halts the run instead of quietly inheriting the default.

**The reason clause is dropped before the fields are read**, at the first em dash — an en dash or a spaced hyphen is accepted too, since the reason is prose and a writer will reach for whichever dash is to hand.
Without that step a reason containing a comma or a colon reads as another field and trips the fail-closed check on a correct annotation.

Both rules are covered by `scripts/test-auto-run-routing.sh`, which drives the real driver against fixture items and a stub `claude`.
The regression it exists to prevent is a widened or unanchored match — the failure the anchoring was chosen against — since nothing in the item file would show that the wrong tier had been used.

### Absent means inherit, and only half of what is inherited can be observed

An absent **model** inherits the tier the session is on — the operator's `/model` interactively, the machine default headless — and a session can read that back off its own system prompt, so the inheritance is observable.

An absent **effort** inherits something no available instrument can name.
Whether `effortLevel` in `~/.claude/settings.json` (`xhigh` on this machine) reaches a headless run is [unresolved](HeadlessModelSurface.md#what-this-does-not-settle), no output field reports the effort a run used, and thinking-token counts are far too noisy to infer it.

Hence a practical asymmetry on top of a symmetric grammar: a routed task should name **both** fields.
Not because the grammar demands it — the fields stay independent, so a task may be routed to a tier without a claim about effort — but because an inherited effort is unobservable before and after the fact, and a task silently running at `low` is the failure mode that returns a confident wrong answer.

### It must not fold into `(human)`

`(human)` gates a task against unattended runs, and the driver matches it as a **literal substring**.
Writing `(model: opus, human)` would therefore remove the gate while looking like it keeps it — a fail-open change of meaning in the one marker whose whole job is to fail closed.
The two markers stay separate groups, `(human)` first, and in practice a `(human)` task carries no routing at all: no unattended run reaches it, and the human at the keyboard picks the tier.

### The routing table is a prior, not a result

Which tier suffices for which class of task is the routing decision's central claim, and it is so far an assumption written down.
The table lives in [`work` § step 3](../../skills/work/SKILL.md#3-decompose-into-tasks), because that is where tasks are written, and it is presented with every breakdown so the human rules on it instead of inheriting it.
Two measurements touch it, and both cut against the cheap end rather than for it.
At `low` effort, sonnet answered a two-step arithmetic question wrong in two of three runs — cheap tier and cheap effort are separate decisions, and the table pairs the cheap tiers with a high effort for that reason.
And in [the routing trial](AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke), a `haiku` task at `high` effort produced its deliverable correctly for $0.07 and then failed the session protocol, while the same shape of task on `sonnet` closed cleanly for $0.64 against $1.54–$4.09 on the default tier.
So the table's middle row has support and its cheapest row has a counterexample: what a cheap tier costs is not the price of the task but the price of the task plus the chance of a halt on the bookkeeping.

### No new section, and nothing machine-only

The annotation lives inside `## Tasks`, so [the closed section list](#the-section-list-is-closed) holds.
It stays hand-writable plain markdown, like `(human)` and `> Autonomous: allowed` before it, and an item with no annotations behaves exactly as it did.

## Why Progress leaves the read path

T2 classified every claim-line of every Progress block by destination and found four classes: durable (→ `Wiki/`), decision (→ `## Decisions`), hand-off (live for exactly one session), and narration (nowhere).
If each of those has a home, **nothing a session needs is in Progress** — it is the audit surface for a human skimming what happened, and for git.

Three consequences, all subtractions:

- **The partial-read rule is deleted.** T1 measured it as a 7 % optimisation of the bookkeeping budget that saves nothing before session 4, and T2 measured what it hides: ~30 kB of durable content below the tail. A format whose read is flat in session count needs no such rule, and `next-session` step 2 loses the three gaps T1 found in it — unmentioned `## Decisions`, unbounded `## Spec`, no tail-read recipe.
- **Hand-offs stop being append-only.** A hand-off is live for one session, so it belongs in a section that is overwritten. In the old format it was the `**Next:**` line of the newest Progress block — reachable only by finding the tail, and permanent once written. T2's structural finding was that append-only prose can only accumulate contradictions; the fix is to give every corrigible thing a mutable home, and `## Hand-off` is that home for carry-forward.
- **An unattended pipeline gets a fixed place to look.** T4's loop needs to know the state of an item without a human to arbitrate between an S2 claim and its S4 reversal. `## Hand-off` is that place.

## Once Progress is out, `## Spec` and `## Decisions` *are* the read path

This is the part T1 and T2 did not price, and it is where the remaining bloat turned out to be.
Section sizes at close, across the corpus:

| item | S | total | Spec | Tasks | Decisions | ad-hoc | Progress | read without Progress |
|---|---|---|---|---|---|---|---|---|
| `AdoptMarkdownToNotebook` | 5 | 42.9 kB | **13.0** | 1.0 | **7.4** | — | 21.5 | **21.4 kB** |
| `EvaluateMarkdownToNotebook` | 4 | 24.2 kB | 3.5 | 0.7 | 0.7 | **5.7** | 13.4 | 10.8 kB |
| `PacletDocumentation` | 6 | 30.9 kB | 4.8 | 1.1 | 1.7 | 0.7 | 22.5 | 8.4 kB |
| `MathNotebookIntegration` | 6 | 32.0 kB | 4.4 | 1.0 | 1.6 | — | 24.9 | 7.1 kB |
| `DeclutterReadme` | 1 | 5.7 kB | 2.9 | 0.3 | 0.6 | — | 1.9 | 3.8 kB |
| `MarketplaceReadme` | 1 | 3.9 kB | 1.4 | 0.2 | 0.5 | 0.6 | 1.2 | 2.7 kB |

Four of six land under 8.5 kB and are flat in session count — that is the format working.
The worst is 21.4 kB, of which Spec + Decisions is 20.4 kB: **95 % of its post-Progress read path is the two sections nobody had costed.**
It is also the item the Spec cited as the motivating example of item-file bloat — which turns out to have been misattributed to Progress.
Across five of the six, Spec + Decisions is 70–95 % of the post-Progress read.

So bounding those two sections is the rest of T3's job, together with the `ad-hoc` column.

### The section list is closed

Three of six items invented top-level sections the template does not have, and each is a destination violation:

| section | bytes | what it actually was |
|---|---|---|
| `## Recommendation` (`EvaluateMarkdownToNotebook`) | 5,683 | the investigation's findings — durable, so a `Wiki/` article |
| `## Blocked` (`PacletDocumentation`) | 720 | a hand-off |
| `## Plugins`, `## License` (`MarketplaceReadme`) | 576 | draft content for the artifact being written |

The 5.7 kB one matters most: it is over half that item's post-Progress read path, and it is the shape an `investigation` item naturally reaches for when it has a conclusion and no Wiki article to put it in.
T2 measured the same item as adding **0–1 lines outside `Work/`** across all four of its sessions.
So the rule is explicit: an item's conclusions go to `Wiki/`, and the item file links them.
A blocker is a hand-off.
Draft content for an artifact belongs in the artifact, or in a scratch file that is not read every session.

### The Spec is a contract, and it is edited in place

`AdoptMarkdownToNotebook`'s Spec grew 4.4 → 13.0 kB, 3.0×, in its own T4/T5 sessions (T1).
On the other five items the Spec was near-constant, so this is one failure mode rather than a universal one — but nothing in the old format prevented it, and the Spec is the one section always read whole.

- A session that finds the Spec **wrong** replaces the sentence. It does not append an amendment, a caveat, or a "note: superseded by".
- Findings never go in the Spec. They are durable (→ `Wiki/`) or they are choices (→ `## Decisions`).
- `### Requirements` is the contract to build against, not a research log.
- Past roughly one screen — call it 4 kB — a Spec is a signal the item should have been split, not a section to keep extending.

### A `## Decisions` row is earned by a choice

Rows cost a uniform 288–433 B across every item, so row *size* needs no rule.
Row *count* is the variable: 17 rows in 5 sessions on `AdoptMarkdownToNotebook` — 3.4 per session — against 0.7 per session on every other item.
Reading those 17 gives three failure modes, and they are the same defect Progress had:

1. **Reversals are appended instead of applied.** S4's row reverses S3's row and both remain, so a reader must reconstruct the order to know which won. A reversal now **edits** the row it reverses, dated to the revision; the superseded wording is in git.
2. **Spec corrections are logged as rows instead of applied to the Spec.** Three of the 17 are the Spec being wrong — "no pinnable release is dropped as a risk", "the evaluation is current, not stale", "the guide-page gap is no longer a reason to adopt". Each leaves the wrong Spec text in place plus a row contradicting it. Correct the Spec instead.
3. **Findings are logged as rows.** "Routes 1–3 rejected on measurement" carries two sentences of evidence that are durable facts about `MarkdownToNotebook`. The row keeps the choice; the rationale links the article for the evidence.

One sentence for the decision, one for the rationale, and a link where the evidence lives.

## Closed items are not pruned

T2 asked whether a closed item's Progress should be pruned once its facts are harvested.
No — and the question mostly dissolves, because a new item's Progress is one line per session and there is nothing to prune.

For the legacy blocks that T5 will harvest, pruning buys nothing that `git log -p` does not already provide, and rewriting a closed item's audit trail destroys the human-readable record at no saving to any read path: a closed item is read once more, by the harvest itself.
One exception, for honesty rather than bytes.
T2 found a sentence in `Work/Done/` that is **false today** — `research-notebook`'s sync described as `ExportString[Import[path], "Markdown"]`, replaced by one-way generation plus a fingerprint two sessions later — with no mechanism to correct it.
When a harvest pass meets a claim it now knows to be false, it appends one line under that block:

```
> Superseded: <what is true now> — see [Article](../../Wiki/...).
```

The claim stays, the reader is warned, the diff is one line.

## The format applies to the skill files too

T1's headline was that the unconditional preamble — `CLAUDE.md` plus the skill files, 27.7 kB — is a bigger term than the item file, which was smaller than it in 21 of 22 measured session starts.
Two things follow that a format decision can act on.

**Rationale goes where it is read on demand.** That is this article. `next-session/SKILL.md` states the rules and links here; it must not carry the argument for them, because the argument would be re-read every session forever.

**A skill file must not charge every session for one project type.** `next-session`'s branch/worktree/PR procedure was 2.3 kB — 38 % of the file — and applies only to `paclet-dev` repos changing a paclet submodule. It now lives in `skills/next-session/paclet-worktree.md`, referenced by one line and read only in that case. Same principle as moving durable facts out of Progress: pay for what you read.

One caveat on the 27.7 kB itself.
16.6 kB of it is *this* repo's `CLAUDE.md`, which is large because it documents the plugin's own skill/script/command tables.
A scaffolded research project gets a 3.3 kB `CLAUDE.md` (`claude_template.md`), so the portable fixed term is ~14 kB, of which the skill files are two thirds.
The skill files are therefore the part of T1's headline term that plugin changes can actually move.

## What this does not fix

- **It is a prediction, not a measurement.** The section sizes above are measured; the claim that the new format holds the read flat is arithmetic on a format that has run for zero sessions. It is re-measurable: `measure_session_budget.py` and the script below both keep working, and the first item to run four sessions in the new format settles it.
- **The row rule does not bind a decision-making task, and T3's own session proves it.** Deciding this format added four `## Decisions` rows and 1.4 kB, putting `EvaluateWorkItemsEfficiency` at 3.3 rows/session — the same rate as the item whose table the rule exists to bound. That is not a loophole being exercised: a task whose deliverable *is* a set of choices earns rows, and per-session row count was never the target. What the rule forbids is spending rows on facts, on Spec corrections, and on reversals that leave the old row standing — and at least 7 of `AdoptMarkdownToNotebook`'s 17 are one of those three.
- **The ~53 kB backlog in `Work/Done/` is untouched.** T5 owns it, and it is now sequenced correctly: the format is decided, so a harvested block does not need re-doing.
- **A one-line Progress can drop a fact.** The Spec's own risk note named the case: `AdoptMarkdownToNotebook` S5's two most useful findings — `CreateCellID` does not stamp built cells, fingerprint after the round-trip rather than in memory — are exactly what a terser format would lose. Under the one-destination rule they are durable facts about a tool and go to `Wiki/Resources/MarkdownToNotebook.md`, where anyone touching that tool finds them and where they can be corrected. The target was fewer bytes carried per fact, not fewer facts; nothing here deletes a fact, it relocates one.
- **Nothing here is machine-only.** Every section stays plain markdown, hand-writable and diff-friendly, which the Spec required because item files are user-edited.

## Migration

Items already in flight keep their existing Progress blocks — no rewrite.
The next session on such an item adds a `## Hand-off` section and writes its own Progress as one line, so the file carries both shapes for the rest of its life.
`next-session` step 2 handles that: read the whole file, and if it has multi-paragraph Progress blocks, read only the last one or two of them.

## Reproduce

The section table:

```bash
python3 Wiki/Concepts/measure_item_sections.py
```

It prints the per-section byte counts, the read path with and without `## Progress`, and the `## Decisions` row count and bytes-per-row for every item in `Work/`.

## See also

- [Session Information Budget](SessionInformationBudget.md) — T1: what a session reads, and the 27.7 kB fixed term
- [Progress vs Wiki](ProgressWikiSplit.md) — T2: what is in Progress that should not be
- [The headless model and effort surface](HeadlessModelSurface.md) — the measurements the routing annotation is built on
- `Work/Done/2026-07-28-EvaluateWorkItemsEfficiency.md` — the item this serves; T4 specifies the autonomous loop against this format
- [Status](../Status.md)
