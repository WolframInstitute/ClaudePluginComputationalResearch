## Source formatting

Semantic line breaks: **on** <!-- When on, prose you write in source files — markdown (.md) and LaTeX/Typst (.tex/.typ) — uses one sentence per line (semantic line breaks): each sentence starts on its own source line, and a long sentence may also break at clause boundaries.
This changes only the source; rendered output is unchanged.
Set to **off** to wrap prose into filled paragraphs.
Applies to wiki articles, work items, resources, journal entries, and papers — not to code, tables, headings, or YAML/TOML front matter.
Do not reflow an existing paragraph onto one line, and do not add blank lines between a paragraph's sentences (a blank line still separates paragraphs).
Detect with: grep -qiE 'semantic line breaks:[[:space:]]*\*{0,2}on' CLAUDE.md && echo on || echo off -->

A Wolfram context name ends in a backtick, which closes a single-backtick code span early and silently corrupts the text.
In any Markdown — docs, wiki, prompts, commit messages — write such a span with double backticks and a space inside each end: ``` `` WolframInstitute`Name` `` ```.

## Code style

**Exploratory research code.** Mathematical clarity matters more than robustness.
Functionality first, readability second, performance third — but readability is non-negotiable.
Code should read like a mathematician at a blackboard, not production software.
The rules on input, predicates, naming and interfaces follow the PureMath style guide (`WolframInstitute/PureMath`, `GUIDE.md`), the fuller reference where it is readable.

- **Prefer the simplest implementation** that uses built-in Wolfram functions and works in the generic case over heavily customized, safeguarded code.
- **Validity lives in the pattern.** The exported signature says what it accepts (`f[ g_Graph, v_ ]`, `f[ m_?MatrixQ ]`), so a wrong-type call matches nothing and stays unevaluated.
  No input-checking code, no `f::badarg` messages, no `$Failed`, no `Missing`, no `Return`.
  Code below the signature trusts its inputs and lets inner built-ins raise their own errors.
- **A `Failure` is for a computation that started and could not finish** — a step checkable only after starting (a singular matrix met mid-way).
  Write it with `Enclose` and `Confirm*`, which return a `Failure` value; never `Message[...]; $Failed`.
- **A predicate answers `True` or `False`, and never guesses.**
  `False` only on input that is not the thing asked about; a valid input it cannot decide stays unevaluated.
  A predicate is never stricter than the functions it guards: if `GroupOrder[ SymmetricGroup[ 3 ] ]` works, `GroupQ[ SymmetricGroup[ 3 ] ]` is `True`.
- **Prefer duplication over the wrong abstraction.** No non-exported helper unless it is used in several places or is the only way to keep a definition readable.
  Main functions on top, helpers below in order of use.
  Compose at the call site with `Map`, `Fold`, `KeyValueMap`, `Thread`; a long body used once is inlined, however long.
  For an exported symbol the bar is higher still — § *Exported functions*.
- **Functional style.** `Fold`, `Nest`, `Map`, `Apply`, `Select`; listability over `Map`.
  Never `For`, never a list grown by `AppendTo`; a loop only where the functional form clearly hurts speed or memory.
- **`x |-> ...` and `{ x, y } |-> ...`, never `Function[ ... ]`.**
  Prefer inline pure functions over local helpers; longer composed functions are fine.
- **Chained `With`**, one definition block per dependency layer: `With[ { a = ... }, { b = ... }, body ]`.
  Later clauses see earlier bindings, so this is the staged binding of nested `With` without the nesting.
  Do not nest `Module` or `Block`; `Module` is for a genuinely mutable accumulator and a function opens at most one.

### Layout

- Body on a new line after `:=`. No trailing `;` after a top-level definition.
- Spaces inside brackets and around every operator, including `@`, `@@`, `<>`: `f[ x, y ]`, `a + b`, `list[[ i ]]`.
  Blanks and `?` stay attached: `_Integer`, `t_?NumericQ`.
