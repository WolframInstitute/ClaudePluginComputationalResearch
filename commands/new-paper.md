Add a paper to `Research/` using the `new-paper` skill.

If inside a project directory, use `Research/` here.
Otherwise ask where.
A project that already has a `Paper/` folder keeps using it; say that `Research/` is the new place and move nothing.
Name the paper in `CapitalizedWords` — that becomes its filename — and if `Research/` already holds a paper, ask whether this one joins it, sharing the preamble and bibliography, or gets its own subfolder.
Default is LaTeX (amsart, biblatex with biber, shared macros.sty).
Pass `--typst` (or if the user says "typst") to scaffold a Typst paper instead.
If Wiki/Resources/ exists, seed references.bib from existing papers.

After scaffolding, act as an editor on the user-owned document — import material at a requested location, fix a paragraph, add figures/code/tables — but do not author paper content unprompted.
