# Session Information Budget

*[ LLM Generated ]*

What one `next-session` run must read before it can do useful work, and what it writes so the next run can start cold.
Measured 2026-07-27 from git history over the six items in `Work/Done/`, for `EvaluateWorkItemsEfficiency` T1.

## Scope limit — read this first

This measures the **bookkeeping** budget only: `CLAUDE.md`, the skill files, `Work/README.md`, and the item file.
It does **not** measure the task-specific reading a session does to actually do its task — the skill sources it edits, paclet code, notebook output, MCP results.
On the sessions that shipped code (`f2c5aaa`, `4d53ee9`) that unmeasured term is plausibly larger than everything below.
So the numbers here bound the *overhead*, not the session.
Any claim of the form "a session costs X" does not follow from this article.

## The two terms that dominate

**1. Fixed overhead, paid every session before the item file is opened — 27.7 kB.**

| File | Bytes | Why it is read |
|---|---|---|
| `CLAUDE.md` | 16,650 | auto-loaded into context |
| `skills/next-session/SKILL.md` | 6,096 | the command loads it |
| `skills/revise/SKILL.md` | 3,216 | step 0 instructs reading it |
| `Work/README.md` | 1,709 | step 1 locates the item through it |
| **total** | **27,671** | |

**2. The item file, which grows linearly in session count.**

`## Progress` gains a near-constant 3.4–4.5 kB per session across every multi-session item, so the file grows linearly and so does the cost of starting session *N*.

| Item | Progress bytes added per session | mean |
|---|---|---|
| `AdoptMarkdownToNotebook` | 1962, 3151, 5078, 5791, 5644 | 4,325 |
| `MathNotebookIntegration` | 6694, 3260, 3299, 3052, 4001, 4795 | 4,183 |
| `PacletDocumentation` | 9278, 2340, 2802, 4194, 4049 | 4,532 |
| `EvaluateMarkdownToNotebook` | 4155, 3912, 4868, 574 | 3,377 |

At close, `## Progress` is 50 % / 56 % / 73 % / 78 % of those four files.

**The fixed term is the bigger one.**
Across the 22 measured session-start file states, the item file ran 2.4–34.0 kB with a median of 15.4 kB.
In **21 of 22** it was *smaller* than the 27.7 kB fixed overhead.
`CLAUDE.md` alone (16.6 kB, 60 % of the fixed term) outweighed the item file in 12 of 22.
Discussion of this system has been about item-file bloat; the measurement says the skill-and-config preamble is the larger line.

## The partial-read rule saves 22 %, and nothing at all early

`next-session` step 2 says: full Spec and Tasks, only the **tail** of Progress.
Applying that rule to each measured state, against reading the file whole:

| State entering | file | rule + Decisions | avoided |
|---|---|---|---|
| commits 1–3 of every item | — | — | **0 %** |
| `MathNotebookIntegration` last 3 | 19.5 / 22.6 / 26.6 kB | 12.8 / 12.6 / 13.3 kB | 34 / 44 / 50 % |
| `PacletDocumentation` last 3 | 19.1 / 22.5 / 27.0 kB | 11.7 / 12.7 / 14.7 kB | 39 / 43 / 46 % |
| `AdoptMarkdownToNotebook` last 2 | 21.6 / 34.0 kB | 19.6 / 28.9 kB | 9 / 15 % |
| all 22 states | 331.1 kB | 258.6 kB | **22 %** |

Zero early because a tail-of-two covers *all* of Progress while there are ≤ 2 blocks — the rule cannot bite until session 4.
It then reaches 34–50 %, but only on the item files that were already the smaller term.
22 % of a median 15.4 kB is ~3.4 kB saved against a 27.7 kB floor: **the rule is a 7 % optimisation of the bookkeeping budget.**

## Three gaps in the rule as written

**`## Decisions` is not mentioned at all.**
It is unbounded and it grew every item: 60 → 7,424 B (`AdoptMarkdownToNotebook`), 60 → 1,705 (`PacletDocumentation`), 60 → 1,651 (`MathNotebookIntegration`), 60 → 728 (`EvaluateMarkdownToNotebook`).
A session either reads it (uncosted) or skips it (and re-litigates settled decisions).

