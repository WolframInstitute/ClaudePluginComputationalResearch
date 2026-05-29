#!/usr/bin/env bash
# scaffold-notes.sh — Create Notes/ directory with a running LaTeX or Typst notes file
#
# Usage: scaffold-notes.sh [--typst|--latex] <ProjectDir> [Title] [Author]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/new-project/assets"

FORMAT="latex"
case "${1:-}" in
    --typst) FORMAT="typst"; shift ;;
    --latex) FORMAT="latex"; shift ;;
esac

if [ $# -lt 1 ]; then
    echo "Usage: scaffold-notes.sh [--typst|--latex] <ProjectDir> [Title] [Author]" >&2
    exit 1
fi

PROJECT_DIR="$1"
TITLE="${2:-Notes}"
AUTHOR_NAME="${3:-Pavel H\'ajek}"

NOTES_DIR="$PROJECT_DIR/Notes"

mkdir -p "$NOTES_DIR/figures"

if [ "$FORMAT" = "typst" ]; then
    cp "$ASSETS_DIR/macros_template.typ" "$NOTES_DIR/macros.typ"
    sed \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
      "$ASSETS_DIR/notes_template.typ" > "$NOTES_DIR/notes.typ"

    echo "Created: $NOTES_DIR/ (Typst)"
    echo "  notes.typ         — running notes file (#import macros.typ)"
    echo "  macros.typ        — shared preamble and macros"
    echo "  figures/          — figures"
    echo ""
    echo "Compile: cd $NOTES_DIR && typst compile notes.typ"
else
    cp "$ASSETS_DIR/macros_template.sty" "$NOTES_DIR/macros.sty"
    sed \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
      "$ASSETS_DIR/notes_template.tex" > "$NOTES_DIR/notes.tex"
    cp "$ASSETS_DIR/latexmkrc_template" "$NOTES_DIR/.latexmkrc"

    echo "Created: $NOTES_DIR/ (LaTeX)"
    echo "  notes.tex         — running notes file (article + macros)"
    echo "  macros.sty        — shared preamble and macros"
    echo "  figures/          — figures"
    echo "  .latexmkrc        — latexmk configuration"
    echo ""
    echo "Compile: cd $NOTES_DIR && latexmk -pdf notes.tex"
fi
