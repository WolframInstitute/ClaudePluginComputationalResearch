# Generated Preamble Audit

*[ LLM Generated ]*

What the `CLAUDE.md` this plugin *generates* costs every session of every scaffolded project.
Measured 2026-07-28 for `EvaluateWorkItemsEfficiency` T9, applying the must-be-resident test of [Preamble audit](PreambleAudit.md) to `skills/new-project/assets/` rather than to this repo's own `CLAUDE.md`.

T6 audited the plugin's `CLAUDE.md` and left this explicitly open: `new-project` appends `code_style_template.md` to `claude_template.md` (or `math_claude_template.md`), producing 10.5 kB or 12.6 kB auto-loaded into every downstream session, "two thirds of it the code-style block", and it had never been put to the test.
This is that audit.

## The headline: it does not have T6's defect

| | standard | math-research |
|---|---:|---:|
| policy | **82.9 %** | **81.8 %** |
| reference | 9.2 % | 8.0 % |
| inventory | 7.5 % | 9.9 % |
| title | 0.4 % | 0.3 % |
| total | 10,529 B | 12,572 B |

Against 46.9 % inventory in the pre-split plugin `CLAUDE.md`, the generated file was already 82 % policy.
The suspicion T6 recorded — that the code-style block is two thirds of the file and therefore the obvious cut — **does not survive the test it was to be judged by**.
All 7,247 B of `code_style_template.md` classify as policy, and not by a generous reading: a session about to write Wolfram code has no prompt to go looking for a style guide, and a style violation is invisible afterwards because the code works.
That is the same argument that kept the 1.5 kB Wolfram kernel policy resident in T6, applied to a block five times the size.

Size is not the test.
Being the largest block made the code-style template the natural suspect and it is simply not the defect; the defects are in the small sections.

## Three real findings, all in the remaining 18 %

**`## Work` was a third copy.** 607 B (standard) / 647 B (math) restating the conventions of `Work/README.md` — which every scaffold *also* writes, from `work_readme_template.md`, 1,153 B, and which `next-session` step 1 opens by name.
Its two bullets additionally restated the `work` and `next-session` slash commands, whose full `description:` frontmatter the harness injects unconditionally.
Exactly T6's Skills-table shape: a lossy copy, paid every turn, of something already in context by another route.
One sentence in it was neither — *durable knowledge goes in `Wiki/`, plans and progress go in `Work/`* — and that sentence is genuine policy, because a session that does not know the split writes its findings into the wrong file without ever asking.
Cut to that sentence plus a pointer: 206 B / 279 B.

**The math template reproduced the Skills table in miniature.** `## Skills tuned for this project type`, 490 B, listing six skills whose descriptions the harness already injects as 9,613 B across 21 skills.
Two of the six (`search-math`, `lean`) already name math-research in their own descriptions, so the curation added little that was not derivable.
Deleted, not moved — the same call T6 made — with the one non-derivable fact (that `new-notebook` has a `theorem-proof` template type) folded into `## Working style`, which is resident policy anyway.

**Two auto-loaded files gave contradictory instructions.** This is the finding worth the task.
The user's global `~/.claude/CLAUDE.md` says *"Concise code, no comments or docstrings unless explicitly requested."*
`code_style_template.md` § *Comments* says *"One-line mathematical summary per exported symbol … That is the only comment most functions need."*
Both load automatically in every scaffolded project on this machine, one forbidding what the other mandates, with no stated precedence.

A duplicate wastes bytes; a contradiction makes behaviour a coin flip, and the losing outcome is silent either way — either exported symbols go undocumented or the global rule is quietly ignored.
Resolved in the template rather than the global file: the project-scoped rule is the more specific and more considered one, and it now says so explicitly, naming the narration-style comments as what the global default is actually aimed at.
`measure_generated_preamble.py` asserts all three probes, so removing the precedence clause fails the script.

## What the overlap with the global file does *not* justify

Four of `## Code style`'s bullets restate global rules in substance — no defensive programming, main-functions-first, functional style, `{x} |-> ...` over `Function`.
On this machine that is duplication of the same kind T6 found in `## Plugin Maintenance`, where the fix was to shrink to a pointer.

Here it is not, and the difference matters: `~/.claude/CLAUDE.md` is one user's private file.
The plugin cannot read it, cannot assume it exists, and scaffolds repos for machines that have no such file.
Deleting the bullets would make the template correct on this machine and lossy everywhere else.
The overlap is the price of the template being self-contained; the *contradiction* is a bug regardless of who else has a global file, which is why one was fixed and the other left alone.

