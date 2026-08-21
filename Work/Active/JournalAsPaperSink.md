# JournalAsPaperSink

*[ LLM Generated ]*

> Type: investigation
<!-- Status is the folder: Active/ Backlog/ Done/ Dropped/. Move the file to change it. -->

## Spec

Origin: falls out of the 4.13.0 tier design (2026-08-18) — not separately requested.

**The tier rules now depend on the journal existing, and the journal is off by default.**
`style.md` § *The four tiers* sends hedged claims, verification ranges, heuristics, alternate proofs, failed attempts and unresolved `[lookup]` items to the journal, and states that cutting is a transfer and never a deletion.
That promise is only kept when the toggle is on.
With it off, `research-notebook` step 8 falls back to the Wiki, which is a deduplicated encyclopedia and the wrong shape for a dated record of what did not make the paper — so the material either distorts the Wiki or is quietly dropped, which is exactly what the tier rule forbids.

Decide what the default should be, and make the promise true either way.

### Requirements

- A paper or notebook built with the journal off must still land its cut material somewhere honest, or must refuse to cut silently.
- Whatever is decided, every site carrying the promise must agree — they currently describe the on case well and the off case in one parenthesis. There are **five**, not the three first counted here: `style.md` (the tier table and the final checklist), `journal/SKILL.md`, `research-notebook/SKILL.md` (step 8, a checklist line, and the cross-skill note), and `scaffold-paper/SKILL.md` (§ *Tiers* and *Move, do not drop*), which was missed because the guide is shared by both paths while each path restates it.
- No nagging: the journal skill's own rule is to stay silent when off, and that rule stands.

### Design / API

Three candidates, in the order they currently look best:

1. **Auto-scaffold on first cut.** The first time a paper routes material below the settled tier, create `Journal/` and turn the toggle on, saying so once. Keeps the promise with no ceremony; costs the user a directory they did not ask for.
2. **Leave it off and let the paper hold the overflow** in a clearly marked terminal section. No new machinery; reintroduces some of the flooding the tiers were built to stop.
3. **Refuse to cut.** With the journal off, the material stays in the paper and the build says what would have moved. Honest, and annoying in exactly the way that gets a toggle turned on.

### Edge cases & out of scope

- Not a change to the journal's format or its exemption from the `revise` loop.
- The Wiki's role is not in question: settled facts belong there, and this item is about the *unsettled* ones.

## Tasks

- [ ] T2 — exercise the chosen path: build a paper with the journal off and confirm nothing is silently lost.

### Done

- [x] T1 (S1) — decide between the three candidates with the operator, then make the three files agree.

## Hand-off

T1 is settled and the five sites agree; T2 is the whole remainder.

The blocker T2 has to solve first: **there is no document that cuts anything.**
`ExercisePaperStyle` was supposed to supply one and produced zero material below the settled tier, and its two documents have since been deleted, so T2 must *construct* a case rather than find one — a short paper carrying, say, a hedged claim and one failed attempt, built with the toggle off.
What it has to confirm is that the generator stops and lists them, and that no path through it deletes anything without a ruling.

Second thing to check, and it is the one most likely to be wrong: the unattended half.
Nothing has ever exercised retain-and-report, and the digest side of it is asserted rather than tested — `/auto-run` writes the digest, so verifying it means an autonomous run over an item that cuts, not an interactive one.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-21 | With the journal off, refuse to cut *silently*: stop, list what has no home, and let the operator turn the journal on, keep it marked in the paper, or drop it explicitly. Unattended, retain and report in the run digest. | Each filed candidate broke a rule the plugin already had — auto-scaffolding overrides the explicit *no* `new-project` invites, and both overflow variants put hedges in the user-owned deliverable that `style.md` marks *never*. Narrowing candidate 3 so the generator asks instead of deciding keeps its honesty and drops the flooding. [Rationale](../../Wiki/Concepts/CutWithNoJournal.md) |
| 2026-08-21 | The toggle stays **off** by default | Turning it on would create `Journal/` in every project to serve a case that did not arise once in the only exercise built to produce it |

## Progress

- **S0** 2026-08-18 — item filed out of the 4.13.0 session; the gap was introduced by the tier design and noticed while writing it up.
- **S1** 2026-08-21 T1 — ruled on the three candidates and made all five sites agree, the rule written once and linked four times. → [why, and why the other three lost](../../Wiki/Concepts/CutWithNoJournal.md)
