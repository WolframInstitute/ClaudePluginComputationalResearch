#!/usr/bin/env bash
# scaffold-paper.sh — Create Paper/ directory with LaTeX or Typst templates
#
# Usage: scaffold-paper.sh [--typst|--latex] [--force] <ProjectDir> [Title] [Operator] [Email] [Model] [Freedom] [Prompt] [Date]
#
# The author of the document is the MODEL. The operator is the person who ran the
# session and is named in the footnote, not as an author, together with the
# freedom the model had -- Directed, Guided or Open exploration, set in bold --
# and a one-sentence summary of the instructions it worked under.
#
# Date is the date the document was generated, written out; it is baked in rather
# than left to \today, which re-dates the paper on every compile.
#
# An existing main.tex / main.typ / macros / references.bib is NOT overwritten
# without --force: the target may be a paper someone is writing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/new-project/assets"

FORMAT="latex"
FORCE=0
while [ $# -gt 0 ]; do
    case "$1" in
        --typst) FORMAT="typst"; shift ;;
        --latex) FORMAT="latex"; shift ;;
        --force) FORCE=1; shift ;;
        *) break ;;
    esac
done

if [ $# -lt 1 ]; then
    echo "Usage: scaffold-paper.sh [--typst|--latex] [--force] <ProjectDir> [Title] [Operator] [Email] [Model] [Freedom] [Prompt] [Date]" >&2
    exit 1
fi

PROJECT_DIR="$1"
TITLE="${2:-Working Title}"
OPERATOR="${3:-Pavel H\'ajek}"
OPERATOR_EMAIL="${4:-p135246@gmail.com}"
MODEL="${5:-Claude}"
FREEDOM="${6:-Open exploration}"
PROMPT="${7:-TODO}"
DATE="${8:-$(date +"%d %B %Y" | sed 's/^0//')}"

PAPER_DIR="$PROJECT_DIR/Paper"
ABSTRACT="TODO"

# Never overwrite a document someone is writing.
if [ "$FORCE" -ne 1 ]; then
    for existing in main.tex main.typ macros.sty macros.typ references.bib; do
        if [ -e "$PAPER_DIR/$existing" ]; then
            echo "scaffold-paper: $PAPER_DIR/$existing exists — refusing to overwrite." >&2
            echo "  Give a different <ProjectDir>, or pass --force to replace the scaffold." >&2
            exit 1
        fi
    done
fi

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
      -e "s|{{MODEL}}|$MODEL|g" \
      -e "s|{{OPERATOR}}|$OPERATOR|g" \
      -e "s|{{FREEDOM}}|$FREEDOM|g" \
      -e "s|{{PROMPT}}|$PROMPT|g" \
      -e "s|{{EMAIL}}|$OPERATOR_EMAIL|g" \
      -e "s|{{DATE}}|$DATE|g" \
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
      -e "s|{{MODEL}}|$MODEL|g" \
      -e "s|{{OPERATOR}}|$OPERATOR|g" \
      -e "s|{{FREEDOM}}|$FREEDOM|g" \
      -e "s|{{PROMPT}}|$PROMPT|g" \
      -e "s|{{EMAIL}}|$OPERATOR_EMAIL|g" \
      -e "s|{{DATE}}|$DATE|g" \
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
