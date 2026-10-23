Create, edit or convert a Wolfram notebook using the `notebook-create` skill.

Interpret `$ARGUMENTS` as the source or notebook path, operation and requested scope.
For a new notebook, follow the creation pipeline and artifact placement rules.
For an existing notebook, make only the requested edits through the notebook-aware workflow, preserving human changes.
For a notebook-to-Markdown request, export only; do not regenerate the notebook or begin a revision round.
Ask for the target or operation only when the request and current context do not identify it.
