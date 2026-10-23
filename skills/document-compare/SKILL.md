---
name: document-compare
description: >
  Review agreement between a current human-owned manuscript or paclet design,
  its notes companion, and relevant proofs, code, examples or checks. Use when
  the user asks whether implementation follows the accepted design, which
  proposals remain unintegrated, or where claims and evidence diverge. Report
  focused discrepancies with locations and evidence; do not rewrite the human
  baseline, accept proposals or advance its iteration during review.
---

# Compare the document, proposals and evidence

## When to use

- The user asks whether a paclet implementation matches the accepted design.
- The user asks what differs between the human paper/design, companion proposals and available evidence.
- A requested change exposes a material inconsistency that needs focused review.

## Steps

### 1. Establish the comparison

Read the recorded current human source and companion using [paper ownership](../paper-create/workflow.md) or [paclet design ownership](../project-create/paclet-design.md).
Do not use timestamps or implementation behavior as evidence that the human accepted a proposal.
If authority is unresolved, identify it before dependent conclusions; use `document-setup` when selection is needed.
Read the actual editable notebook when applicable, including direct human changes.
Limit review to the user's question and relevant sections, operations or claims.

### 2. Trace statements to evidence

Compare accepted wording with relevant implementation, examples, proof artifacts, citations and existing checks.
For paclets, focus on the requested public operations, representations, invariants, input/output examples and boundary cases.
For papers, focus on the requested definitions, hypotheses, claims, arguments and citations.
Keep accepted design, companion proposals and observed implementation behavior distinct.
Run only appropriate authorized checks needed to resolve a material question; a review does not automatically require a build, new test suite or external publication.
State exactly what was read or checked and what remains unverified.
Finite examples are evidence about those examples, not a proof of a general claim.

### 3. Report actionable discrepancies

Give a compact list or table with the human source location, relevant proposal or implementation location, evidence, and a suggested next action.
Quote or reference stable labels and notebook sections/cells where available; do not invent locations or theorem numbers.
Distinguish an implementation defect, an unclear design decision, an unaccepted proposal, and a mathematical gap.
If nothing material is found, say so within the reviewed scope without claiming the whole project is correct.

Review is read-only by default; do not create another report file unless requested.
When saved findings are requested, use `document-propose` and keep detail in existing or explicitly requested topical artifacts.
An explicit request to fix code authorizes that code scope; it does not authorize rewriting the human design to match the implementation.
Do not merge proposals, change current-version pointers, create a new human iteration, or replace annotated reading copies during review.

## Integration with other skills

- `document-setup` resolves the human baseline; `document-propose` records requested proposals and findings.
- Paclet build, documentation and test tools can supply relevant evidence without advancing the design.
- This is a scoped comparison, not a substitute for a requested full mathematical proof review or publication audit.

## When NOT to use

- Every routine build or small edit solely to impose a process gate.
- Promoting proposals or rewriting a human document without explicit instructions.
- Claiming global correctness from a limited comparison or a passing computation.
