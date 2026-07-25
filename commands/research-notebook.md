Build a research notebook on the given topic using the `research-notebook` skill.

A concise, mathematically precise research document as a cloud-published Wolfram notebook: definitions first, then the strongest defensible conjectures each backed by computed evidence rendered as graphics, function demonstrations titled by the literal code, an enumerated list of further research questions, and a cited literature section. Statements use MathNotebook environments and are written to translate directly to Lean.

The source of truth is `NotebooksLLM/<Topic>.md`, kept in two-way sync with the `.nb` — user edits in the notebook are folded back into the source, never overwritten. The evaluated notebook is deployed public to the Wolfram Cloud and linked from the repo README's "Research Notebooks" table.

Pass the topic as argument (e.g., `/research-notebook displacement algebra on graphs`). Otherwise infer it from the current work item or ask.
