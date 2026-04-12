#!/usr/bin/env bash
# scaffold-paclet-dev.sh — Create WolframInstitute-style paclet dev repo
#
# Usage: scaffold-paclet-dev.sh <DevRepoName> <PacletNames> [OrgName] [GitHubUser] [Topic] [Author] [Email] [OutputDir]
#
# PacletNames: comma-separated, e.g., "SyntheticInfrageometry,Infrageometry"
# OrgName: GitHub org for public paclet repos (default: WolframInstitute)
# GitHubUser: GitHub user for private dev repo

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/project-init/assets"

if [ $# -lt 2 ]; then
    echo "Usage: scaffold-paclet-dev.sh <DevRepoName> <PacletNames> [OrgName] [GitHubUser] [Topic] [Author] [Email] [OutputDir]" >&2
    exit 1
fi

DEV_REPO_NAME="$1"
PACLET_NAMES_RAW="$2"
ORG_NAME="${3:-WolframInstitute}"
GITHUB_USER="${4:-p135246}"
TOPIC="${5:-A Wolfram paclet development project.}"
AUTHOR_NAME="${6:-Pavel H\'ajek}"
AUTHOR_EMAIL="${7:-p135246@gmail.com}"
OUTPUT_DIR="${8:-.}"

IFS=',' read -ra PACLETS <<< "$PACLET_NAMES_RAW"

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# ── 1. Dev repo root ──────────────────────────────────────────────────────

mkdir -p "$DEV_REPO_NAME/Code"
echo "Created: $DEV_REPO_NAME/Code/"

# ── 2. Each paclet (triple-nested) ───────────────────────────────────────

for PACLET in "${PACLETS[@]}"; do
    PACLET=$(echo "$PACLET" | xargs)
    SUBMODULE_DIR="$DEV_REPO_NAME/$PACLET"
    PACLET_DIR="$SUBMODULE_DIR/$PACLET"

    mkdir -p "$PACLET_DIR/Kernel"
    mkdir -p "$PACLET_DIR/Tests"

    sed -e "s/{{PACLET_NAME}}/$PACLET/g" \
        -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
        -e "s|{{TOPIC}}|$TOPIC|g" \
        -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
        "$ASSETS_DIR/pacletinfo_template.wl" > "$PACLET_DIR/PacletInfo.wl"

    sed -e "s/{{PACLET_NAME}}/$PACLET/g" \
        -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
        "$ASSETS_DIR/kernel_main_template.wl" > "$PACLET_DIR/Kernel/$PACLET.wl"

    sed -e "s/{{PACLET_NAME}}/$PACLET/g" \
        -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
        "$ASSETS_DIR/usage_template.wl" > "$PACLET_DIR/Kernel/Usage.wl"

    sed -e "s/{{PACLET_NAME}}/$PACLET/g" \
        -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
        "$ASSETS_DIR/run_all_tests_template.wl" > "$PACLET_DIR/Tests/RunAllTests.wl"

    sed -e "s/{{PACLET_NAME}}/$PACLET/g" \
        -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
        "$ASSETS_DIR/run_tests_template.wls" > "$SUBMODULE_DIR/run_tests.wls"
    chmod +x "$SUBMODULE_DIR/run_tests.wls"

    sed -e "s/{{PACLET_NAME}}/$PACLET/g" \
        -e "s/{{ORG_NAME}}/$ORG_NAME/g" \
        -e "s|{{TOPIC}}|$TOPIC|g" \
        "$ASSETS_DIR/readme_paclet_template.md" > "$SUBMODULE_DIR/README.md"

    cp "$ASSETS_DIR/gitignore_submodule.template" "$SUBMODULE_DIR/.gitignore"

    echo "Created paclet: $SUBMODULE_DIR/$PACLET/ (triple-nested)"
done

# ── 3. .gitmodules ────────────────────────────────────────────────────────

{
    first=true
    for PACLET in "${PACLETS[@]}"; do
        PACLET=$(echo "$PACLET" | xargs)
        if [ "$first" = true ]; then
            first=false
        else
            echo ""
        fi
        echo "[submodule \"$PACLET\"]"
        echo "    path = $PACLET"
        echo "    url = git@github.com:$ORG_NAME/$PACLET.git"
    done
} > "$DEV_REPO_NAME/.gitmodules"
echo "Created: $DEV_REPO_NAME/.gitmodules"

# ── 4. Dev repo .gitignore ───────────────────────────────────────────────

cp "$ASSETS_DIR/gitignore_dev.template" "$DEV_REPO_NAME/.gitignore"
echo "Created: $DEV_REPO_NAME/.gitignore"

# ── 5. CLAUDE.md ─────────────────────────────────────────────────────────

{
    echo "# $DEV_REPO_NAME"
    echo ""
    echo "## Project goals"
    echo ""
    echo "$TOPIC"
    echo ""
    echo "## Repo structure"
    echo ""
    echo "WolframInstitute-style paclet dev repo with three-tier architecture:"
    echo "- **Dev repo** ($GITHUB_USER/$DEV_REPO_NAME, private) — experimental code, wiki, notes"
    echo "- **Paclet submodules** ($ORG_NAME/PacletName, public) — formal paclet code"
    echo ""
    echo "### Paclets"
    echo ""
    for PACLET in "${PACLETS[@]}"; do
        PACLET=$(echo "$PACLET" | xargs)
        echo "- \`$PACLET/$PACLET/\` — $PACLET paclet"
        echo "  - \`PacletInfo.wl\` — paclet metadata"
        echo "  - \`Kernel/$PACLET.wl\` — main loader"
        echo "  - \`Kernel/Usage.wl\` — usage messages"
        echo "  - \`Tests/\` — test files (*.wlt)"
    done
    echo ""
    echo "### Triple nesting convention"
    echo ""
    echo "The paclet name appears three times in the path:"
    echo "\`\`\`"
    echo "PacletName/PacletName/Kernel/PacletName.wl"
    echo "^submodule  ^paclet    ^main loader"
    echo "\`\`\`"
    echo ""
    echo "### Loading during development"
    echo ""
    echo "\`\`\`wolfram"
    for PACLET in "${PACLETS[@]}"; do
        PACLET=$(echo "$PACLET" | xargs)
        echo "PacletDirectoryLoad[ \"$PACLET/$PACLET\" ]"
        echo "Needs[ \"$ORG_NAME\`$PACLET\`\" ]"
    done
    echo "\`\`\`"
    echo ""
    echo "### Package system"
    echo ""
    echo "Uses \`Package[]\` / \`PackageExport\` / \`PackageScope\` (not BeginPackage/EndPackage)."
    echo ""
    echo "- Main loader: \`Package[\"$ORG_NAME\\\`PacletName\\\`\"]\` + \`PackageExport[Symbol]\` + \`ClearAll\`"
    echo "- Kernel modules: \`Package[\"$ORG_NAME\\\`PacletName\\\`\"]\` + optional \`PackageScope[helper]\`"
    echo ""
    echo "## Other directories"
    echo ""
    echo "- \`Code/\` — experimental/unrevised code (dev repo only)"
    echo "- \`Wiki/\` — plain-markdown knowledge base"
    echo "- \`Notebooks/\` — generated .nb files (gitignored)"
    echo "- \`Paper/\` — research notes (gitignored)"
    echo "- \`Resources/\` — reference PDFs (gitignored)"
    echo ""
    echo "## Testing"
    echo ""
    echo "\`\`\`bash"
    for PACLET in "${PACLETS[@]}"; do
        PACLET=$(echo "$PACLET" | xargs)
        echo "wolframscript -f $PACLET/run_tests.wls"
    done
    echo "\`\`\`"
} > "$DEV_REPO_NAME/CLAUDE.md"
echo "Created: $DEV_REPO_NAME/CLAUDE.md"

# ── 6. Scripts ───────────────────────────────────────────────────────────

mkdir -p "$DEV_REPO_NAME/Scripts"
if [ -f "$SCRIPT_DIR/recover_resources.sh" ]; then
    cp "$SCRIPT_DIR/recover_resources.sh" "$DEV_REPO_NAME/Scripts/recover_resources.sh"
    chmod +x "$DEV_REPO_NAME/Scripts/recover_resources.sh"
fi
if [ -f "$SCRIPT_DIR/generate_notebooks.wls" ]; then
    cp "$SCRIPT_DIR/generate_notebooks.wls" "$DEV_REPO_NAME/Scripts/generate_notebooks.wls"
fi
if [ -f "$SCRIPT_DIR/publish_notebooks.wls" ]; then
    cp "$SCRIPT_DIR/publish_notebooks.wls" "$DEV_REPO_NAME/Scripts/publish_notebooks.wls"
fi
echo "Created: $DEV_REPO_NAME/Scripts/"

# ── 7. Summary ───────────────────────────────────────────────────────────

echo ""
echo "=== Paclet dev repo scaffolded: $DEV_REPO_NAME/ ==="
echo ""
for PACLET in "${PACLETS[@]}"; do
    PACLET=$(echo "$PACLET" | xargs)
    echo "  $PACLET/                        — git submodule -> $ORG_NAME/$PACLET"
    echo "    $PACLET/PacletInfo.wl"
    echo "    $PACLET/Kernel/$PACLET.wl      — main loader"
    echo "    $PACLET/Kernel/Usage.wl"
    echo "    $PACLET/Tests/"
    echo "    run_tests.wls"
done
echo "  Code/                             — experimental/unrevised code"
echo "  Scripts/"
echo "  .gitmodules"
echo "  .gitignore"
echo "  CLAUDE.md"
echo ""
echo "Next: Claude will initialize Wiki/, download papers, and create notebooks."
echo ""
echo "Git setup (after scaffolding complete):"
echo "  cd $DEV_REPO_NAME && git init"
for PACLET in "${PACLETS[@]}"; do
    PACLET=$(echo "$PACLET" | xargs)
    echo "  cd $PACLET && git init && git remote add origin git@github.com:$ORG_NAME/$PACLET.git && cd .."
done
echo "  git submodule add git@github.com:$ORG_NAME/<PacletName>.git <PacletName>"
echo "  git remote add origin git@github.com:$GITHUB_USER/$DEV_REPO_NAME.git"
