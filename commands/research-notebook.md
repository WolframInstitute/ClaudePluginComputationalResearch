Build a research notebook on the given topic using the `research-notebook` skill.

A mathematics paper published as a Wolfram notebook: an introduction stating the results, then sections in the order the mathematics needs, each mixing definitions, examples, claims, proofs and remarks. Every definition is followed by an Example — a few lines of plain code a reader can copy and change, answering with one bare graphic. Statements, equations and sections are numbered by the front end and cited by tag; no number is typed into the source. Statements use MathNotebook environments on the PlainArticle stylesheet and are written to translate directly to Lean.

The source of truth is `NotebooksLLM/<Topic>.md`, and generation is one-way: the user reads the `.nb` and edits the `.md`. A per-cell fingerprint detects an edit made in the `.nb` and stops the build rather than overwrite it. The evaluated notebook is deployed public to the Wolfram Cloud and linked from the repo README's "Research Notebooks" table.

Pass the topic as argument (e.g., `/research-notebook displacement algebra on graphs`). Otherwise infer it from the current work item or ask.
