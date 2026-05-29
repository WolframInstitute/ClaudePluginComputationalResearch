#!/usr/bin/env bash
# scaffold-paper.sh — Create Paper/ directory with LaTeX or Typst templates
#
# Usage: scaffold-paper.sh [--typst|--latex] <ProjectDir> [Title] [Author] [Email]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/new-project/assets"

FORMAT="latex"
case "${1:-}" in
    --typst) FORMAT="typst"; shift ;;
    --latex) FORMAT="latex"; shift ;;
esac

if [ $# -lt 1 ]; then
    echo "Usage: scaffold-paper.sh [--typst|--latex] <ProjectDir> [Title] [Author] [Email]" >&2
    exit 1
fi

PROJECT_DIR="$1"
TITLE="${2:-Working Title}"
AUTHOR_NAME="${3:-Pavel H\'ajek}"
AUTHOR_EMAIL="${4:-p135246@gmail.com}"

PAPER_DIR="$PROJECT_DIR/Paper"
ABSTRACT="TODO"

mkdir -p "$PAPER_DIR/figures"

# ── references.bib (shared by both formats) ──
cat > "$PAPER_DIR/references.bib" << 'EOF'
% References
EOF

if [ "$FORMAT" = "typst" ]; then
    cp "$ASSETS_DIR/macros_template.typ" "$PAPER_DIR/macros.typ"
    sed \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{ABSTRACT}}|$ABSTRACT|g" \
      -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
      -e "s|{{EMAIL}}|$AUTHOR_EMAIL|g" \
      "$ASSETS_DIR/main_template.typ" > "$PAPER_DIR/main.typ"

    echo "Created: $PAPER_DIR/ (Typst)"
    echo "  main.typ          — document (#import macros.typ)"
    echo "  macros.typ        — shared preamble and macros"
    echo "  references.bib    — bibliography"
    echo "  figures/          — figures"
    echo ""
    echo "Compile: cd $PAPER_DIR && typst compile main.typ"
else
    cp "$ASSETS_DIR/macros_template.sty" "$PAPER_DIR/macros.sty"
    sed \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{ABSTRACT}}|$ABSTRACT|g" \
      -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
      -e "s|{{EMAIL}}|$AUTHOR_EMAIL|g" \
      "$ASSETS_DIR/main_template.tex" > "$PAPER_DIR/main.tex"
    cp "$ASSETS_DIR/latexmkrc_template" "$PAPER_DIR/.latexmkrc"

    echo "Created: $PAPER_DIR/ (LaTeX)"
    echo "  main.tex          — article (amsart + biblatex)"
    echo "  macros.sty        — shared preamble and macros"
    echo "  references.bib    — bibliography"
    echo "  figures/          — figures"
    echo "  .latexmkrc        — latexmk configuration"
    echo ""
    echo "Compile: cd $PAPER_DIR && latexmk -pdf main.tex"
fi
