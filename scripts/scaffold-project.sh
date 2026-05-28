#!/usr/bin/env bash
# scaffold-project.sh — Create Wolfram research project directory structure
#
# Usage: scaffold-project.sh <ProjectName> ["Topic"] [output-dir] ["Author Name"] ["email"] ["CodeDir"]
#
# Called by Claude during project-init skill execution.
# Claude handles notebook creation and paper downloading via MCP separately.
#
# output-dir:   base directory where <ProjectName>/ will be created.
#               Defaults to current directory. In Cowork mode, pass the
#               mounted workspace path (e.g. /sessions/.../mnt/MyFolder/).
# Author Name:  for \author{} in LaTeX templates. Defaults to "Author".
# email:        for \email{} in LaTeX templates. Defaults to empty.
# CodeDir:      name of the code directory. Defaults to "Code".

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/project-init/assets"

if [ $# -lt 1 ]; then
  echo "Usage: scaffold-project.sh <ProjectName> [\"Topic description\"] [output-dir] [\"Author\"] [\"email\"] [\"CodeDir\"]" >&2
  exit 1
fi

PROJECT_NAME="$1"
TOPIC_DESCRIPTION="${2:-A computational research project.}"
OUTPUT_DIR="${3:-.}"
AUTHOR_NAME="${4:-Pavel H\'ajek}"
AUTHOR_EMAIL="${5:-p135246@gmail.com}"
CODE_DIR="${6:-Code}"
TODAY=$(date +%Y-%m-%d)

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# ── 1. Directories ─────────────────────────────────────────────────────────

mkdir -p "$PROJECT_NAME/$CODE_DIR"
mkdir -p "$PROJECT_NAME/Resources"
mkdir -p "$PROJECT_NAME/Scripts"
mkdir -p "$PROJECT_NAME/Work"
echo "Created directories: $PROJECT_NAME/{$CODE_DIR,Resources,Scripts,Work}"

sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
  "$ASSETS_DIR/work_readme_template.md" > "$PROJECT_NAME/Work/README.md"
echo "Created: $PROJECT_NAME/Work/README.md"

# ── 2. Tools.wl ───────────────────────────────────────────────────────────

cp "$ASSETS_DIR/tools_starter.wl" "$PROJECT_NAME/$CODE_DIR/Tools.wl"
echo "Created: $PROJECT_NAME/$CODE_DIR/Tools.wl"

# ── 3. CLAUDE.md ──────────────────────────────────────────────────────────
# Topic-specific code files (<Topic>.wl, <Topic>Visualization.wl) are created
# by the add-topic skill, not by this script.

sed \
  -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
  -e "s|{{TOPIC_DESCRIPTION}}|$TOPIC_DESCRIPTION|g" \
  -e "s|{{CODE_DIR}}|$CODE_DIR|g" \
  -e "s|{{GOALS}}|1. Understand the mathematical structure of $TOPIC_DESCRIPTION\n2. Develop computational tools in Wolfram Language\n3. Visualize and verify results computationally|g" \
  "$ASSETS_DIR/claude_template.md" > "$PROJECT_NAME/CLAUDE.md"
printf '\n' >> "$PROJECT_NAME/CLAUDE.md"
cat "$ASSETS_DIR/code_style_template.md" >> "$PROJECT_NAME/CLAUDE.md"
echo "Created: $PROJECT_NAME/CLAUDE.md"

# ── 4. Scripts ────────────────────────────────────────────────────────────

cp "$SCRIPT_DIR/recover_resources.sh" "$PROJECT_NAME/Scripts/recover_resources.sh"
cp "$SCRIPT_DIR/generate_notebooks.wls" "$PROJECT_NAME/Scripts/generate_notebooks.wls"
cp "$SCRIPT_DIR/publish_notebooks.wls" "$PROJECT_NAME/Scripts/publish_notebooks.wls"
chmod +x "$PROJECT_NAME/Scripts/recover_resources.sh"
echo "Created: $PROJECT_NAME/Scripts/{recover_resources.sh,generate_notebooks.wls,publish_notebooks.wls}"

# ── 5. Summary ────────────────────────────────────────────────────────────

echo ""
echo "=== Project scaffolded: $PROJECT_NAME/ ==="
echo ""
echo "  $CODE_DIR/"
echo "    Tools.wl           — shared general utilities"
echo "  Resources/            — reference PDFs and notebooks"
echo "  Scripts/"
echo "    recover_resources.sh — rebuild Resources/ from wiki ## Recover sections"
echo "  Work/"
echo "    README.md            — work-item board (spec / tasks / progress per effort)"
echo "  CLAUDE.md             — project context for future Claude sessions"
echo ""
echo "Next: Claude will initialize Wiki/, optionally create Paper/, and download papers."
