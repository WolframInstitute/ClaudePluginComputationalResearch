#!/usr/bin/env bash
# scaffold-journal.sh — Create Journal/ directory with a running LaTeX or Typst scientific journal
#
# Usage: scaffold-journal.sh [--typst|--latex] <ProjectDir> [Title] [Author]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/new-project/assets"

FORMAT="latex"
case "${1:-}" in
    --typst) FORMAT="typst"; shift ;;
    --latex) FORMAT="latex"; shift ;;
esac

if [ $# -lt 1 ]; then
    echo "Usage: scaffold-journal.sh [--typst|--latex] <ProjectDir> [Title] [Author]" >&2
    exit 1
fi

PROJECT_DIR="$1"
TITLE="${2:-Research Journal}"
AUTHOR_NAME="${3:-Pavel H\'ajek}"

JOURNAL_DIR="$PROJECT_DIR/Journal"

mkdir -p "$JOURNAL_DIR/entries" "$JOURNAL_DIR/figures"

if [ "$FORMAT" = "typst" ]; then
    cp "$ASSETS_DIR/macros_template.typ" "$JOURNAL_DIR/macros.typ"
    sed \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
      "$ASSETS_DIR/journal_template.typ" > "$JOURNAL_DIR/journal.typ"
    cat > "$JOURNAL_DIR/references.bib" << 'EOF'
% Journal bibliography — entries added via the cite skill
EOF

    echo "Created: $JOURNAL_DIR/ (Typst)"
    echo "  journal.typ       — master file (#import macros.typ, #bibliography)"
    echo "  macros.typ        — shared preamble and macros"
    echo "  references.bib    — bibliography (read natively by Typst)"
    echo "  entries/          — one day-file per day (#include into journal.typ)"
    echo "  figures/          — figures"
    echo ""
    echo "Compile: cd $JOURNAL_DIR && typst compile journal.typ"
else
    cp "$ASSETS_DIR/macros_template.sty" "$JOURNAL_DIR/macros.sty"
    sed \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
      "$ASSETS_DIR/journal_template.tex" > "$JOURNAL_DIR/journal.tex"
    cp "$ASSETS_DIR/latexmkrc_template" "$JOURNAL_DIR/.latexmkrc"
    cat > "$JOURNAL_DIR/references.bib" << 'EOF'
% Journal bibliography — entries added via the cite skill
EOF

    echo "Created: $JOURNAL_DIR/ (LaTeX)"
    echo "  journal.tex       — master file (article + macros, \\printbibliography)"
    echo "  macros.sty        — shared preamble and macros"
    echo "  references.bib    — bibliography (biblatex format)"
    echo "  entries/          — one day-file per day (\\input into journal.tex)"
    echo "  figures/          — figures"
    echo "  .latexmkrc        — latexmk configuration"
    echo ""
    echo "Compile: cd $JOURNAL_DIR && latexmk -pdf journal.tex"
fi
