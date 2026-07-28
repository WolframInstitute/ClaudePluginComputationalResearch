# new-notebook: named templates

When the user doesn't specify a structure, infer from context or ask.

## `research` template

```
# <Title>
## Setup        ← package loads (become InitializationCells)
## Exploration  ← initial computations and visualizations
## Results      ← key findings and summaries
## Discussion   ← interpretation, conjectures, next steps
```

## `paper-analysis` template

```
# <Title>
## Paper Metadata   ← full title, authors, year, arXiv ID
## Summary          ← 3–4 sentence abstract in own words
## Key Definitions  ← brief explanations of terms
## Key Results      ← one sentence per theorem/result
## Relevance        ← connection to current project
## Code             ← reproduce or verify key computations
```

## `computation` template

```
# <Title>
## Setup          ← package loads and configuration
## Algorithm      ← pseudocode or description (CodeText cells)
## Implementation ← actual Wolfram Language code
## Tests          ← verification against known cases
## Visualization  ← plots and graphics
```

## `theorem-proof` template

For math-research projects (see [new-project](../new-project/SKILL.md) math-research type).
The full markdown skeleton is at `${CLAUDE_PLUGIN_ROOT}/skills/new-project/assets/notebook_theorem_proof_template.md` — copy it as the starting point, then specialize.

```
# <Theorem Name>
## Setup            ← package loads
## Definitions      ← terms used in the statement (linked to Wiki/Definitions/)
## Statement        ← precise theorem statement, numbered hypotheses
## Proof
###   Step 1        ← each major step is its own subsection
###   Step 2
###   Step N — Conclusion
## Corollaries      ← downstream results with brief proofs
## Examples         ← low-dimensional / finite verifications
## Non-examples     ← cases where a hypothesis fails (justifies hypotheses)
## References       ← Wiki/Theorems/ link + external refs
```

Notes:

- One `Subsection` per proof step (use `###`); within a step, alternate narrative text with `wolfram` code blocks that verify or illustrate.
- Hypotheses get numbered ItemNumbered cells so the proof can refer to them as "H1", "H2", etc.
- Use **display math** (`$$ ... $$`) for the theorem statement and key equations within the proof; **inline math** (`$ ... $`) for variables.
- The full post-processing ([pipeline-builtin.md](pipeline-builtin.md)) applies as usual — do not skip `boxifyInputCells` or `markInitCells`.