## After

| | before | after |
|---|---:|---:|
| standard `CLAUDE.md` | 10,529 B (82.9 % policy) | 10,299 B (**88.4 %** policy) |
| math-research `CLAUDE.md` | 12,572 B (81.8 % policy) | 11,990 B (**90.4 %** policy) |
| reference share | 9.2 % / 8.0 % | 3.5 % / 3.0 % |

The byte saving is small — 230 B and 582 B — and saying otherwise would misreport it.
What moved is the composition: reference is down to ~3 %, and what remains is the 358 B `## Loading code` block, kept because the `{{CODE_DIR}}` substitution makes it project-specific and getting a `Get` path wrong costs a round trip.
`## Code structure` / `## Directory layout` stay classified inventory (677 B / 755 B) and stay in place: they carry the file-naming *convention* for new topic scopes, which is policy embedded in a list, and the script records that impurity rather than letting the table imply the section is pure.

## The number that puts all of this in proportion

A scaffolded project's fixed preamble, in bytes:

| | standard | math-research |
|---|---:|---:|
| generated `CLAUDE.md` | 10,298 | 11,989 |
| global `~/.claude/CLAUDE.md` | 4,922 | 4,922 |
| `Work/README.md` | 1,153 | 1,153 |
| skill `description:` frontmatter (harness-injected) | 9,613 | 9,613 |
| `next-session` + `revise` | 10,936 | 10,936 |
| **total** | **36,922** | **38,613** |

The generated `CLAUDE.md` is 28 % / 31 % of it, and the harness-injected skill descriptions — which cannot be switched off — are nearly as large as the file being audited.

And [Autonomous Pipeline](AutonomousPipeline.md#t6s-cut-barely-moved-this-number) already showed where this leads: T6's 11.6 kB cut moved the measured cold start by ~1 % (31,479 → 31,187 tokens), because that floor is dominated by MCP tool schemas.
A ~800 B cut here will not be measurable at all.

So the honest verdict on T9 is **audited, and the cuts made are about correctness rather than cost**: the contradiction was a real bug, the two duplicate sections were real instances of a rule this project had already adopted, and the code-style block — the thing the task was opened to suspect — is exonerated by the test.
Byte-trimming the generated preamble further is not worth another session.

## Caveats

**This is bytes, not tokens, and one machine's config.**
The same conversion T6 used applies: ~4 bytes per token, so the whole generated `CLAUDE.md` is ~2.6 k tokens against a ~31 k measured floor.

**The overlap and contradiction findings are machine-local.**
Both depend on `~/.claude/CLAUDE.md` existing and saying what it says today.
The script skips the overlap check when there is no global file, so it degrades to the class measurement rather than reporting a false negative — but a future edit to the global file could re-open the contradiction from the other side, and nothing detects that.

**No scaffolded project was measured in situ.**
The templates were measured, not a generated repo, so `{{PROJECT_NAME}}` / `{{CODE_DIR}}` substitution and the paclet-dev variant's inline-built `CLAUDE.md` (assembled in `scripts/scaffold-paclet-dev.sh`, not from a template) are outside the numbers.
The paclet-dev variant appends the same `code_style_template.md` and carries its own `## Other directories` inventory plus a worktree procedure — it was read and is structurally similar, but it is not in the table.

## Reproduce

```bash
python3 Wiki/Concepts/measure_generated_preamble.py           # live
python3 Wiki/Concepts/measure_generated_preamble.py --before  # as of 713177f, before S8's cuts
```

The classification is hand-encoded and asserted against the live templates, so editing a template fails the script rather than silently misaligning this article — the same discipline as `measure_preamble.py` and `audit_learned_notes.py`.
`BEFORE_OVERRIDE` records the two headings whose class S8 changed, so the before/after tables are not comparing a cut against a reclassification without saying so.

## See also

- [Preamble audit](PreambleAudit.md) — the same test applied to the plugin's own `CLAUDE.md`, which left this task open
- [Autonomous Pipeline](AutonomousPipeline.md) — the token floor that bounds what any preamble cut can buy
- [Session Information Budget](SessionInformationBudget.md) — the measurement that made the preamble the thing to audit
- `skills/new-project/assets/` — the three templates measured here
