---
name: dev-notebook
description: >
  Build an LLM-generated "dev notebook" for the paclet under development: a
  self-contained, evaluated, cloud-deployed Wolfram notebook that presents every
  exported function (a reference card) plus a sequence of worked examples, each
  mostly code and each producing a picture. Outputs are embedded (graphics
  rasterized, small symbolic results kept as live boxes), the build is smoke-
  tested headless to zero messages, deployed public to the Wolfram Cloud, and the
  stable URL is linked from the README. Use when the user says "dev notebook",
  "demo notebook", "build the paclet demo", "show what the paclet does",
  "reference notebook for the paclet", or the /dev-notebook command.
---

# Dev Notebook

A single script builds one notebook a reader can open in the browser and
immediately *see* what the paclet does: a reference card of every exported
function, then a sequence of worked examples — each opening with a sentence or
two of plain prose, then mostly clean code, each producing an embedded picture.

The script — `Scripts/build_<name>_notebook.wls` in the paclet repo — is the
**source of truth**. The `.nb` is a build artifact (gitignored). Re-running the
script rebuilds and redeploys to the **same cloud object**, so the public URL is
stable across versions.

The template lives at `${CLAUDE_PLUGIN_ROOT}/scripts/build_dev_notebook.wls` and
is reusable across paclet repos. Copy it in, fill the three marked sections, run.

## Kernel execution (license-aware)

Prefer the AgentTools MCP (`mcp__Wolfram__WolframLanguageEvaluator`) — one
persistent kernel, no extra license seat. Develop and smoke-test the build by
evaluating the assembly code through the MCP, and deploy with `CloudDeploy`
through the same kernel. The `Scripts/build_<name>_notebook.wls` invocation via
`wolframscript` is the **batch/headless fallback**; before spawning it, check
headroom (this costs no seat — it runs on the already-running kernel):

```wolfram
With[ { free = $MaxLicenseProcesses - $LicenseProcesses }, free ]
```

If `free <= 0`, do **not** spawn `wolframscript` — route the build through the
MCP (`Get` the script file into the persistent kernel, or evaluate the assembly
inline) or ask the user to free a seat.

This skill assembles `Notebook[cells]` directly in the kernel (it does **not**
use the new-notebook Markdown→ImportString pipeline). The constructors and the
rasterize-vs-boxes heuristic are in the template; reuse them, don't reinvent.

## What you need

1. **The paclet under development** — its name, the directory holding
   `PacletInfo.wl`, and the context to `Needs[]`. Detect from the project's
   `CLAUDE.md` or by scanning for `PacletInfo.wl` (dev repo: triple nesting
   `<root>/<Name>/<Name>/`; standalone: double nesting `<root>/<Name>/`).
2. **The exported symbols, grouped by source module** — read the `Kernel/`
   source files; one group per module, each listing that module's
   `PackageExport` symbols. Pull descriptions from `::usage` automatically.
3. **A gitignored notebooks folder** for the local `.nb` artifact — reuse
   `NotebooksLLM/` (already gitignored as `NotebooksLLM/*.nb` in scaffolded
   projects) unless the user prefers another.

## Procedure

### 1. Gather the exported functions

Load the paclet and enumerate its public symbols grouped by source file:

```wolfram
PacletDirectoryLoad[ "<pacletDir>" ];
Needs[ "<Org>`<Paclet>`" ];
Names[ "<Org>`<Paclet>`*" ]
```

Read the `Kernel/` files to learn which symbols belong to which module so the
reference section can be grouped by module (one subsection each). The reference
must cover **all** exported functions.

### 2. Design the worked examples

One concept per example section. For each:

- **Open with 1–3 sentences of plain prose** — what this shows, no jargon.
- **Mostly code, clean** — no clutter, no defensive programming, no comments.
- **Use the paclet's own functions** plus standard WL / Function Repository
  functions — not bespoke reimplementations of what the paclet provides.
- **Follow the project's example house style.** If the `wi:sw-example` skill is
  present (the WolframInstitute house style), follow it: chained `With[]`
  bindings, inline literals, a declared `SeedRandom`, `Standard*` colors, no
  axes / frames / labels / legends / plot titles, `Text[...]` around any visible
  string. Otherwise follow the project's own notebook style rules.

**Options / variants → subsections titled by the literal code form.** When a
section demonstrates a function's options or method settings, put each setting in
its own subsection whose title **is the code**, e.g. `"Method" -> "3DFiber"`,
`"IsomorphicFibers" -> True`, `Maximality -> "Diameter"`. Never invent prose
names ("the 3D variant") — the subsection title is the option.

### 3. Fill the template

Copy `${CLAUDE_PLUGIN_ROOT}/scripts/build_dev_notebook.wls` to
`Scripts/build_<name>_notebook.wls` and fill the three marked sections:

