# <Theorem Name>

Brief context: what kind of object, where it lives, why it matters here.

## Setup

```wolfram
Get @ FileNameJoin[{NotebookDirectory[], "..", "Code", "Tools.wl"}]
```

## Definitions

State the definitions used in the theorem statement.
Prefer linking each to a `Wiki/Definitions/<Term>.md` article rather than restating in full.

- **<Term 1>** — see `Wiki/Definitions/Term1.md`.
  Brief inline reminder.
- **<Term 2>** — see `Wiki/Definitions/Term2.md`.

Notation: list any non-standard notation used below.

## Statement

> **Theorem.** Let ... Then $\\dots$.

Hypotheses (numbered for proof reference):

1. $H_1$: ...
2. $H_2$: ...

Conclusion: $C$.

Optionally cross-link a `Wiki/Theorems/<Name>.md` article that tracks the proof status.

## Proof

Outline first, then steps.
Each major step gets its own subsection.
Within a step, narrative text alternates with `wolfram` code blocks that verify the step computationally where possible (small examples, sanity checks, plots).

### Step 1 — <short label>

Narrative.

```wolfram
(* concrete computation that illustrates Step 1 *)
```

### Step 2 — <short label>

Narrative.

```wolfram
(* concrete computation that illustrates Step 2 *)
```

### Step N — Conclusion

Combine the previous steps to derive $C$.

## Corollaries

> **Corollary 1.** ... .

Brief proof sketch (often one line: "Apply Theorem to $X$").

```wolfram
(* corollary verification *)
```

> **Corollary 2.** ... .

## Examples

Small, hand-checkable examples.
Use these to:

- Verify the theorem on a low-dimensional / finite case.
- Test the corollaries.
- Build intuition for the proof.

```wolfram
(* example 1 *)
```

```wolfram
(* example 2 *)
```

## Non-examples

Cases where the hypotheses fail and the conclusion can fail too.
This is essential — the non-examples justify the hypotheses.

```wolfram
(* non-example demonstrating the hypothesis is needed *)
```

## References

- [[../Theorems/<Name>]] — the wiki tracker for this theorem
- External: MathWorld / nLab / DLMF / paper / textbook references with full citations
