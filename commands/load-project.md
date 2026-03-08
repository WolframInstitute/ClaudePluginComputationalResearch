---
allowed-tools:
  - Read
  - Glob
  - Bash
---
Load and summarize the context of a research project.

$ARGUMENTS is an optional path to the project directory. If not provided, use the
current working directory.

Steps:
1. Read `CLAUDE.md` and summarize: project name, topic, goals, code structure.
2. List all `.nb` files (notebooks) present at the project root.
3. List `Code/` files and their sizes.
4. Count the number of PDFs and `.nb` files in `Resources/` and report whether `Resources1.nb` exists.
5. Report the line counts of `Article/notes1.tex` and `Article/article1.tex`
   (warn if notes is approaching the 300-line threshold for versioning).
6. Based on the above, suggest 2–3 concrete next steps for the project.

Format the output as a concise project status report.
