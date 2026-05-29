#!/usr/bin/env bash
# scaffold-paclet.sh — Create a standalone Wolfram paclet structure
#
# Usage: scaffold-paclet.sh <PacletName> [OrgName] [Topic] [Author] [Email] [OutputDir]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/project-init/assets"

if [ $# -lt 1 ]; then
    echo "Usage: scaffold-paclet.sh <PacletName> [OrgName] [Topic] [Author] [Email] [OutputDir]" >&2
    exit 1
fi

PACLET_NAME="$1"
ORG_NAME="${2:-WolframInstitute}"
TOPIC="${3:-A Wolfram Language paclet.}"
AUTHOR_NAME="${4:-Pavel H\'ajek}"
AUTHOR_EMAIL="${5:-p135246@gmail.com}"
OUTPUT_DIR="${6:-.}"

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# ── 1. Directory structure (two-level nesting) ───────────────────────────

REPO_ROOT="$PACLET_NAME"
PACLET_DIR="$REPO_ROOT/$PACLET_NAME"

mkdir -p "$PACLET_DIR/Kernel"
mkdir -p "$PACLET_DIR/Tests"
mkdir -p "$REPO_ROOT/Work"

sed -e "s/{{PROJECT_NAME}}/$PACLET_NAME/g" \
    "$ASSETS_DIR/work_readme_template.md" > "$REPO_ROOT/Work/README.md"
echo "Created: $REPO_ROOT/Work/README.md"

# ── 2. Paclet files ──────────────────────────────────────────────────────

sed -e "s/{{PACLET_NAME}}/$PACLET_NAME/g" \
    -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
    -e "s|{{TOPIC}}|$TOPIC|g" \
    -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
    "$ASSETS_DIR/pacletinfo_template.wl" > "$PACLET_DIR/PacletInfo.wl"

sed -e "s/{{PACLET_NAME}}/$PACLET_NAME/g" \
    -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
    "$ASSETS_DIR/kernel_main_template.wl" > "$PACLET_DIR/Kernel/$PACLET_NAME.wl"

sed -e "s/{{PACLET_NAME}}/$PACLET_NAME/g" \
    -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
    "$ASSETS_DIR/usage_template.wl" > "$PACLET_DIR/Kernel/Usage.wl"

sed -e "s/{{PACLET_NAME}}/$PACLET_NAME/g" \
    -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
    "$ASSETS_DIR/run_all_tests_template.wl" > "$PACLET_DIR/Tests/RunAllTests.wl"

echo "Created paclet: $PACLET_DIR/"

# ── 3. Repo-level files ─────────────────────────────────────────────────

sed -e "s/{{PACLET_NAME}}/$PACLET_NAME/g" \
    -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
    "$ASSETS_DIR/run_tests_template.wls" > "$REPO_ROOT/run_tests.wls"
chmod +x "$REPO_ROOT/run_tests.wls"

sed -e "s/{{PACLET_NAME}}/$PACLET_NAME/g" \
    -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
    -e "s|{{TOPIC}}|$TOPIC|g" \
    "$ASSETS_DIR/readme_paclet_template.md" > "$REPO_ROOT/README.md"

cp "$ASSETS_DIR/gitignore_submodule.template" "$REPO_ROOT/.gitignore"

echo "Created repo files: run_tests.wls, README.md, .gitignore"

# ── 4. CLAUDE.md ─────────────────────────────────────────────────────────

cat > "$REPO_ROOT/CLAUDE.md" << EOF
# $PACLET_NAME

## Project goals

$TOPIC

## Repo structure

Standalone Wolfram paclet with two-level nesting:

\`\`\`
$PACLET_NAME/              <- repo root
  $PACLET_NAME/            <- actual paclet
    PacletInfo.wl
    Kernel/
      $PACLET_NAME.wl      <- main loader
      Usage.wl
    Tests/
      RunAllTests.wl
  run_tests.wls
  README.md
  Work/                    <- execution state (specs / tasks / progress)
\`\`\`

## Work

\`Work/\` holds execution state — what's being built now. Each file is one work
item: a Spec, Tasks (one ≈ one session), and a Progress log; \`Work/README.md\`
is the board. Use \`/work <goal>\` to create one and \`/next-session\` to do one
task per fresh session.

## Package system

Uses \`Package[]\` / \`PackageExport\` / \`PackageScope\` (not BeginPackage/EndPackage).

- Main loader: \`Package["$ORG_NAME\`$PACLET_NAME\`"]\` + \`PackageExport[Symbol]\` + \`ClearAll\`
- Kernel modules: \`Package["$ORG_NAME\`$PACLET_NAME\`"]\` + optional \`PackageScope[helper]\`

## Loading during development

\`\`\`wolfram
PacletDirectoryLoad[ "$PACLET_NAME" ]
Needs[ "$ORG_NAME\`$PACLET_NAME\`" ]
\`\`\`

## Testing

\`\`\`bash
wolframscript -f run_tests.wls
\`\`\`
EOF
printf '\n' >> "$REPO_ROOT/CLAUDE.md"
cat "$ASSETS_DIR/code_style_template.md" >> "$REPO_ROOT/CLAUDE.md"
echo "Created: $REPO_ROOT/CLAUDE.md"

# ── 5. Summary ───────────────────────────────────────────────────────────

echo ""
echo "=== Paclet scaffolded: $REPO_ROOT/ ==="
echo ""
echo "  $PACLET_NAME/PacletInfo.wl"
echo "  $PACLET_NAME/Kernel/$PACLET_NAME.wl  — main loader"
echo "  $PACLET_NAME/Kernel/Usage.wl"
echo "  $PACLET_NAME/Tests/"
echo "  run_tests.wls"
echo "  README.md"
echo "  .gitignore"
echo "  Work/README.md       — work-item board (spec / tasks / progress per effort)"
echo "  CLAUDE.md"
echo ""
echo "Next: add kernel modules, tests, and optionally initialize Wiki/."
