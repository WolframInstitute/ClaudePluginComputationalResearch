---
name: provenance
description: >
  Optionally record the prompts/intent behind generated artifacts — notebooks,
  paclet functions/code, wiki articles, and work items. Maintains an append-only
  ledger at Wiki/Prompts.md and embeds a back-pointer in each artifact so
  provenance travels with the file. Off by default; gated by a per-project toggle
  in CLAUDE.md. Use when the user says "track prompts", "record the prompt",
  "where did this come from", "turn provenance on/off", "show the prompt ledger",
  or the /provenance command. Other skills (new-notebook, update-wiki, work,
  next-session) follow this skill's format when the toggle is on.
---

# Prompt Provenance

Record *what was asked* to produce a generated artifact. The plugin already
records *who* generated code (git `Co-Authored-By` trailer) and *what changed*
(`Wiki/Status.md`, Work `## Progress`). Provenance fills the remaining gap: the
originating prompt/intent behind each artifact.

This mirrors the existing `## Recover` convention (see [add-resource](../add-resource/SKILL.md)):
plain markdown, git-tracked, machine-readable, no database. It is **optional** —
nothing here runs unless the project toggle is on.

## The toggle (check this first)

Provenance is opt-in per project, declared in the project's `CLAUDE.md`:

```markdown
## Provenance

Prompt tracking: **off**
<!-- When on, generated artifacts record their originating prompt/intent in
     Wiki/Prompts.md and carry an embedded back-pointer. See the `provenance` skill. -->
```

Before recording anything, check the toggle:

```bash
grep -qiE 'prompt tracking:[[:space:]]*\*{0,2}on' CLAUDE.md && echo on || echo off
```

- **off** (default, or section absent): do nothing. Never create `Wiki/Prompts.md`,
  never embed back-pointers. Stay silent — do not nag the user to turn it on.
- **on**: record provenance for each artifact you generate, per the rules below.

To flip the toggle, edit the `Prompt tracking:` line in `CLAUDE.md` (and seed
`Wiki/Prompts.md` the first time it goes on — see *Turning it on*).

## The canonical record

One small set of fields, reused in the ledger and in every embedded back-pointer:

| Field | Meaning |
|-------|---------|
| `date` | Absolute `YYYY-MM-DD` (from the current date). |
| `artifact` | Path relative to project root (`NotebooksLLM/Ricci.nb`, `Code/Curvature.wl`). |
| `intent` | One-line distilled goal. **Always present.** |
| `prompt` | Verbatim user request. Optional — include when short, or when the user asks. |
| `generator` | The skill that produced it (`new-notebook`, `update-wiki`, …). |
| `model` | Model id (e.g. `claude-opus-4-8`). |
| `source` | Notebooks only: the `NotebooksLLM/*.md` source path. |

**Fidelity:** default to a concise one-line `intent`. Add the verbatim `prompt`
when the request is short, reproducibility matters, or the user asks for it.
Do not paste long conversational text into the ledger.

## The central ledger — `Wiki/Prompts.md`

Append-only, **newest at the bottom** (matching the Work `## Progress` convention).
One `###` block per generation event:

```markdown
# Prompt Ledger

Append-only record of the prompts/intent behind generated artifacts.
Toggle in CLAUDE.md (`Prompt tracking`). See the `provenance` skill for the format.

### 2026-05-29 — NotebooksLLM/RicciCurvature.nb
- **Intent:** Explore Ollivier–Ricci curvature on graphs with pastel plots
- **Prompt:** "make a notebook about ollivier ricci curvature on graphs"
- **Generator:** new-notebook · claude-opus-4-8
- **Source:** NotebooksLLM/RicciCurvature.md
```

Omit lines that don't apply (e.g. no `Source:` for a `.wl` file; drop `Prompt:`
when you're only keeping the distilled intent). Register the ledger once in
`Wiki/Index.md` under a `## Prompts` section:

```markdown
## Prompts

- [Prompt Ledger](Prompts.md) — prompts/intent behind generated artifacts
```

## Embedded back-pointers (so provenance travels with the file)

In addition to the ledger entry, embed provenance **inside** each artifact so it
survives when the file is shared standalone.

### Notebooks

Write a leading HTML comment into the `NotebooksLLM/*.md` source. HTML comments
are dropped by the `{"Markdown","Notebook"}` importer, so they never become cells:

```markdown
<!-- provenance:
     intent: Explore Ollivier–Ricci curvature on graphs
     prompt: "make a notebook about ollivier ricci curvature on graphs"
     generator: new-notebook
     model: claude-opus-4-8
     date: 2026-05-29 -->
# Ollivier–Ricci Curvature
```

`Scripts/generate_notebooks.wls` parses that block and injects it into the
generated `.nb` as `Notebook[cells, TaggingRules -> {"Provenance" -> <|...|>}]` —
Wolfram's native, non-rendering metadata slot. You do not write `TaggingRules`
by hand; the script does it. When the comment is absent, the `.nb` is generated
exactly as before (no `TaggingRules`). See [new-notebook](../new-notebook/SKILL.md).

To read it back from a notebook:

```wolfram
"Provenance" /. (TaggingRules /. Options[Import["NotebooksLLM/Name.nb"], TaggingRules])
```

### Paclet functions / code (`Kernel/*.wl`, `Code/*.wl`)

A header comment above the file or the function:

```wolfram
(* Provenance: 2026-05-29 · intent: Wasserstein-1 distance on graphs
   ledger: Wiki/Prompts.md *)
```

### Wiki articles (Concepts / Definitions / Theorems)

A `## Provenance` section at the bottom of the article, mirroring `## Recover`:

```markdown
## Provenance
- Intent: ...
- Generated: 2026-05-29 · update-wiki · claude-opus-4-8
- Ledger: Wiki/Prompts.md
```

### Work items (`Work/<Name>.md`)

Capture the originating request in the Spec and each session's prompt in Progress:

- In `## Spec`: an `Origin:` line with the verbatim request that prompted the item.
- In each `## Progress` block: a `**Prompt:**` line with the session's request.

## Turning it on

When the user asks to enable provenance:

1. Set `Prompt tracking: **on**` in the project's `CLAUDE.md` (add the
   `## Provenance` section if absent).
2. Create `Wiki/Prompts.md` with the header shown above (if it doesn't exist).
3. Add the `## Prompts` entry to `Wiki/Index.md`.

To disable, set `Prompt tracking: **off**`. Leave existing entries in place —
they are part of the git history.

## Backfilling

When the user wants to record provenance for something just produced (or an
older artifact), append a ledger entry and add the matching embedded back-pointer
using the rules above. Distil the intent from the conversation; include the
verbatim prompt only if it's short or requested.

## How other skills use this

These skills check the toggle and, when on, record provenance in this format:

- **new-notebook** — writes the leading HTML comment into the notebook source
  and appends a ledger entry. The script propagates the comment to `TaggingRules`.
- **update-wiki** — appends a `## Provenance` section to newly generated articles
  and a ledger entry.
- **work** / **next-session** — record `Origin:` in the Spec and `**Prompt:**`
  in each Progress block; mirror to the ledger when on.

This skill is the single source of truth for the format — the others reference it
rather than redefining it.
