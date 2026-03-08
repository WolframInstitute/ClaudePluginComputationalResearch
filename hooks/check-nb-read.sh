#!/bin/bash
# PreToolUse hook: block direct Read calls on .nb files.
# Arguments: $1 = tool name, $2 = tool input as JSON string
if [ "$1" = "Read" ]; then
  file_path=$(echo "$2" | python3 -c "import sys,json; print(json.load(sys.stdin).get('file_path',''))" 2>/dev/null)
  if [[ "$file_path" == *.nb ]]; then
    echo "BLOCKED: Do not read .nb files directly — raw notebook format is not useful in context."
    echo "Use the modify-notebook skill instead:"
    echo "  ExportString[Import[\"$file_path\"], \"Markdown\"] via the Wolfram MCP"
    echo "This returns editable Markdown. Then make changes and re-import."
    exit 2
  fi
fi
