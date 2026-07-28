# Set-valued naming in the graph-displacement theory

*[ LLM Generated ]*

Domain notes evicted from the `research-notebook` skill by `AuditFixes` T7.
They belong in the graph-displacement work's home project (the Infrageometry line of research), which has no wiki yet — **move this article there when it gains one**.
The skill keeps only the generic principle (name by closure, record the convention in a Remark); the worked case lives here.

## Details

Discrete-geometric constructions defined from a metric are **set-valued by default**: the metric leaves ties it cannot break, and the operations create them.
The naming is decided by **closure**, not by analogy with the smooth case:

- The operations of the displacement theory do not preserve single-valuedness, so the set-valued object is the primitive one and takes the plain name (`Displacement`), with a predicate for the special case (`DisplacementSingleValuedQ`) and the phrase "single-valued displacement" in prose.
  Naming the single-valued object `Displacement` would name a class the theory leaves after one operation.
- This was verified rather than assumed, by feeding single-valued inputs through every operation and reporting the largest value set: for displacements on graphs **only composition preserves single-valuedness**; sum, inverse, scaling and commutator all break it.
- A single-valued object contained in a set-valued one is a **selection**, the standard term from set-valued analysis.

The convention is stated in a `Remark` in the notebook's Definitions section, with the closure computation as its Example.

## Census examples used as evidence

Full enumeration on a small object beats sampling on a large one, and it catches false "obvious" claims:

- all 720 permutations of `C6`;
- of the 20 bijections of `C6` with magnitude ≤ 1, only 3 are automorphisms;
- all 729 scale-1 displacements on the reference patch.

## Infrageometry specifics

The research notebooks on this topic copy their example-graph constructions verbatim from Infrageometry's `Kernel/ExampleGraphs.wl` so each notebook is self-contained, and the repo README's `## 📓 Research Notebooks` table (rows `| Notebook | Description | Link |`, link anchored on "Wolfram Cloud") is the publication index the `research-notebook` skill's *publish* step mirrors.

## See also

- [MarkdownToNotebook](../Resources/MarkdownToNotebook.md) — the parser half of the research-notebook pipeline
