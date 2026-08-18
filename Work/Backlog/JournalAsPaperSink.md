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
- Whatever is decided, `style.md`, `journal/SKILL.md` and `research-notebook/SKILL.md` step 8 must agree — they currently describe the on case well and the off case in one parenthesis.
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

- [ ] T1 — decide between the three candidates with the operator, then make the three files agree.
- [ ] T2 — exercise the chosen path: build a paper with the journal off and confirm nothing is silently lost.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Best read alongside [ExercisePaperStyle](ExercisePaperStyle.md) — T1 of that item will produce the first real document that has material to cut, which is the cheapest way to see which candidate is right.

## Decisions

| Date | Decision | Rationale |
|---|---|---|

## Progress

- **S0** 2026-08-18 — item filed out of the 4.13.0 session; the gap was introduced by the tier design and noticed while writing it up.
