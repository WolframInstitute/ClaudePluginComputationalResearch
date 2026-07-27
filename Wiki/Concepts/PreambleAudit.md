# Preamble Audit

*[ LLM Generated ]*

> The cut measured here is real in bytes, but it moved the **cold-start token** cost by only ~1 % (31,479 → 31,187) — that figure is dominated by MCP tool schemas. Measured in T7: [AutonomousPipeline § T6's cut barely moved this number](AutonomousPipeline.md#t6s-cut-barely-moved-this-number).

What belongs in an auto-loaded `CLAUDE.md` and what does not.
Measured 2026-07-28 against this repo's 16.9 kB `CLAUDE.md`, for `EvaluateWorkItemsEfficiency` T6.

[Session Information Budget](SessionInformationBudget.md) established that the unconditional preamble — `CLAUDE.md` plus the loaded skill files, 27.7 kB — is the largest term in a session's bookkeeping cost, bigger than the item file in 21 of 22 measured session starts, and that 60 % of it was `CLAUDE.md`.
[Autonomous Pipeline](AutonomousPipeline.md) then measured a cold headless task at 31,479 input tokens before it reads anything of its own, which is what moved this audit ahead of implementing the pipeline.
This article is the audit of that 60 %.

## The test: what must be resident

A file loaded into every session should carry only what a session must know **before it knows to look something up**.
That gives three classes:

- **policy** — changes what a session does, and is unfindable at the point of use because nothing prompts you to look. A session that does not know kernels consume license seats does not go looking for a kernel policy; it just spawns `wolframscript` and gets a license error.
- **reference** — needed only by the skill that uses it, and that skill *does* know to look. `new-project` knows it needs the project types.
- **inventory** — a list of what exists on disk, answerable by `ls` at the moment the question arises.

Measured against the pre-split file:

| Class | Bytes | Share |
|---|---:|---:|
| inventory | 7,921 | **46.9 %** |
| policy | 4,439 | 26.3 % |
| reference | 4,199 | 24.8 % |
| title | 348 | 2.1 % |
| total | 16,907 | |

Almost half the file was inventory, and three quarters was something other than policy.

## The inventory was a third copy

The four tables — Skills 2,450 B, Templates 2,518 B, Scripts 2,181 B, Commands 772 B.

**The Skills table was the clearest case.** The harness injects every skill's `description:` frontmatter into every session unconditionally: **9,613 B across 21 skills**, richer than the table's one-line summaries and impossible to switch off. `README.md` carries a second, human-facing copy. The `CLAUDE.md` table was a third, and the only one that was both lossy and paid for on every turn.

**The Commands table encoded a rule and two exceptions.** Every skill has a slash command of the same name; `check-env` and `load-project` are the only commands without a skill, and `revise` the only skill without a command. 772 B for one sentence.

**Scripts and Templates are `ls` plus a purpose column.** The purpose is also in the skill that calls the script, at the point where it is called.

## Maintaining a duplicate is not free, and it did not work

Of the 26 commits to `CLAUDE.md`, **18 touched an inventory table** and 4 changed table rows and nothing else.
That is the `Keeping CLAUDE.md current` rule's real cost — paid to hold a copy in sync with two others.

It still drifted.
At the last commit before this audit, the headings read `Skills (20)` and `Commands (21)` against **21 skills and 22 commands** on disk, and the Templates heading carried no count at all.
The rows themselves were complete — every skill, script, command, and template on disk had an entry — so the failure was not neglect of the table but of the count *about* the table.
A duplicate maintained by hand drifts in whichever field nobody diffs.

**One further duplication, across files rather than within one.** `## Plugin Maintenance` restated the version-bump and marketplace-sync procedure that the user's global `~/.claude/CLAUDE.md` § *Versioning & Marketplace* already states — and the global file is auto-loaded too. Two auto-loaded copies of one rule, in two repos' worth of scope.

## What was done

Inventory and reference moved to `ARCHITECTURE.md` at the repo root, read on demand — the same pay-for-what-you-read move [Item File Format](ItemFileFormat.md) made when it pushed `next-session`'s paclet-worktree procedure into a sibling file.
The Skills table was **deleted rather than moved**: the harness list and `README.md` are the two copies that survive, and `ARCHITECTURE.md` points at `README.md` instead of adding a third.
`## Plugin Maintenance` shrank to a pointer at the global rule plus the one thing the global file lacks — the marketplace re-clone command.

`CLAUDE.md` keeps five things: source formatting, the Wolfram kernel execution policy, the `Wiki/` scope rule, the blog-post handling rule, and keeping-the-docs-current.

| | before | after |
|---|---:|---:|
| `CLAUDE.md` | 16,906 B | 5,254 B (−69 %) |
| fixed preamble (`CLAUDE.md` + `next-session` + `revise` + `Work/README.md`) | 27,934 B | 16,319 B (**−42 %**) |
| `ARCHITECTURE.md`, read on demand | — | 9,896 B |

The 1,546 B kernel policy is now the largest surviving block, and most sessions never spawn a kernel.
It was kept deliberately: a license error is unfindable after the fact, and the section is what tells a session the MCP-first rule exists at all.

## Caveats

**This is a byte measurement of one repo's config, not a token measurement of a session.**
The token figures it is reasoned against (31,479 for a cold headless task) come from [Autonomous Pipeline](AutonomousPipeline.md) and include MCP tool schemas for every server on this machine.
Bytes removed from `CLAUDE.md` convert to tokens at roughly 4:1, so the ~11.7 kB cut is on the order of 3 k tokens per cold task — real against a 31.5 k floor, and not the whole floor.

**A move only pays if the destination stays unread.**
`ARCHITECTURE.md` costs 9,896 B to any session that opens it, more than the tables cost before, since it now also carries the reference sections.
The bet is that the sessions needing it — `new-project`, the paclet skills, adding a skill — are a minority. If that turns out false, the tables should be split per-consumer rather than pulled back into `CLAUDE.md`.

**Scaffolded projects were not audited, and are not obviously fine.**
`new-project` generates a project `CLAUDE.md` by appending `code_style_template.md` (7,247 B) to `claude_template.md` (3,280 B) or `math_claude_template.md` (5,323 B) — **10.5 kB or 12.6 kB auto-loaded into every session of every downstream project**, two thirds of it the code-style block.
It carries no inventory tables, so it does not have *this* defect, but it has never been put to the must-be-resident test.
That is left as a separate task.

## Reproduce

```bash
python3 Wiki/Concepts/measure_preamble.py
```

Regenerates every number above.
The section classification is hand-encoded in the script and asserted against the pre-split blob, so an edit to `CLAUDE.md` fails the script rather than silently misaligning the table — the same discipline `audit_learned_notes.py` uses.

## See also

- [Session Information Budget](SessionInformationBudget.md) — the measurement that identified the preamble as the largest term
- [Autonomous Pipeline](AutonomousPipeline.md) — the 31.5 k-token cold start this audit serves
- [Item File Format](ItemFileFormat.md) — the same read-on-demand move applied to the item file and `next-session`
- `ARCHITECTURE.md` — where the inventory now lives