**`## Spec` is mandated as a full read but is not static.**
On `AdoptMarkdownToNotebook` it grew 4,389 → 13,102 B, 3.0×, mostly self-inflicted mid-item amendment in its own T4/T5 sessions.
The one section the rule insists on reading whole is a growth channel.
On the other five items Spec was near-constant, so this is one item's failure mode, not a universal one — but nothing in the format prevents it.

**A tail read costs an extra round-trip and no recipe is given.**
`Read` takes `offset`/`limit`, so the tail *is* reachable — but only after a `grep` for the last `### Session` heading.
Step 2 does not say to do that, so the cheap path is to read the file whole, which is what this session did.

## Where the durable output actually went

`EvaluateMarkdownToNotebook` added **0–1 lines outside `Work/`** in all four of its sessions: its entire output was Progress prose.
That is legitimate for an `investigation` item — but it means the knowledge landed in the one section the next session is told to skim.
Progress is simultaneously the item's output channel and its least-read input.
Measured inertness at the final session (everything but preamble, Spec, Tasks, Decisions, and the last Progress block):

| Item | file at last session | live | inert |
|---|---|---|---|
| `MathNotebookIntegration` | 26.6 kB | 10.3 kB | **61 %** |
| `PacletDocumentation` | 27.0 kB | 11.9 kB | **56 %** |
| `EvaluateMarkdownToNotebook` | 17.4 kB | 9.3 kB | **47 %** |
| `AdoptMarkdownToNotebook` | 34.0 kB | 23.8 kB | 30 % |
| `MarketplaceReadme` | 2.4 kB | 1.8 kB | 26 % |
| `DeclutterReadme` | 5.8 kB | 5.7 kB | 0 % |

Quantifying which of those inert bytes are durable facts that belong in `Wiki/` is T2's job; T1 only establishes that the majority of a mature item file is inert at the moment it is read.

## Item files are edited by sessions belonging to other items

The commit-to-session mapping is not 1:1.
`14c8981` created four item files at once; `9fe8ba6` and `6c1502c` were `PacletDocumentation` sessions that also amended `AdoptMarkdownToNotebook`'s Spec and Tasks (+210 B).
So "one session, one item" holds for *work* but not for *edits*, and per-session accounting derived from git needs this caveat.
It also means an autonomous loop cannot assume an item file only changes when that item is worked.

## What T1 concludes

The per-task information budget is real and it is bad, but not where the Spec guessed.
Ranked by bytes:

1. **`CLAUDE.md` + skill preamble, 27.7 kB, paid unconditionally, never pruned** — the largest single lever, and untouched by anything in `next-session`.
2. **Linear Progress growth, ~4.3 kB/session** — the term the partial-read rule targets, worth 22 % of a smaller number.
3. **Uncosted `Decisions` and amendable `Spec`** — small today, unbounded by construction.

This does not yet say the split between `Work/` and `Wiki/` is wrong (T2) or what the format should be (T3).
It does say that any redesign confined to the item file is optimising the second-largest term.

## Reproduce

`Wiki/Concepts/measure_session_budget.py` regenerates every number above from git history:

```bash
python3 Wiki/Concepts/measure_session_budget.py
```

One gotcha cost real time: `git log --follow --reverse` silently collapses to a **single** commit, because `--follow` needs the reverse-chronological walk to track the rename.
Use `--follow` without `--reverse` and reverse the list afterwards.
Items are renamed on close (`Work/Active/<Name>.md` → `Work/Done/YYYY-MM-DD-<Name>.md`), so path resolution must try `Done/`, `Active/`, and `Backlog/` at each commit.

## See also

- [Work/README.md](../../Work/README.md) — the folder-is-status convention and the active index
- `Work/Active/EvaluateWorkItemsEfficiency.md` — the item this measurement serves
- [Status](../Status.md)
