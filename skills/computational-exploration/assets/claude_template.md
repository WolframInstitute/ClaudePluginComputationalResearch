# {{PROJECT_NAME}}

## Project goals

{{GOALS}}

## Research approaches

- **Wolfram-model mapping**: Identify the core structures of the topic (objects, relations, dynamics) and map them to hypergraph rewriting rules, multiway systems, or other Wolfram-model primitives. What emerges from simple rules?
- **Computational / constructive**: Build explicit models in Wolfram Language, run experiments, generate and visualize data. Push this before introducing analytical tools.
- **Analytical / theoretical**: Use mathematical analysis, approximations, or formal reasoning to explain patterns found computationally.

The central question is always: what does the Wolfram-model perspective add, and what new structures or predictions emerge?

## Code structure

- `Code/Tools.wl` — shared general utilities

Each topic scope can have:
- `Code/<Topic>.wl` — core functions (add-topic)
- `Code/<Topic>Visualization.wl` — visualization (add-topic)
- `Code/<Topic>Experiment.wl` — experiments (make-experiment)
- `Code/<Topic>Test.wl` — tests with VerificationTest + TestReport (make-test)

Initial topic: `{{PROJECT_NAME}}`

Notebooks: `<Topic>1.nb` per topic, `Test1.nb` for tests.

## Resources

`Resources/` — reference papers and community notebooks, named as `Author_Year_Title.pdf` or `.nb`
`Resources1.nb` — paper summaries notebook (one section per paper)

## Notes

`Article/article1.tex` — LaTeX article scaffold (user writes here, drawing from notes1.tex)
`Article/notes1.tex` — article-form working notes (Claude writes here when asked; source material for the article)
`Article/references.bib` — BibTeX references

## Loading code

```wolfram
SetDirectory[NotebookDirectory[]]
Get["Code/Tools.wl"]
Get["Code/{{PROJECT_NAME}}.wl"]
Get["Code/{{PROJECT_NAME}}Visualization.wl"]
```