- **(A) CONFIG** — `pacletName`, `pacletAuthor`, `pacletDir`, `pacletNeeds`,
  `notebooksDir`, and `nbIntro`. The intro is 2–4 plain sentences saying *what
  you're looking at* — **no formulas, no function names, no option names, no math
  notation** in the intro or any section/subsection prose.
- **(B) REFERENCE** — `referenceGroups`, one `"Module" -> {symbols}` rule per
  module. `usageLine` pulls each symbol's `::usage` first line automatically.
- **(C) EXAMPLES** — `exampleCells`, the `{sec, txt, io @ Hold[...]}` blocks.
  Each code expression is wrapped in `Hold[...]` so `io` evaluates it once and
  embeds the result.

The constructors are already defined in the template:

| Constructor | Produces |
|-------------|----------|
| `sec[title]` / `sub[title]` | Section / Subsection cell |
| `txt[body]` | Text cell (plain prose) |
| `io[Hold[code]]` | Input cell + embedded Output cell (evaluates once) |
| `refGroup["Module" -> {syms}]` | Subsection + two-column signature\|description Grid |

### 4. Output / embedding rules

Handled by `outCell` / `rasterizeQ` in the template — do not bypass them:

- **Graphics** (`Graphics`, `Graphics3D`, `Image`, `Legended`, `Graph`, or a
  `Grid`/`Column`/`Row` containing graphics) → **rasterized to a bitmap** at
  fixed `ImageResolution -> 144`, `ImageSize -> 420` for uniform thumbnails, so
  the cloud notebook is fast and the picture the author saw is the picture the
  reader gets.
- **Small symbolic / numeric output** (booleans, sets, matrices, short lists) →
  embedded as **live typeset boxes** (`ToBoxes`), readable and copy-pasteable.
- Every embedded output is the **real evaluated result**, never a mock-up.

### 5. The mandatory subtitle — do not omit

Like every LLM-generated notebook in this plugin, the dev notebook carries the
**`[LLM Generated]` Subtitle** marker directly under the Title. The template adds
two subtitle cells: the spec subtitle `Dev notebook — <Name>` **and** the
`[LLM Generated]` marker. Never ship the notebook without the `[LLM Generated]`
marker.

### 6. Smoke test (before deploy)

The template evaluates every example inside an `Internal`HandlerBlock` that
collects messages, wraps each evaluation in `TimeConstrained`, and forces the
renderer via `Rasterize`, so render-time errors (bad coords, etc.) are caught,
not just construction-time ones. The build **must finish with zero messages**;
the script `Exit[1]`s and lists offenders otherwise.

If a probe times out, **shrink the input** (coarser graph, smaller `n`) — do not
just raise the cap.

### 7. Deploy and report

The script exports the local `.nb` (gitignored), `CloudDeploy`s it
`Permissions -> "Public"` to the stable cloud object, and prints
`=== DEV_NOTEBOOK_URL: <url> ===`. Extract the URL from that line.

If running through the MCP instead: evaluate the same assembly, then
`CloudConnect[]` and `CloudDeploy[ notebook, CloudObject[ "DevNotebooks/<Name>.nb" ], Permissions -> "Public" ]`;
the returned object's `First` is the public URL. (If `CloudConnect` fails, the
user must authenticate once.)

### 8. README integration

Link the deployed URL from the paclet's `README.md` under a clearly named
section — **`## Dev notebook — <Author>`** — noting it runs on the Wolfram Cloud
and how to rebuild:

```markdown
## Dev notebook — <Author>

A live, evaluated demo of every function, hosted on the Wolfram Cloud:

<cloud-url>

Rebuild and redeploy with `wolframscript -f Scripts/build_<name>_notebook.wls`.
```

If the section already exists, update the URL only if the cloud object changed
(it shouldn't — the object name is stable).

## Checklist

- [ ] Intro / section / subsection text has no formulas, function names, or option names.
- [ ] Function-reference section covers *all* exported functions, grouped by module, terse.
- [ ] Each example section: short prose + mostly clean code + embedded output.
- [ ] Options shown as subsections titled by their literal code form.
- [ ] Graphics rasterized; small symbolic output kept as live boxes.
- [ ] `[LLM Generated]` subtitle present (plus the `Dev notebook — <Name>` subtitle).
- [ ] Build evaluates everything, zero messages, deploys public, prints the URL.
- [ ] README links the URL and the rebuild command.

## Provenance (optional)

If the project has prompt tracking on (`Prompt tracking: **on**` in `CLAUDE.md`
— see the [provenance](../provenance/SKILL.md) skill), record the originating
prompt: add a `(* provenance: ... *)` comment near the top of
`Scripts/build_<name>_notebook.wls` and append an entry to `Wiki/Prompts.md`.
When tracking is off (default), skip this.