- One statement per line. Never split a binary operator's operands across lines. Lines under 150 characters.
- ASCII only in source: no em dashes, no box-drawing banners, no decorative arrows.
- Formal symbols (`\[FormalX]`) for variables a function puts into its output.

```wolfram
BallVolume[ graph_Graph, center_, radius_Integer ] :=
  VertexCount @ NeighborhoodGraph[ graph, center, radius ]

BallVolume[ graph_Graph, centers_List, radius_Integer ] :=
  Total[ BallVolume[ graph, #, radius ] & /@ centers ]
```

### Naming

- **A name says what the object is**, in full words: `ShortestSeparatingCycle`, not `SSC` or `sepCyc`.
  No abbreviations, contractions, or initials, in exported symbols and in local variables alike.
- Exported symbols: expressive CamelCase, usually two or three words: `FinitelyPresentedGroup`, `SpecialUnitaryGroup`.
- `Find…` for finders, `…Q` for predicates, `$…` for global parameters.
- Local variables: descriptive lowerCamelCase in paclet code (`graph`, not `g`); short names are fine in snippets.
- **Never collide with a `System` symbol** — check `` NameQ[ "System`" <> name ] `` — and do not depend on `` System`Private` `` internals.
- **Built-in and project symbols are treated alike** — same call conventions, neither needing a wrapper the other does not.

### Mathematical objects

When a framework defines mathematical objects, each object is an **inert head** holding only its defining data: `InfraSegment[ p, q ]`, `InfraCircle[ c, "Radius" -> r ]`.
The head computes nothing and carries no rules beyond formatting.
Computation happens only when the object meets the structure it is read in, through ordinary functions: `InfraMeasurement[ g, InfraSegment[ p, q ], "Length" ]`.
This is for mathematical objects, not for every function.

- **No object without a theorem that it is well defined.** If the construction is not faithful on some inputs, the object does not exist there, or says so (`Undetermined`).
- **Parameters are options named for what they are** (`"Radius" -> r`), not positional flags.
- **Abstract operations return objects**, so they compose: the centre of an abstract group is an abstract group, not an element list.
  Operations that depend on a choice of representation require that choice as an argument.
- **Never require a wrapper around what the system already understands.** `SymmetricGroup[ 3 ]` is accepted as a group as it stands.
- **Built-in functions before accessors.** Where a `System` function covers a property (`GroupOrder`), support it rather than standing an `obj[ "Order" ]` beside it.
  A property accessor is fine where the object needs a structure to be evaluated in.
- **A function answers its headline examples.** Bounded by cost is fine; failing the first input a reader tries is not — narrow the name, or do not ship it.

### Exported functions

**Every exported function stands on its own.**
The test it has to pass — whether or not it is ever submitted — is that it could be lifted out of the paclet and published to the Wolfram Function Repository unchanged.
A function that only works with the rest of the package around it is a fragment, not a function.

- **No private helpers unless the definition cannot be read without one.**
  This is § *Code style* applied at the package level: a `PackageScope` helper shared by two exported functions makes both of them unpublishable.
  If the shared thing is worth a name, export it and let it be a function in its own right; if it is needed in exactly one place, it is a `With` binding inside the body, not a symbol in the private context.
- **Everything it needs arrives through its arguments and options.**
  No package-scoped mutable state, no `$Globals` set at load time, no memoized cache living outside the body, no dependence on another module having been loaded first.
- **One symbol, one interface.**
  Dispatch happens in the exported signature, options are declared on it with `Options[ f ] = { ... }` and read with `OptionValue`, and anything else a caller must know goes in `::usage`.
- **Call built-ins, or other exported functions.**
  A repository function may call another `ResourceFunction`, so a cross-call between two exported symbols is fine; a call into the private context is not.
- **Tests go through the public signature only** (§ *Testing*) — which is how a repository submission is tested too.

### Graphics

