## Code style

**Exploratory research code.** Mathematical clarity matters more than robustness. Functionality first, readability second, performance third — but readability is non-negotiable. Code should read like a mathematician at a blackboard, not production software.

- **No defensive programming.** No `Return[$Failed]` on shape/range checks, no input validation, no error handling, no `f::badthing` messages. If the caller passes garbage, let it crash naturally. The only acceptable `$Failed` is "no such mathematical object exists" — and even then prefer an empty wrapper when it composes more cleanly.
- **Crash on the boundary, not inside.** Only the outermost user-facing signature pattern-matches for dispatch (`f[g_Graph, v_, ...]`); helpers below it trust their inputs and let inner built-ins raise their own errors.
- **Main functions first, helpers second — but prefer no helpers at all.** Inline the body unless the helper genuinely earns its name (reused at multiple call sites, or captures a single substantial idea). Resist splitting a long body into a chain of one-line helpers; compose at the call site with `Map`, `Fold`, `KeyValueMap`, `Thread`, etc. Option dispatchers (public signature handing off to a private worker) are an accepted exception.
- **Functional style; loops only when they earn it.** Default to `Map` / `Fold` / `Nest` / `Apply` / `Select` / `KeyValueMap` / `Thread`. Reach for `Do` / `While` / `For` only when (a) you have a mutable accumulator, (b) you need early termination on a non-trivial condition, or (c) the functional form measurably hurts speed or memory. When you use a loop, the body should be doing the substantive work — not setting up state for the next pipeline stage.
- **One-liners when efficient.** If a function fits on one line without becoming dense or unreadable, write it on one line. `f[g_, v_] := VertexOutDegree[g, v] - 1` beats a four-line `Module`.
- **Use `{x} |-> ...`, not `Function[{x}, ...]`.** Use `Function` only when the operator form genuinely will not work (named slots, attributes, multi-statement bodies). **Never nest one `|->` inside another** — restructure: lift the inner function to a named local with `With`, or chain the lambdas via `Map` / `Composition` / `RightComposition`.
- **No nested `Module`.** A function may open *one* `Module` for its locals; if it needs another scope inside, use `With[{...}, ...]`. If a function feels like it wants two `Module`s, it is doing two things and should be split — not nested. Same rule inside `DynamicModule` / `Manipulate` bodies.
- **`With` over `Module`** wherever the bindings are not mutated. `Module` is for genuinely mutable accumulators; everything else is `With`.

### Comments

- **One-line mathematical summary per exported symbol** — what the object *is*, mathematically (e.g. `(* midpoint of a, b: vertex m with d(a, m) == d(m, b) *)`). That is the only comment most functions need.
- Structural section dividers like `(* ===================== Points ===================== *)` are fine.
- **No** multi-paragraph block comments.
- **No** comments narrating what the next lines do, what a variable holds, or how the algorithm proceeds step-by-step. If a comment is needed to explain a *what*, the code is wrong; rewrite the code, do not annotate it.
- Reserve comments for genuine *why* — a non-obvious mathematical subtlety, a workaround for a Wolfram-specific quirk, a deliberate departure from the textbook definition.
- **Compose over annotate.** When tempted to write `(* this builds the level-surface subgraph *)` above a five-line block, bind the block to a named local instead: `With[{levelSurface = ...}, ...]`. The name documents the math; the comment becomes redundant.

### Performance

- **Preserve existing optimizations.** When refactoring, keep load-bearing performance code (memoized helpers, precomputed distance matrices, sparse representations, compiled inner kernels) intact even when its justification isn't documented. The goal is to strip *clutter*, not *speed*. If you must touch a fast path, add a one-line comment recording why it was fast.
- **No premature optimization.** No memoization, compilation, sparse-matrix conversion, or other tricks unless you measured a problem first. When you do add one, leave a one-line comment naming the operation that was hot.

### Testing

- **Tests assert math, not internals.** Organize a test file around the invariants the construction should satisfy (e.g. for a midpoint `m` of `a` and `b`: `d(a, m) == d(m, b)` and `d(a, m) + d(m, b) == d(a, b)`), not around `$Failed`-shape checks, wrapper-head pattern matches, or option-parsing branches. If a `VerificationTest` would fail only when the implementation changes shape — without any mathematical statement having become false — delete it.
- One `VerificationTest` per behavior; small deterministic graphs (`PathGraph[Range[5]]`, `CycleGraph[6]`, `GridGraph[{3, 3}]`, `PetersenGraph[]`) when relevant.

### Knowledge Base (Wiki)

When the project has a `Wiki/`:

- **One article per mathematical concept, not per exported symbol.** An article on a concept covers its definition, candidate methods, relationships, and open questions — not the function's signature, options, and accessor lists (those live in `::usage` and in any `APIConventions` article the project maintains). If you find yourself writing one article per `Find*` / `*Q` symbol, stop — you are duplicating the function reference. Merge into the underlying concept and link via `## See also`.
