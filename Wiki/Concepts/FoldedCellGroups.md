# Folded cell groups: code hidden, graphic shown

*[ LLM Generated ]*

A Wolfram cell group has a **third** display state beyond `Open` and `Closed`:
`{n}`, meaning *closed, displaying cell `n`*.
`Cell[ CellGroupData[ { input, output }, {2} ] ]` therefore shows the graphic and
hides the code that produced it, which is the shape a research notebook needs
and the one `Open` and `Closed` both fail to give.

## Details

### The three states

| State | Displays |
|---|---|
| `Open` | every cell in the group |
| `Closed` | the **first** cell — for an Input/Output pair, the code |
| `{n}` | cell `n` alone |

The front end's automatic grouping makes the `Input` cell the head of its
`Output`s, so `Closed` collapses a computation onto its source and `Open` shows
both.
Neither is what a reader of a mathematical document wants: the picture is the
content and the code is the appendix.
`{2}` inverts the pair without reordering it.

### The precedent

`Infrageometry/NotebooksLLM/Displacements.nb` (1.7 MB, 22 computations) uses
`{2}` for **every** Input/Output pair and sets no other option — no
`CellGrouping`, no `CellOpen` anywhere in the file.
It is the working reference for this shape.

### Two mechanisms that do not work

Both were built and measured before `Displacements.nb` was consulted:

- **`CellOpen -> False` on the `Input` cell.**
  It round-trips through `Export`/`Import` intact and does hide the contents, but
  renders as a strip too faint to notice, so the reader has no visible affordance
  and concludes the code is absent.
- **An explicit `Closed` group with the `Output` cell placed first.**
  Under the notebook's default `CellGrouping -> Automatic` the front end
  recomputes grouping from cell styles and **discards the explicit
  `CellGroupData`**, so the group reopens itself and the code reappears.
  Forcing `CellGrouping -> Manual` preserves it, but the whole detour is
  unnecessary under `{2}`.

### Consequences for a generator

- **One `Output` per `Input`.** A closed group displays a single cell, so a
  computation emitting two outputs can show only one of them. Split it.
- **`Input` cells must carry real code** — a code `String` or genuine boxes.
  `ToBoxes` applied to a code *string* produces a cell displaying the quoted
  string; nothing errors, and it is visible only on screen.
- **The environment cell stays a sibling** above the group rather than heading
  it, so it remains the line the reader scans.

## See also

- [The notebook TaggingRules registry](TaggingRulesRegistry.md) — the other notebook-level convention every writer of a generated `.nb` must respect
- [MathNotebook](../Resources/MathNotebook.md) — supplies the environments and stylesheet the folded groups sit inside
- [Set-valued naming in the graph-displacement theory](DisplacementNaming.md) — the other note drawn from the same Infrageometry displacement work
