#!/bin/bash
# PreToolUse hook: block direct Read calls on .nb files.
# Claude Code delivers the tool call as JSON on stdin ({"tool_name": ..., "tool_input": {...}});
# a block is exit 2 with the message on stderr. Malformed input fails open (exit 0).
file_path=$(python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
if [[ "$file_path" == *.nb ]]; then
  {
    echo "BLOCKED: Do not read .nb files directly — raw notebook format is not useful in context."
    echo "Use notebook-create with native ReadNotebook or focused cell/option inspection in the Wolfram kernel."
    echo "For edits, patch the saved notebook and preserve unrelated cells, options and human authorship."
    echo "A requested Markdown export is a separate, potentially lossy output; do not re-import it over the .nb."
  } >&2
  exit 2
fi
exit 0
