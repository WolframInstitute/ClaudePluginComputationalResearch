Create or modify a Wolfram notebook using the `new-notebook` skill.

If arguments are provided (e.g., `/new-notebook graph curvature examples`), create a notebook on that topic.
Otherwise ask what the notebook should cover.

Uses the Markdown→notebook pipeline via the official Wolfram MCP.
Creates the Markdown source and generates the .nb alongside it, sharing one dated stem: in Code/ for a document the user will keep working on, in Code/Artifacts/ for a one-off (the default when the request does not say). No file is ever overwritten.
