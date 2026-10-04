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
  next-session) follow this skill's format when the toggle is on. Also owns
  the always-on document provenance file (<stem>.provenance.md) that a
  revision round keeps beside a document: notes, hand edits, requests, rules.
---

# Prompt Provenance

Record *what was asked* to produce a generated artifact.
The plugin already records *who* generated code (git `Co-Authored-By` trailer) and *what changed* (`Wiki/Status.md`, Work `## Progress`).
Provenance fills the remaining gap: the originating prompt/intent behind each artifact.

This mirrors the existing `## Recover` convention (see [add-resource](../add-resource/SKILL.md)): plain markdown, git-tracked, machine-readable, no database.
It is **optional** — nothing here runs unless the project toggle is on, except [§ *Document provenance*](#document-provenance), which every revised document keeps.

## When to use

- The user says "track prompts", "record the prompt", "where did this come from", "turn provenance on/off", "show the prompt ledger", or runs `/provenance`.
- Automatically, when the toggle is **on** and an artifact is generated (the generating skills follow this skill's format — see *Integration with other skills*).

## Steps

When the toggle is on and an artifact is generated:

1. Build the canonical record (§ *The canonical record*).
2. Embed the back-pointer in the artifact (§ *Embedded back-pointers*).
3. Append the entry to `Wiki/Prompts.md` (§ *The central ledger*).

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

- **off** (default, or section absent): do nothing.
  Never create `Wiki/Prompts.md`, never embed back-pointers.
  Stay silent — do not nag the user to turn it on.
- **on**: record provenance for each artifact you generate, per the rules below.

To flip the toggle, edit the `Prompt tracking:` line in `CLAUDE.md` (and seed `Wiki/Prompts.md` the first time it goes on — see *Turning it on*).

## The canonical record

One small set of fields, reused in the ledger and in every embedded back-pointer:

| Field | Meaning |
|-------|---------|
| `date` | Absolute `YYYY-MM-DD` (from the current date). |
| `artifact` | Path relative to project root (`Code/Artifacts/Ricci_260919.nb`, `Code/Curvature.wl`). |
| `intent` | One-line distilled goal. **Always present.** |
| `prompt` | Verbatim user request. Optional — include when short, or when the user asks. |
| `generator` | The skill that produced it (`new-notebook`, `update-wiki`, …). |
| `model` | Model id (e.g. `claude-opus-4-8`). |
| `source` | Notebooks only: the `.md` source path beside the notebook. |

**Fidelity:** default to a concise one-line `intent`.
Add the verbatim `prompt` when the request is short, reproducibility matters, or the user asks for it.
Do not paste long conversational text into the ledger.

## The central ledger — `Wiki/Prompts.md`

Append-only, **newest at the bottom** (matching the Work `## Progress` convention).
One `###` block per generation event:

```markdown
# Prompt Ledger

Append-only record of the prompts/intent behind generated artifacts.
Toggle in CLAUDE.md (`Prompt tracking`). See the `provenance` skill for the format.

### 2026-05-29 — Code/Artifacts/RicciCurvature_260529.nb
- **Intent:** Explore Ollivier–Ricci curvature on graphs with pastel plots
- **Prompt:** "make a notebook about ollivier ricci curvature on graphs"
- **Generator:** new-notebook · claude-opus-4-8
- **Source:** Code/Artifacts/RicciCurvature_260529.md
```

Omit lines that don't apply (e.g. no `Source:` for a `.wl` file; drop `Prompt:` when you're only keeping the distilled intent).
Register the ledger once in `Wiki/Index.md` under a `## Prompts` section:

```markdown
## Prompts

- [Prompt Ledger](Prompts.md) — prompts/intent behind generated artifacts
```

## Embedded back-pointers (so provenance travels with the file)

In addition to the ledger entry, embed provenance **inside** each artifact so it survives when the file is shared standalone.

### Notebooks

Write a leading HTML comment into the artifact's `.md` source.
HTML comments are dropped by the `{"Markdown","Notebook"}` importer, so they never become cells:

```markdown
<!-- provenance:
     intent: Explore Ollivier–Ricci curvature on graphs
     prompt: "make a notebook about ollivier ricci curvature on graphs"
     generator: new-notebook
     model: claude-opus-4-8
     date: 2026-05-29 -->
# Ollivier–Ricci Curvature
```

The comment is the durable record; the generated `.nb` mirrors it in `TaggingRules` under the `"Provenance"` key — Wolfram's native, non-rendering metadata slot.
Who injects it depends on the generation path:

- **MCP path (the normal one):** the generating skill injects it during the build — construct the association from the comment's fields, strip the comment from the markdown string before conversion, and stamp the notebook expression before `ExportString` with the merge helper below.
- **Batch fallback (`Scripts/generate_notebooks.wls`):** the script parses the comment and injects it itself — do not pre-strip the comment or write `TaggingRules` by hand there.

When the comment is absent, the `.nb` is generated exactly as before (no `"Provenance"` key).
See [new-notebook](../new-notebook/SKILL.md).

**`TaggingRules` is a shared slot — merge by key, never replace the option.**
[new-research-notebook](../new-research-notebook/SKILL.md) stores its per-cell fingerprint there under the `"ResearchNotebook"` key, so a writer that sets a literal `TaggingRules -> {...}` erases the other key.
Every writer stamps through this helper (canonical here; verified to survive the `ExportString`/`ImportString` round-trip with both keys intact):

```wolfram
stampTaggingRule[ nb_Notebook, key_String -> value_ ] :=
  With[ { existing = Replace[ TaggingRules /. Options[ nb ], TaggingRules -> {} ] },
    Notebook[ First @ nb,
      Sequence @@ FilterRules[ Options[ nb ], Except[ TaggingRules ] ],
      TaggingRules -> Normal @ Append[ Association @ existing, key -> value ] ]
  ]
```

`stampTaggingRule[ nb, "Provenance" -> prov ]` adds or updates the provenance without touching any other `TaggingRules` key or notebook option; stamping only touches options, so an already-computed cell fingerprint stays valid.

To read it back from a notebook:

```wolfram
"Provenance" /. (TaggingRules /. Options[Import["Code/Artifacts/Name_260919.nb"], TaggingRules])
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

### Work items (`Work/<bucket>/<Name>.md`)

Capture the originating request in the Spec; each session's prompt goes to the ledger, not the item file:

- In `## Prompt history`: the verbatim request that prompted the item, dated, plus any later user request that reshaped it (older items carry an `Origin:` line in `## Spec` instead).
- In `Wiki/Prompts.md`: one ledger entry per session, which the item's `## Progress` line links.
  The item file carries no `Prompt:` field — one fact, one destination (see `work`, *The item file format*).

## Turning it on

When the user asks to enable provenance:

1. Set `Prompt tracking: **on**` in the project's `CLAUDE.md` (add the `## Provenance` section if absent).
2. Create `Wiki/Prompts.md` with the header shown above (if it doesn't exist).
3. Add the `## Prompts` entry to `Wiki/Index.md`.

To disable, set `Prompt tracking: **off**`.
Leave existing entries in place — they are part of the git history.

## Backfilling

When the user wants to record provenance for something just produced (or an older artifact), append a ledger entry and add the matching embedded back-pointer using the rules above.
Distil the intent from the conversation; include the verbatim prompt only if it's short or requested.

## Document provenance

A document under revision remembers how it was revised.
This is separate from the toggle above and is **always on**: every document a [revision round](../revise/round.md) works on has a provenance file, whatever the toggle says.
The ledger records the prompt behind each artifact; a document's provenance file records what the user asked of that one document, where, and what came back.
`revise` writes it during a round; the generating skills write its first request.

### The file

One per stem, beside the document: `Note_260927.provenance.md` beside `Note_260927.tex`, `Note_260927_2.tex`, …
A folder-shaped artifact keeps it beside the folders, as `Name_YYMMDD.provenance.md`.

- It belongs to the stem, not to a version: it is not numbered, and a round does not copy it into `k+1`.
- [`/clean`](../../commands/clean.md) leaves it in place, so it stays in view beside the latest version.
- It is plain Markdown, for the user to read and edit, and it is committed with every round.

```markdown
# Note_260927 — provenance

## Rules
- Write "it is shown", never "we show". *(r2, H1–H4)*
- Example graphs have at most 10 vertices. *(r3, N2)*

## Requests
- 2026-09-27 — "make a note on geodesic pools" *(v1, new-research-note)*
- 2026-09-28 — "proofs shorter everywhere" *(chat, before r3)*

## Rounds
### r3 — 2026-09-28, v2 → v3
- N1 · `Note_260927_2.md` L41–47 (Example 2) · "make this example smaller" → 6-cycle
- N2 · L88 · "cite the source" → not done, no source in Resources/
- H1 · L12 · "we show" → "it is shown"
```

- **`## Rules`** — a short list, one imperative line each, ending with where it came from.
- **`## Requests`** — what the user asked about this document outside its notes, dated: the request that produced version 1 first, then each chat request, with when it came.
- **`## Rounds`** — one entry per round, newest at the bottom: `r<k+1>` is the round that wrote version `k+1` from version `k`.

Each line of a round is one note (`N`) or one hand edit (`H`), numbered from 1 within the round, so `r3 N2` names one note for good:

| Field | Meaning |
|---|---|
| file | the file the lines belong to, written once per round and then left out |
| lines | `L41–47` in version `k` as the user left it; `after L52` for something added between lines; `L?` when unknown |
| passage | the passage it was about, quoted or named ("Example 2"), so the record still reads after lines move in later versions |
| text | the note's words, or the hand edit as before → after (a one-line summary for a long one) |
| outcome | for a note, what was done, or `not done` and why |

### Version 1

The skill that generates a document starts its provenance file:

1. Write `<stem>.provenance.md` with an empty `## Rules`, one line under `## Requests` — the date, the user's request in their words (shortened if long), and `(v1, <skill>)` — and an empty `## Rounds`.
2. Commit version 1 as written: the text files (`.tex`, `.typ`, `.md`, code), the `.md` source of a notebook, and the provenance file, staged by name; never a generated `.nb`.
   This commit is the baseline that [hand edits](#hand-edits) of a text file are measured against.
3. Where the skill must not commit (the user asked for no commit, or the project forbids it), say `no baseline` in the file's `## Requests` line; the first round then records edits as `no baseline`.

### Anchors

Which lines a note is stored against:

- **Text files** (`.tex`, `.typ`, `.md`, code): lines of the file itself.
- **Notebooks**: lines of the version's Markdown source, never positions in the `.nb`.
  Each generated cell carries its source line range in its own `TaggingRules`, as `"SourceLines" -> { first, last }`, stamped at generation by `SourceLineNotebook` in [`scripts/source_lines.wl`](../../scripts/source_lines.wl); `CellSourceLines[ cell ]` reads it.
  A Markdown block that converts to several cells — a paragraph holding a display equation, a list item with a nested one — gives each of them the block's range.
  Head cells built from the frontmatter, the `[ LLM Generated ]` line and embedded Outputs carry none.
  A note in a cell maps to that cell's lines; a note in a cell the user added maps to `after L<n>`, the last line of the cell above it.
  A notebook generated before cells carried line ranges has none: its notes are anchored by quoted passage only, with `L?`.

### Hand edits

What the user changed by hand, found without asking them:

- **Notebooks**: a cell whose fingerprint no longer matches is one the user edited; the `.md` holds what Claude wrote, so both sides of the edit are known.
  No git is needed.
- **Text files**: `git diff` between version `k` as Claude committed it and the file as the user left it, taken before the round commits version `k`.
- **No baseline** — a text file whose version `k` was never committed as written, or a notebook without fingerprints: the round records `H · no baseline` and draws no rules from edits.

A note is not a hand edit, but both of these report it as one: the `git diff` holds every line the user added a note on, and the fingerprint marks every annotated cell as edited.
Take the notes out before deciding.
A diff line that is only a note is not an edit; a cell is hand-edited only when its content with each note deleted — `StringReplace[ s, " "... ~~ "<<" ~~ Shortest[ ___ ] ~~ ">>" -> "" ]` on its strings, and a string left empty dropped from its `TextData` — still misses its recorded hash.

### Rules

A rule is what keeps a correction from being needed twice.

- **Drawn** from a note or hand edit that says how the document should be, not only what one passage should say: a note whose words reach further ("everywhere", "always", "never"), a hand edit of a kind already made before, a chat request about the whole document.
  A one-off change of content makes no rule.
- **Cited** — each rule ends with the round and the notes or edits it came from: *(r3, N2)*, *(r2, H1–H4)*.
- **Added automatically** and listed in the round's reply.
  The user overrules a wrong one by editing or deleting it in the file.
- **Protected once the user touches it.** A rule the user wrote or edited — the file's `## Rules` differs from its last commit — is theirs ([revise § *Protected content*](../revise/SKILL.md#protected-content)) and is not reworded or dropped on Claude's initiative.
- **Overruled by a newer note.** A note that contradicts a rule wins, and the rule is rewritten to agree with it, citing the note.
- **Kept short.** A new rule that covers an old one replaces it.
- **Local to the document.** A rule that recurs across documents is proposed to the user for the project's style; Claude never moves it there.

Each round reads `## Rules` and the last two rounds first, records its notes, hand edits and requests, and checks the new version against every rule and every earlier hand edit before writing it — the steps are in [round.md](../revise/round.md#steps).

Out of scope: memory across unrelated documents, and any database.

## Integration with other skills

These skills check the toggle and, when on, record provenance in this format:

- **new-notebook** — writes the leading HTML comment into the notebook source and appends a ledger entry.
  On the MCP path it stamps the `TaggingRules` itself via `stampTaggingRule`; on the batch fallback the script propagates the comment.
- **new-research-notebook** — same comment and ledger entry; the build passes `TaggingRules -> { "Provenance" -> prov }` through `MathNotebookDocument`, and the later fingerprint stamp merges its `"ResearchNotebook"` key alongside it.
- **update-wiki** — appends a `## Provenance` section to newly generated articles and a ledger entry.
- **work** / **next-session** — record the user's requests in `## Prompt history`; each session's prompt goes to the ledger, and the `## Progress` line links it.
- **revise** — keeps each revised document's provenance file (§ *Document provenance*), whatever the toggle says.

This skill is the single source of truth for the format — the others reference it rather than redefining it.

## When NOT to use

- The toggle is **off** (the default) — do nothing, silently; never create the ledger or nag the user. A revised document's provenance file is kept all the same.
- Recording *who* wrote code or *what* changed — git authorship and `Wiki/Status.md` already carry those.
