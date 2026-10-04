#!/usr/bin/env bash
# scaffold-paper.sh — Add a paper to Research/, with LaTeX or Typst templates
#
# Usage: scaffold-paper.sh [--typst|--latex] [--name <Name>] [--subfolder] [--force] \
#            <ProjectDir> [Title] [Operator] [Email] [Model] [Freedom] [Prompt] [Date]
#
# A paper is a document in progress: it lives in Research/ beside the research
# notebooks and notes, never in Artifacts/. A project that already has a Paper/
# folder keeps using it, and the script says Research/ is the new place; nothing
# is moved. --name gives this paper its own source file; without it the file is
# main.tex, which is what a first paper usually wants.
#
#   default      Research/<Name>.tex, sharing Research/macros.sty and Research/references.bib
#   --subfolder  Research/<Name>/<Name>.tex, with its own macros and bibliography
#
# The skill asks the user which of the two when Research/ already holds a paper;
# it does not guess.
#
# The author of the document is the MODEL. The operator is the person who ran the
# session and is named in the footnote, not as an author, together with the
# freedom the model had -- Directed, Guided or Open exploration, set in bold --
# and a one-sentence summary of the instructions it worked under.
#
# Date is the date the document was generated, written out; it is baked in rather
# than left to \today, which re-dates the paper on every compile.
#
# An existing source file is NEVER overwritten without --force: the target may be
# a paper someone is writing. Shared macros.sty / references.bib are left alone
# when they already exist, so a second paper joins the first rather than
# replacing its preamble.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/new-project/assets"

FORMAT="latex"
FORCE=0
SUBFOLDER=0
NAME="main"
while [ $# -gt 0 ]; do
    case "$1" in
        --typst) FORMAT="typst"; shift ;;
        --latex) FORMAT="latex"; shift ;;
        --force) FORCE=1; shift ;;
        --subfolder) SUBFOLDER=1; shift ;;
        --name) NAME="${2:?--name needs a value}"; shift 2 ;;
        *) break ;;
    esac
done

if [ $# -lt 1 ]; then
    echo "Usage: scaffold-paper.sh [--typst|--latex] [--name <Name>] [--subfolder] [--force] <ProjectDir> [Title] [Operator] [Email] [Model] [Freedom] [Prompt] [Date]" >&2
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

PAPER_DIR="$PROJECT_DIR/Research"
if [ -d "$PROJECT_DIR/Paper" ]; then
    PAPER_DIR="$PROJECT_DIR/Paper"
    echo "new-paper: $PROJECT_DIR/Paper exists, so the paper goes there. Research/ is the new place for papers; nothing is moved."
fi
if [ "$SUBFOLDER" -eq 1 ]; then
    PAPER_DIR="$PAPER_DIR/$NAME"
fi
ABSTRACT="TODO"

if [ "$FORMAT" = "typst" ]; then
    SOURCE="$PAPER_DIR/$NAME.typ"
else
    SOURCE="$PAPER_DIR/$NAME.tex"
fi

# Never overwrite a document someone is writing.
if [ "$FORCE" -ne 1 ] && [ -e "$SOURCE" ]; then
    echo "new-paper: $SOURCE exists — refusing to overwrite." >&2
    echo "  Give a different --name, or pass --force to replace it." >&2
    exit 1
fi

mkdir -p "$PAPER_DIR/figures"

# ── Shared by every paper in this directory; written once, never replaced. ──
if [ ! -e "$PAPER_DIR/references.bib" ]; then
    echo "% References" > "$PAPER_DIR/references.bib"
    SHARED="created"
else
    SHARED="reused"
fi

if [ "$FORMAT" = "typst" ]; then
    [ -e "$PAPER_DIR/macros.typ" ] || cp "$ASSETS_DIR/macros_template.typ" "$PAPER_DIR/macros.typ"
    sed \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{ABSTRACT}}|$ABSTRACT|g" \
      -e "s|{{MODEL}}|$MODEL|g" \
      -e "s|{{OPERATOR}}|$OPERATOR|g" \
      -e "s|{{FREEDOM}}|$FREEDOM|g" \
      -e "s|{{PROMPT}}|$PROMPT|g" \
      -e "s|{{EMAIL}}|$OPERATOR_EMAIL|g" \
      -e "s|{{DATE}}|$DATE|g" \
      "$ASSETS_DIR/main_template.typ" > "$SOURCE"

    echo "Created: $SOURCE (Typst)"
    echo "  macros.typ        — shared preamble and macros ($SHARED)"
    echo "  references.bib    — bibliography ($SHARED)"
    echo "  figures/          — figures"
    echo ""
    echo "Compile: cd $PAPER_DIR && typst compile $NAME.typ"
else
    [ -e "$PAPER_DIR/macros.sty" ] || cp "$ASSETS_DIR/macros_template.sty" "$PAPER_DIR/macros.sty"
    sed \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{ABSTRACT}}|$ABSTRACT|g" \
      -e "s|{{MODEL}}|$MODEL|g" \
      -e "s|{{OPERATOR}}|$OPERATOR|g" \
      -e "s|{{FREEDOM}}|$FREEDOM|g" \
      -e "s|{{PROMPT}}|$PROMPT|g" \
      -e "s|{{EMAIL}}|$OPERATOR_EMAIL|g" \
      -e "s|{{DATE}}|$DATE|g" \
      "$ASSETS_DIR/main_template.tex" > "$SOURCE"
    [ -e "$PAPER_DIR/.latexmkrc" ] || cp "$ASSETS_DIR/latexmkrc_template" "$PAPER_DIR/.latexmkrc"

    echo "Created: $SOURCE (LaTeX)"
    echo "  macros.sty        — shared preamble and macros ($SHARED)"
    echo "  references.bib    — bibliography ($SHARED)"
    echo "  figures/          — figures"
    echo "  .latexmkrc        — latexmk configuration"
    echo ""
    echo "Compile: cd $PAPER_DIR && latexmk -pdf $NAME.tex"
fi
