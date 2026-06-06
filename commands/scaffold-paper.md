Scaffold a Paper/ folder with LaTeX or Typst templates using the `scaffold-paper` skill.

If inside a project directory, create Paper/ here.
Otherwise ask where.
Default is LaTeX (amsart, biblatex with biber, shared macros.sty).
Pass `--typst` (or if the user says "typst") to scaffold a Typst paper (main.typ + macros.typ) instead.
If Wiki/Resources/ exists, seed references.bib from existing papers.

After scaffolding, act as an editor on the user-owned document — import material at a requested location, fix a paragraph, add figures/code/tables — but do not author paper content unprompted.