- `Standard*` colors (`StandardRed`, `StandardBlue`, …) or pastel colors; they read in light and dark mode.
  No hard-coded `White` or `Black` backgrounds.
- Defaults first: no custom styling options like `ImageSize`, no overdone plot styling.
- Highlight graphs with the built-in `VertexStyle` and `EdgeStyle`, or `VertexShapeFunction` and `EdgeShapeFunction`, options of `Graph`.

### Snippets

A snippet, in a notebook or a chat, is a chained `With`: one construction per definition block, literals inline, the display last.

```wolfram
With[
  { g = GridGraph[ { 7, 7 } ] },
  { c = First @ GraphCenter[ g ] },
  { ball = VertexList @ NeighborhoodGraph[ g, c, 2 ] },
  HighlightGraph[ g, ball ] ]
```

### Comments

- **No comments, with one exception:** a line doing mathematics, or an algorithm whose reason a reader cannot get from the code — a non-obvious subtlety, a Wolfram quirk worked around, a deliberate departure from the textbook definition.
- What a symbol *is* goes in its `::usage`, not in a comment above the definition.
  Design prose, usage examples and degenerate-case notes go in the wiki or the tests.
- **No** section dividers, no block comments, no narration of what the next lines do or what a variable holds.
  If a comment is needed to explain a *what*, the code is wrong; rewrite the code, do not annotate it.
- Existing comments in a file are not a licence to add more. When in doubt, leave the comment out.
- **Compose over annotate.** When tempted to write `(* this builds the level-surface subgraph *)` above a five-line block, bind the block to a named local instead: `With[ { levelSurface = ... }, ... ]`.
  The name documents the math; the comment becomes redundant.

### Performance

- **Preserve existing optimizations.** When refactoring, keep load-bearing performance code (memoized helpers, precomputed distance matrices, sparse representations, compiled inner kernels) intact even when its justification isn't documented.
  The goal is to strip *clutter*, not *speed*.
  If you must touch a fast path, add a one-line comment recording why it was fast.
- **No premature optimization.** No memoization, compilation, sparse-matrix conversion, or other tricks unless you measured a problem first.
  When you do add one, leave a one-line comment naming the operation that was hot.

### Testing

- **Tests assert math, not internals.** Organize a test file around the invariants the construction should satisfy (e.g. for a midpoint `m` of `a` and `b`: `d(a, m) == d(m, b)` and `d(a, m) + d(m, b) == d(a, b)`), not around `$Failed`-shape checks, wrapper-head pattern matches, or option-parsing branches.
  If a `VerificationTest` would fail only when the implementation changes shape — without any mathematical statement having become false — delete it.
- One `VerificationTest` per behavior; small deterministic graphs (`PathGraph[ Range[ 5 ] ]`, `CycleGraph[ 6 ]`, `GridGraph[ { 3, 3 } ]`, `PetersenGraph[]`) when relevant.

### Knowledge Base (Wiki)

When the project has a `Wiki/`:

- **One article per mathematical concept, not per exported symbol.** An article on a concept covers its definition, candidate methods, relationships, and open questions — not the function's signature, options, and accessor lists (those live in `::usage` and in any `APIConventions` article the project maintains).
  If you find yourself writing one article per `Find*` / `*Q` symbol, stop — you are duplicating the function reference.
  Merge into the underlying concept and link via `## See also`.

### Commits

- **Conventional Commits.** Subject line is `type(scope): subject` — e.g. `fix(curvature): correct Ollivier sign`.
  Types: `feat fix docs style refactor perf test build ci chore revert`; scope optional; `!` after the type marks a breaking change.
  Keep the subject ≤ 72 chars, imperative mood, no trailing period.
- A `.githooks/commit-msg` hook enforces this and rejects non-conforming subjects (`core.hooksPath=.githooks`).
  If a commit is rejected, rewrite the subject to match — do not bypass with `--no-verify`.
