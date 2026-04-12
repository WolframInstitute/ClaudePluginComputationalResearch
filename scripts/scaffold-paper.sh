#!/usr/bin/env bash
# scaffold-paper.sh — Create Paper/ directory with LaTeX templates
#
# Usage: scaffold-paper.sh <ProjectDir> [Title] [Author] [Email]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/project-init/assets"

if [ $# -lt 1 ]; then
    echo "Usage: scaffold-paper.sh <ProjectDir> [Title] [Author] [Email]" >&2
    exit 1
fi

PROJECT_DIR="$1"
TITLE="${2:-Working Title}"
AUTHOR_NAME="${3:-Pavel H\'ajek}"
AUTHOR_EMAIL="${4:-p135246@gmail.com}"

PAPER_DIR="$PROJECT_DIR/Paper"

# ── 1. Directories ───────────────────────────────────────────────────────

mkdir -p "$PAPER_DIR/figures"

# ── 2. macros.sty ────────────────────────────────────────────────────────

cp "$ASSETS_DIR/macros_template.sty" "$PAPER_DIR/macros.sty"

# ── 3. main.tex ──────────────────────────────────────────────────────────

ABSTRACT="TODO"

sed \
  -e "s|{{TITLE}}|$TITLE|g" \
  -e "s|{{ABSTRACT}}|$ABSTRACT|g" \
  -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
  -e "s|{{EMAIL}}|$AUTHOR_EMAIL|g" \
  "$ASSETS_DIR/main_template.tex" > "$PAPER_DIR/main.tex"

# ── 4. references.bib ───────────────────────────────────────────────────

cat > "$PAPER_DIR/references.bib" << 'EOF'
% References
EOF

# ── 5. .latexmkrc ───────────────────────────────────────────────────────

cp "$ASSETS_DIR/latexmkrc_template" "$PAPER_DIR/.latexmkrc"

# ── 6. Summary ───────────────────────────────────────────────────────────

echo "Created: $PAPER_DIR/"
echo "  main.tex          — article (amsart + biblatex)"
echo "  macros.sty        — shared preamble and macros"
echo "  references.bib    — bibliography"
echo "  figures/           — figures"
echo "  .latexmkrc         — latexmk configuration"
echo ""
echo "Compile: cd $PAPER_DIR && latexmk -pdf main.tex"
