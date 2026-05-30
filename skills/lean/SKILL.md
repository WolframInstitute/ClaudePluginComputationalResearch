---
name: lean
description: >
  Drive a Lean 4 / Mathlib formalization session via the lean-lsp MCP.
  Opens a file, reads the goal state, searches Mathlib for closing lemmas,
  verifies proofs, and writes a formalization checklist to Work/.
  Use when the user says "formalize in Lean", "prove this in Lean",
  "what's the Mathlib name for X", "check this Lean proof", "lean state",
  or during math-research projects with a Lean/ subdirectory.
---

# Lean Bridge

Coherent workflow around the `lean-lsp` MCP for formalization work. The
MCP itself is rate-limited and read-only; this skill orchestrates calls
into a useful sequence and persists progress to `Work/`.

## When this skill kicks in

- The project has a `Lean/` (or `lean/`) directory with a `lakefile.lean`
- The user pastes a Lean snippet / `theorem` declaration
- The user asks to formalize a math statement (in which case start by
  scaffolding a `Lean/` lakefile via the user)
- The user asks "what's the Mathlib name for X"

## Setup check

Before any other action:

1. Confirm a `Lean/` directory + `lakefile.lean` exist. If not, ask the user
   whether to scaffold one (provide `lake new <ProjectName> math` as the
   recommended command — do not run it without confirmation).
2. Confirm Mathlib is available (look for `lake-manifest.json` referencing
   `mathlib`).
3. Confirm the `lean-lsp` MCP responds — call `mcp__lean-lsp__lean_file_outline`
   on the target file. If it fails, ask the user to run `lake build` once.

## Core loop

For each goal you are trying to close:

### Step 1 — Read the goal

```
mcp__lean-lsp__lean_goal  (file, line[, column])
```

Omit `column` to see the goal **before** and **after** the line.

If the result is `"no goals"`, the proof is complete.

### Step 2 — Search for closing lemmas (in this order)

1. **Local first** — is there a lemma already proved in the same file?
   `mcp__lean-lsp__lean_local_search` with the goal's main predicate as query.
2. **State-based** — what existing Mathlib lemma closes this exact state?
   `mcp__lean-lsp__lean_state_search` with the goal text.
3. **Natural language** — "I need a lemma that says X":
   `mcp__lean-lsp__lean_leansearch` with a natural-language description.
4. **Type pattern** — "find a lemma of shape `_ ≤ _ * _`":
   `mcp__lean-lsp__lean_loogle` with the pattern.
5. **Premise selection** — what's worth feeding to `simp`/`aesop`?
   `mcp__lean-lsp__lean_hammer_premise`.

After finding a candidate name, confirm with `mcp__lean-lsp__lean_hover_info`
(type signature + docs) and optionally `mcp__lean-lsp__lean_declaration_file`.

### Step 3 — Try tactics without editing

```
mcp__lean-lsp__lean_multi_attempt  (file, line, snippets: ["simp", "ring", "omega", "exact?"])
```

Use **line-based** form (omit `column`) for fast REPL-style attempts. Use
column-based form when the attempt must occur at an exact source position.

### Step 4 — Edit + verify

After editing the file via the `Edit` tool, verify with:

```
mcp__lean-lsp__lean_diagnostic_messages  (file)
mcp__lean-lsp__lean_verify  (fully-qualified theorem name, e.g. "MyNS.my_thm")
```

`lean_verify` also runs an axiom check — fail loudly if it reports `sorryAx`
or unexpected axioms.

### Step 5 — Re-run goal

Return to Step 1 if the goal is not yet closed.

## Formalization checklist

When the user asks to **formalize** a math statement (vs. closing one
specific goal), seed a checklist before opening Lean:

1. Read `${CLAUDE_PLUGIN_ROOT}/skills/new-project/assets/formalization_checklist_template.md`.
2. Write a copy to `Work/Backlog/Formalize-<KebabTopic>.md` (move to `Active/` when
   you start, archived to `Done/` when complete — folder is the status), filling in:
   - **Statement** — the precise theorem in math + Lean syntax
   - **Hypotheses** — what's needed, what's assumed
   - **Proof outline** — math-level proof sketch
   - **Axioms allowed** — usually classical + propext + choice
   - **Mathlib dependencies** — known related lemmas (use `lean_leanfinder`
     and `lean_leansearch` to find candidates)
3. Walk through the checklist with the user before writing Lean code.

Update the checklist after each substantive step (note what closed each
sub-goal, any axioms used).

## Performance considerations

- `lean_build` is **slow** — only invoke after adding imports.
- `lean_profile_proof` is **slow** — only when investigating a known-slow
  proof.
- Search tools are rate-limited (3/30s for most, 10/30s for `leanfinder`) —
  batch related queries.

## Output discipline

When you produce Lean code for the user:

- Always show the **goal state before** and the **goal state after** the
  tactic.
- Always name the Mathlib lemmas you relied on, with one-line summaries.
- After a `theorem` is closed, run `lean_verify <fullname>` and report the
  axioms used.

## Integration with other skills

- [search-math](../search-math/SKILL.md) — look up math background
  before formalizing (nLab definitions, MathWorld theorem statements).
- [work](../work/SKILL.md) — the formalization checklist is a `Type:
  formalization` work item; [next-session](../next-session/SKILL.md) drives it
  across sessions (one Lean sub-goal per session) while this skill is the
  per-task engine.
- [add-resource](../add-resource/SKILL.md) — when a Mathlib commit, blog
  post, or proof-assistant paper informs the work, add it as a resource.

## When NOT to use

- Pure math content questions with no intent to formalize → [search-math](../search-math/SKILL.md).
- Closed-form symbolic computation → use the Wolfram MCP instead.
- Wolfram-paclet correctness checks → use the existing test infrastructure
  (`run_tests.wls`), not Lean.
