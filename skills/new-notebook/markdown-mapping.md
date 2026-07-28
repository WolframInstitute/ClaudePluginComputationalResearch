# new-notebook: markdown-to-cell mapping

How source Markdown becomes notebook cells, plus composition patterns.
The post-processing that enforces the final styles is in [pipeline-builtin.md](pipeline-builtin.md).

## Headings → notebook structure

The WL-15 markdown importer maps `#`→`Title`, `##`→`Chapter`, `###`→`Section`, `####`→`Subsection`.
That extra `Chapter` level is inconsistent with the rest of the corpus (which uses `Title`/`Section`/`Subsection`), so the post-processing **shifts every heading down one level** immediately after `cells = First[nb]`.
The **final** styles a source author should expect:

| Markdown | Importer style | Final style (after shift) | Notebook Role |
|----------|----------------|---------------------------|---------------|
| `# Title` | `"Title"` | `"Title"` | Notebook title (use once, at top) |
| `## Section` | `"Chapter"` | `"Section"` | Major division |
| `### Subsection` | `"Section"` | `"Subsection"` | Subsection heading |
| `#### Subsubsection` | `"Subsection"` | `"Subsubsection"` | Subsubsection heading |

So author `##` headings render as `"Section"`, not `"Chapter"`.
A `**[ LLM Generated ]**` marker line in the source (the documented convention) is imported as a bold `"Text"` cell and normalized to a single `"Subtitle"` cell under the `"Title"` by the marker rules that run alongside the heading shift.

## Text and formatting

| Markdown | Result |
|----------|--------|
| Plain paragraph | `Cell["...", "Text"]` |
| `**bold**` | `StyleBox["...", FontWeight->Bold]` |
| `*italic*` | `StyleBox["...", FontSlant->Italic]` |
| inline code (single backtick) | `Cell["...", "InlineCode"]` within TextData |
| `[text](url)` | Clickable hyperlink (ButtonBox) |
| `> blockquote` | Text cell with left border frame |

## Lists

| Markdown | Cell Style |
|----------|-----------|
| `- item` | `"Item"` |
| `  - subitem` (2-space indent) | `"Subitem"` |
| `1. first` | `"ItemNumbered"` |

## Math (LaTeX)

| Markdown | Result |
|----------|--------|
| `$...$` | Inline math — `InlineMath` within TextData |
| `$$...$$` | Display math — `DisplayFormula` cell |

**Use math liberally.** Definitions, theorems, formulas, variable references → LaTeX.

**Escaping in Wolfram strings:** double all backslashes in LaTeX math:

```wolfram
md = "The curvature $\\kappa(x,y)$ is defined as\n\n$$\\kappa(x,y) = 1 - \\frac{W_1(\\mu_x, \\mu_y)}{d(x,y)}$$\n\n";
```

Common LaTeX commands that work: `\frac`, `\sum`, `\int`, `\partial`, `\mathbb`, `\mathcal`, `\alpha`–`\omega`, `\in`, `\subset`, `\to`, `\mapsto`, `\leq`, `\geq`, `\neq`, `\infty`, `\ldots`, `\cdots`, `\text`.

**Wolfram notation vs LaTeX in text cells:**

- **Simple symbols** (Greek, relations, arrows): Wolfram `\[Alpha]`, `\[Element]` etc. work — they become Unicode.
- **Structural math** (fractions, sub/superscripts): use LaTeX `$\frac{a}{b}$`, `$x_i$`.
- **Blackboard bold**: use LaTeX `$\mathbb{R}$`.

## Code blocks

| Markdown fence tag | Cell Style | Purpose |
|----------|-----------|---------|
| `wolfram` | `"Input"` | Evaluatable Wolfram code |
| (no tag) | `"Program"` → post-processed to `"CodeText"` | Display-only code |

## Tables

Standard Markdown tables become interactive Tabular/TableView cells.

## Long notebook pattern

For notebooks with > ~30 cells, build per-section chunks:

```wolfram
section1 = StringJoin["## Section 1\n\n", "Text.\n\n", fence, "wolfram\n...\n", fence, "\n\n"];
section2 = StringJoin["## Section 2\n\n", "Text.\n\n", fence, "wolfram\n...\n", fence, "\n\n"];
md = StringJoin["# Title\n\n", section1, section2];
```

## Content best practices

- One `# Title` at the top — only once
- `## Setup` for package loads and configuration (becomes initialization cells)
- One logical operation per `wolfram` code block
- Narrative Text paragraphs between code blocks
- Bullet lists for enumerated points
- Tables for structured comparisons
- Untagged fences for pseudocode or expected output (become CodeText)
- Bold for key terms
- Inline math for variables and short formulas
- Display math for definitions and important equations
