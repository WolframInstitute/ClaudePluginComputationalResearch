# The headless model and effort surface

*[ LLM Generated ]*

What `claude -p` actually does with `--model` and `--effort`, measured rather than assumed, for `ModelRouting` T1 (2026-08-19).
The item's Spec had guessed at three things — whether effort is controllable headless, what the output JSON says about the model used, and whether a bad annotation fails closed.
All three are now measured, and two of the three guesses were wrong.

Measured on this machine against `claude` **2.1.235**.
The `claude -p` properties in [the pipeline article](AutonomousPipeline.md#measured-properties-of-claude--p-this-machine-claude-21220) were taken on 2.1.220 and are not re-measured here; nothing below contradicts them.
Probes ran with `--strict-mcp-config` from an empty temp directory, so the preamble is the CLI's own and not this repo's — the figures below are about routing, not about cold-start cost.

## `--model` takes aliases, and all four tiers resolve

`--help` documents the flag as taking "an alias for the latest model (e.g. 'fable', 'opus', or 'sonnet') or a model's full name".
It names three by example; **`haiku` works too**, so the Spec's four-alias grammar is valid as written.

| requested | reported id | `canonicalModel` | `contextWindow` |
|---|---|---|---|
| *(no flag — machine default)* | `claude-opus-5[1m]` | `claude-opus-5` | 1,000,000 |
| `haiku` | `claude-haiku-4-5-20251001` | `claude-haiku-4-5` | 200,000 |
| `sonnet` | `claude-sonnet-5` | `claude-sonnet-5` | 1,000,000 |
| `opus` | `claude-opus-5` | `claude-opus-5` | 1,000,000 |
| `fable` | `claude-fable-5` | `claude-fable-5` | 1,000,000 |

Three things in that table matter to the driver.

**`haiku` is the concrete case for the alias rule.** It is the one tier whose resolved id is dated — `claude-haiku-4-5-20251001` — so an annotation written with an id rather than an alias would pin a release date in a Spec that outlives it. The Decisions table's alias rule was written on general grounds; this is the instance.

**Passing the alias does not cost the large context window.** The machine default reports `claude-opus-5[1m]` and `--model opus` reports plain `claude-opus-5`, and *both* report a 1,000,000-token window. The differing id strings are not a differing capability, so a driver that compares id strings across annotated and unannotated runs will see a difference that is not there.

**An unannotated task inherits whatever the operator last set with `/model`.** With no flag the run resolved to the machine's saved default. That is the waste the Spec named, confirmed: the tier a headless task runs on is currently a side effect of the last interactive `/model` the human typed, which is not a property of the task at all.

## An unrecognized model fails closed, for free — and the existing driver already catches it

`--model bogus-not-a-model`:

| field | value |
|---|---|
| exit status | `1` |
| `is_error` | `true` |
| `terminal_reason` | `api_error` |
| `api_error_status` | `404` |
| `stop_reason` | `stop_sequence` |
| `total_cost_usd` | `0` |
| `modelUsage` | `{}` |
| stderr | `[claude-code:unrecognized_model] {"model":"bogus-not-a-model","query_source":"sdk"}` |

The driver's [condition 3](AutonomousPipeline.md#stop-conditions--any-one-halts-the-run) tests `is_error`, `stop_reason != end_turn`, and a non-zero exit, so a typo'd model alias trips it three times over and costs nothing.
**No new stop condition is needed for a bad model**, which is the cheapest possible answer to the Spec's fail-closed requirement — for the model half of the annotation.

`subtype` was nevertheless `"success"` on this failure.
That is a third independent confirmation, after the supervised and failure trials, that the CLI's own verdict field carries no information about whether anything worked.

## Effort is controllable headless, and the answer is *both* a flag and a settings key

The Spec's question was "flag / settings file / not at all".
The answer is the first two.

- **The flag is `--effort <low|medium|high|xhigh|max>`** — exactly the five levels the Spec's grammar had proposed, and it is accepted with `-p`.
- **The settings key is `effortLevel`**, not `effort`. `--settings '{"effort":"max"}'` is accepted and silently ignored, which is the documented `-p` behaviour for settings that fail validation. This machine's `~/.claude/settings.json` already carries `effortLevel: xhigh`.

### It bites, and the evidence is the answer and not the token count

Same prompt, `--model sonnet`, three runs per level.
The prompt asks for two intermediate results and their sum (`7^11 mod 1000` = 743, derangements of 7 = 1854, total **2597**) and for the integer alone.

| `--effort` | thinking tokens | correct answers |
|---|---|---|
| `low` | 0, 127, 0 | **1 of 3** — two runs answered 2197, or stopped at the first term |
| `max` | 873, 819, 1115 | **3 of 3** |

So effort is not a cosmetic setting to be filled in for tidiness.
At `low`, sonnet got a two-step arithmetic question wrong more often than right.
That is the strongest argument the item has for routing being worth the machinery at all, and it cuts against cheap routing as much as for it: a task routed to a low tier to save money can return a wrong answer at full confidence, and the driver has no way to notice.

### An invalid effort fails **open** — the exact opposite of an invalid model

`--effort bogus`:

| field | value |
|---|---|
| exit status | `0` |
| `is_error` | `false` |
| the run | proceeds, at default effort |
| stderr | `Warning: Unknown --effort value 'bogus' — ignoring it and using the default effort. Valid values: low, medium, high, xhigh, max.` |

This is the finding that changes the design.
The Spec's fail-closed requirement can be **delegated to the CLI for the model and must be implemented in the parser for the effort**: a typo'd effort produces a clean, successful, correctly-committed task that silently ran at the wrong tier, and the only trace is a warning line on a stderr stream the driver captures but does not inspect for warnings.
The annotation parser must validate the five levels itself, before spawning.

### Effort is not reported anywhere in the output

There is no effort field among the run JSON's 22 top-level keys, and `--debug-file` writes ~47 kB of log with no API request body in it.
Thinking-token counts cannot recover it either — within a single condition they ranged 0 to 185 across repeats, and a run with no flag at all produced 74 and 172 on two attempts.

The consequence for T3: **a digest can name the effort requested, never the effort used.**
The Spec's line that "the digest's per-task table names the model used" is achievable for the model and not for the effort, and the table should say *requested* for the latter rather than implying an observation.
It does — the driver's verdict lines read `effort \`high\` requested` since T3 (2026-08-20).

## The `modelUsage` trap: almost every run reports a second model

A `claude-haiku-4-5-20251001` entry appears alongside the main model in every run measured, carrying ~900 input tokens, **zero** cache tokens, and about $0.0009.
It is an auxiliary call, not the task's model.
Under `--model haiku` it does not appear separately — it merges into the single haiku entry, which then carries the main model's cache figures.

So `modelUsage | keys` is **not** the model the task ran on, and `keys[0]` is frequently the auxiliary haiku.
The discriminator that held across all five runs measured:

> The task's model is the `modelUsage` entry with non-zero cache tokens (`cacheReadInputTokens + cacheCreationInputTokens > 0`); the auxiliary entry always has both at zero.
> When there is exactly one entry, it is the task's model.

This composes with, rather than contradicts, the driver's existing rule to read `.usage` alone for the numbers.
`scripts/auto-run.sh:311` already carries the comment explaining why a recursive sum over `.modelUsage` double-counts every figure.
T3 therefore reads `.modelUsage` for the **name** and continues to take the **numbers** from `.usage` — two fields, two purposes, and the existing comment stays true.
That is what shipped: the driver selects the entry with non-zero cache tokens, falls through to the single entry when there is only one, and prints `?` rather than guessing when neither holds.

## Two adjacent flags found while measuring

Neither is what the item needs, and both are close enough to be mistaken for it.

**`--fallback-model <list>`** (only with `--print`) fails over when the primary is overloaded or unavailable, re-trying the primary at the start of each user turn.
It fires on *API availability*, not on a task halting, so it is not the Spec's escalation-on-halt.
It is worth knowing it exists, because a sonnet-routed run that dies on overload currently halts the whole loop.

**`--max-budget-usd <amount>`** (only with `--print`) is a hard per-process dollar ceiling.
The driver implements its own `--max-cost` cap across tasks, which the supervised trial found to be [the binding constraint on a default run](AutonomousPipeline.md#the-supervised-trial--what-two-real-runs-cost-and-changed).
A per-task ceiling scaled to the routed tier was not available when that cap was written, and a cheap tier with an expensive ceiling is a routing decision that goes unenforced without it.

## What this does not settle

- **Whether `effortLevel` in the user's settings is inherited headless is unresolved.** The only instrument available is the thinking-token count, and it is too noisy to answer: with no flag the same prompt produced 0, 74, and 172 thinking tokens on three attempts. It matters, because if it *is* inherited then every unannotated autonomous task on this machine has been running at `xhigh`, and the annotation must set effort explicitly rather than relying on a default. Settling it needs an instrument that observes the request rather than the response.
- **Nothing was measured on a real task.** All figures come from one-turn probes on trivial prompts in an empty directory. What a *routed* task costs, and whether sonnet can actually close a mechanical `next-session` task, is T3's live run and not this article's.
- **The routing table itself is unmeasured.** Which tier suffices for which class of task is the item's central claim and is so far a prior, not a result. The `low`-effort arithmetic failures above are a warning that the cheap side of the table needs evidence before it is trusted.
- **`--model` was not tested against a paclet or notebook task**, where an MCP-heavy preamble and a 200,000-token window could interact — haiku's window is a fifth of the others', and this repo's cold start alone was measured at ~31 k tokens.

## See also

- [The autonomous next-session pipeline](AutonomousPipeline.md) — the loop these flags are for, its stop conditions, and the earlier `claude -p` measurements
- [The `/auto-run` operator runbook](AutoRunOperations.md) — what the operator does when a run halts
- [The work item file format](ItemFileFormat.md#the-per-task-routing-annotation) — where the per-task annotation lives, and why it has that shape
- `Work/Done/2026-08-20-ModelRouting.md` — the item this serves
- [Status](../Status.md)
