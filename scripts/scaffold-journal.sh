#!/usr/bin/env bash
# scaffold-journal.sh — Create Journal/ directory with a running LaTeX or Typst scientific journal
#
# Usage: scaffold-journal.sh [--typst|--latex] <ProjectDir> [Title] [Author]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/project-create/assets"

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

# Create only missing files; even a concurrent creator must not be overwritten.
create_if_missing() {
    local destination="$1"
    shift
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        echo "Kept: $destination"
        return 0
    fi
    ( set -o noclobber; "$@" > "$destination" )
}

if [ "$FORMAT" = "typst" ]; then
    create_if_missing "$JOURNAL_DIR/macros.typ" cat "$ASSETS_DIR/macros_template.typ"
    create_if_missing "$JOURNAL_DIR/journal.typ" sed \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
      "$ASSETS_DIR/journal_template.typ"
    create_if_missing "$JOURNAL_DIR/references.bib" printf '%s\n' '% Journal bibliography — entries added via the paper-cite skill'

    echo "Journal ready: $JOURNAL_DIR/ (Typst)"
    echo "  journal.typ       — master file (#import macros.typ, #bibliography)"
    echo "  macros.typ        — shared preamble and macros"
    echo "  references.bib    — bibliography (read natively by Typst)"
    echo "  entries/          — one day-file per day (#include into journal.typ)"
    echo "  figures/          — figures"
    echo ""
    echo "Compile: cd $JOURNAL_DIR && typst compile journal.typ"
else
    create_if_missing "$JOURNAL_DIR/macros.sty" cat "$ASSETS_DIR/macros_template.sty"
    create_if_missing "$JOURNAL_DIR/journal.tex" sed \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
      "$ASSETS_DIR/journal_template.tex"
    create_if_missing "$JOURNAL_DIR/.latexmkrc" cat "$ASSETS_DIR/latexmkrc_template"
    create_if_missing "$JOURNAL_DIR/references.bib" printf '%s\n' '% Journal bibliography — entries added via the paper-cite skill'

    echo "Journal ready: $JOURNAL_DIR/ (LaTeX)"
    echo "  journal.tex       — master file (article + macros, \\printbibliography)"
    echo "  macros.sty        — shared preamble and macros"
    echo "  references.bib    — bibliography (biblatex format)"
    echo "  entries/          — one day-file per day (\\input into journal.tex)"
    echo "  figures/          — figures"
    echo "  .latexmkrc        — latexmk configuration"
    echo ""
    echo "Compile: cd $JOURNAL_DIR && latexmk -pdf journal.tex"
fi
