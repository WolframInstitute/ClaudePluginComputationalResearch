# Human-owned paclet design notebooks

When developing a paclet repository, support the user in keeping an editable design notebook and one concise companion in the repository root, beside the paclet folder.
Apply the same ownership and iteration control as for a human paper.

## Naming and location

| Role | Path, for a paclet named `Infrageometry` |
| --- | --- |
| Human-owned design, iteration 1 | `Infrageometry1.nb` |
| Concise companion to iteration 1 | `Infrageometry1_notes.nb` |
| Next human iteration, only when the human chooses | `Infrageometry2.nb` |
| Its matching companion | `Infrageometry2_notes.nb` |

Use the actual paclet name and capitalization, not a hard-coded `Infrageometry` stem or the repository name when it differs from the paclet name.
Place both notebooks in the repository root alongside the paclet folder; do not introduce a separate notes directory.
Preserve existing human files and recorded current paths; relocating an existing notebook requires a scoped user request.
In a multi-paclet development repository, each paclet has its own named pair at the repository root.
Record the current human design and companion paths in the repository's `AGENTS.md` and `CLAUDE.md` when those notebooks exist; do not infer acceptance from the newest file timestamp.
Keep design notebooks outside the nested paclet payload so development notes are not accidentally shipped.

## Authority and content

- The human design notebook is the primary design document and is directly editable by the human.
  The human decides what belongs in it and when to begin the next numbered iteration.
  Edit its content only on an explicit request, preserving direct notebook edits, structure, vocabulary and notation.
- Before substantial paclet/API work, read the current human design and its companion.
  Use the accepted design to guide the requested implementation, interface naming, examples and relevant checks.
  If implementation and design diverge, identify the discrepancy in the companion and propose a design change; do not silently rewrite the human notebook.
  An explicit code-change request authorizes that implementation scope, not automatic promotion of every companion proposal.
- The companion follows the design notebook's sections and terminology.
  Keep it easy to scan: itemized proposed operations and signatures, precise mathematical statements, small examples, corrections, alternatives, open decisions, and citations or links.
  Clearly distinguish accepted design, proposals, proved results and observed computational behavior.
  Preserve human corrections in the companion too.
- A useful design notebook can describe the mathematical objects, intended representations, public operations, invariants, expected input/output examples, boundary cases and acceptance checks.
  Help the human establish these incrementally; do not invent a large API or write a full theory document when only a small design decision was requested.
- Put requested long derivations, experiments, benchmarks, detailed algorithms and supporting code in topical `Artifacts/` files and link them from the companion.
  Do not add competing full-design `_llm` documents or separate human/LLM notes directories.
  Keep meaningful superseded versions recoverable in `Archive/`.

## Notebook and build support

Use actual editable Wolfram notebooks for the `.nb` deliverables, not renamed text/PDF documents.
The assistant handles notebook tooling, conversion and supporting sources; the human should not run custom refresh or conversion scripts to keep the design usable.
If a Markdown or code source supports generation, it is machinery: never regenerate over human edits in the design `.nb` or a corrected companion.
Reconcile those edits first using the notebook-aware workflow.

During an authorized repository setup or design task, help establish a minimal design/companion pair if missing and record the selected current version.
A routine archive build does not authorize overwriting a design, inventing the next iteration, or requiring the human to complete a design document before the build can proceed.
For an existing build request, consult the current design when present and report relevant inconsistencies without making notebook creation a blocking gate.

Design notes are repository documentation, not automatically a shipped paclet feature.
Keep them outside the actual paclet source payload where possible; if layouts overlap, check packaging intent rather than silently changing declared assets or publishing notebooks.
This convention does not authorize editing a reference clone or migrating an unrelated repository.
