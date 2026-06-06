Create or modify a Wolfram notebook using the `new-notebook` skill.

If arguments are provided (e.g., `/new-notebook graph curvature examples`), create a notebook on that topic.
Otherwise ask what the notebook should cover.

Uses the Markdown→notebook pipeline via the official Wolfram MCP.
Creates the NotebooksLLM/*.md source and generates NotebooksLLM/*.nb alongside it (the plain Notebooks/ folder is reserved for user-authored notebooks, never touched).
