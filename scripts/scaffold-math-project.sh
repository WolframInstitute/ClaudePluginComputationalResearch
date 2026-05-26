#!/usr/bin/env bash
# scaffold-math-project.sh — Create math-research project directory structure.
#
# Usage: scaffold-math-project.sh <ProjectName> ["Topic"] [output-dir] ["Author"] ["email"] ["CodeDir"] [WithLean=0|1]
#
# Differs from scaffold-project.sh by adding Wiki/{Theorems,Definitions,Domains,Plans}/
# upfront and seeding Wiki/Domains/categories.md from the math taxonomy template.
# Optionally scaffolds a Lean/ subdirectory for Mathlib-style formalization
# (just the directory + a placeholder lakefile reference, not a real lake new).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/project-init/assets"

if [ $# -lt 1 ]; then
  echo "Usage: scaffold-math-project.sh <ProjectName> [\"Topic\"] [output-dir] [\"Author\"] [\"email\"] [\"CodeDir\"] [WithLean=0|1]" >&2
  exit 1
fi

PROJECT_NAME="$1"
TOPIC_DESCRIPTION="${2:-A pure-math computational research project.}"
OUTPUT_DIR="${3:-.}"
AUTHOR_NAME="${4:-Pavel H\'ajek}"
AUTHOR_EMAIL="${5:-p135246@gmail.com}"
CODE_DIR="${6:-Code}"
WITH_LEAN="${7:-0}"
TODAY=$(date +%Y-%m-%d)

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# ── 1. Directories ─────────────────────────────────────────────────────────

mkdir -p "$PROJECT_NAME/$CODE_DIR"
mkdir -p "$PROJECT_NAME/Resources"
mkdir -p "$PROJECT_NAME/Scripts"
mkdir -p "$PROJECT_NAME/Wiki/Theorems"
mkdir -p "$PROJECT_NAME/Wiki/Definitions"
mkdir -p "$PROJECT_NAME/Wiki/Domains"
mkdir -p "$PROJECT_NAME/Wiki/Plans"
if [ "$WITH_LEAN" = "1" ]; then
  mkdir -p "$PROJECT_NAME/Lean"
fi
echo "Created directories: $PROJECT_NAME/{$CODE_DIR,Resources,Scripts,Wiki/{Theorems,Definitions,Domains,Plans}}$([ "$WITH_LEAN" = "1" ] && echo ',Lean' || true)"

# ── 2. Tools.wl ───────────────────────────────────────────────────────────

cp "$ASSETS_DIR/tools_starter.wl" "$PROJECT_NAME/$CODE_DIR/Tools.wl"
echo "Created: $PROJECT_NAME/$CODE_DIR/Tools.wl"

# ── 3. CLAUDE.md (math variant) ───────────────────────────────────────────

sed \
  -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
  -e "s|{{TOPIC_DESCRIPTION}}|$TOPIC_DESCRIPTION|g" \
  -e "s|{{CODE_DIR}}|$CODE_DIR|g" \
  -e "s|{{GOALS}}|1. State the relevant theorems and definitions precisely in Wiki/Theorems and Wiki/Definitions\n2. Develop computational tools in Wolfram Language to explore examples and counterexamples\n3. (Optional) Formalize the central results in Lean / Mathlib|g" \
  "$ASSETS_DIR/math_claude_template.md" > "$PROJECT_NAME/CLAUDE.md"
printf '\n' >> "$PROJECT_NAME/CLAUDE.md"
cat "$ASSETS_DIR/code_style_template.md" >> "$PROJECT_NAME/CLAUDE.md"
echo "Created: $PROJECT_NAME/CLAUDE.md"

# ── 4. Math taxonomy seed ────────────────────────────────────────────────

cp "$ASSETS_DIR/math_categories_template.md" "$PROJECT_NAME/Wiki/Domains/categories.md"
echo "Created: $PROJECT_NAME/Wiki/Domains/categories.md"

# ── 5. Seed templates the user will fill in ──────────────────────────────

cp "$ASSETS_DIR/formal_definition_template.md" "$PROJECT_NAME/Wiki/Definitions/_template.md"
echo "Created: $PROJECT_NAME/Wiki/Definitions/_template.md"

# ── 6. Scripts ───────────────────────────────────────────────────────────

cp "$SCRIPT_DIR/recover_resources.sh" "$PROJECT_NAME/Scripts/recover_resources.sh"
cp "$SCRIPT_DIR/generate_notebooks.wls" "$PROJECT_NAME/Scripts/generate_notebooks.wls"
cp "$SCRIPT_DIR/publish_notebooks.wls" "$PROJECT_NAME/Scripts/publish_notebooks.wls"
chmod +x "$PROJECT_NAME/Scripts/recover_resources.sh"
echo "Created: $PROJECT_NAME/Scripts/{recover_resources.sh,generate_notebooks.wls,publish_notebooks.wls}"

# ── 7. Summary ───────────────────────────────────────────────────────────

echo ""
echo "=== Math-research project scaffolded: $PROJECT_NAME/ ==="
echo ""
echo "  $CODE_DIR/"
echo "    Tools.wl                   — shared general utilities"
echo "  Resources/                    — reference PDFs, notebooks (gitignored)"
echo "  Wiki/"
echo "    Theorems/                   — one .md per theorem (statement, proof outline, status)"
echo "    Definitions/                — one .md per formal definition"
echo "      _template.md              — copy this for new definitions"
echo "    Domains/categories.md       — math-domain taxonomy (adapt to project scope)"
echo "    Plans/                      — wiki-plan and formalization checklists"
if [ "$WITH_LEAN" = "1" ]; then
  echo "  Lean/                         — formalization (run 'lake new $PROJECT_NAME math' here)"
fi
echo "  CLAUDE.md                     — project context"
echo ""
echo "Next: Claude will run wiki-init for Index/Status/Log, then seed initial theorems/definitions."
