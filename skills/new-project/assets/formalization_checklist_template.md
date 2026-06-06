# Formalize: <Theorem / Definition / Topic>

*[ LLM Generated ]*

> Proof: **outlined**    <!-- outlined | in-progress | proved | verified (proof stage; lifecycle status is the folder) -->
> Type: formalization

Owner / driver: <name> Started: <YYYY-MM-DD>

## Statement

Math statement (exactly as it appears in `Wiki/Theorems/<Name>.md` or `Wiki/Definitions/<Name>.md`):

> ...

Target Lean statement (intended `theorem` / `def` signature):

```lean
theorem <name> (...) : ... := by
  sorry
```

## Hypotheses

| # | Hypothesis | Lean form | Status |
|---|------------|-----------|--------|
| H1 | ... | `...` | open |
| H2 | ... | `...` | open |

## Proof outline (math-level)

1. ...
   (key idea)
2. ...
   (reduction)
3. ...
   (closing argument)

Each step gets a Lean sub-goal below.

## Lean sub-goals

| # | Sub-goal | Closing tactic / lemma | Status |
|---|----------|------------------------|--------|
| L1 | ... | `exact?` / `simp [...]` / `<mathlib lemma>` | open |
| L2 | ... | ... | open |

## Mathlib dependencies

Lemmas / definitions discovered via `lean_leansearch`, `lean_leanfinder`, `lean_state_search`:

- `Mathlib.<Module>.<Name>` — one-line summary
- ...

## Axioms allowed

Default expectation: `propext`, `Classical.choice`, `Quot.sound`.
Anything beyond this gets flagged by `lean_verify` and must be justified here.

- [ ] No `sorryAx` in final proof
- [ ] No unexpected axioms beyond classical defaults

## Progress

Append one bullet per session:

- YYYY-MM-DD — closed sub-goal Lk via `<tactic / lemma>`; remaining: ...
- ...

## Cross-references

- Wiki: [[../Theorems/<Name>]] or [[../Definitions/<Name>]]
- Resources: relevant papers in `Wiki/Resources/`
- External: MathWorld / nLab / textbook references

## Verification

Final acceptance check (run when status flips to **verified**):

```
mcp__lean-lsp__lean_verify <NS>.<name>
```

Paste the axiom list returned here.
