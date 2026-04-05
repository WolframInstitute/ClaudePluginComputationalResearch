#!/usr/bin/env bash
# recover_resources.sh — Rebuild Resources/ from Wiki/Resources/*.md
#
# Parses the ## Recover section from each wiki resource article and
# executes the appropriate download/clone command.
#
# Usage: ./Scripts/recover_resources.sh [wiki_dir]
#   wiki_dir defaults to Wiki/Resources

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

WIKI_DIR="${1:-Wiki/Resources}"

if [ ! -d "$WIKI_DIR" ]; then
  echo "Error: Directory $WIKI_DIR not found."
  echo "Run from the project root, or pass the wiki resources directory as an argument."
  exit 1
fi

mkdir -p Resources

echo ""
echo "=== Resource Recovery ==="
echo "Scanning $WIKI_DIR for resource articles..."
echo ""

TOTAL=0
DOWNLOADED=0
CLONED=0
FAILED=0
SKIPPED=0

for md_file in "$WIKI_DIR"/*.md; do
  [ -f "$md_file" ] || continue
  TOTAL=$((TOTAL + 1))

  filename=$(basename "$md_file")
  echo "Processing: $filename"

  in_recover=0
  while IFS= read -r line; do
    if echo "$line" | grep -qE '^## Recover'; then
      in_recover=1
      continue
    fi
    if [ "$in_recover" -eq 1 ] && echo "$line" | grep -qE '^## '; then
      break
    fi

    if [ "$in_recover" -eq 1 ]; then
      key=$(echo "$line" | sed -n 's/^\([A-Za-z]*\): *\(.*\)/\1/p')
      value=$(echo "$line" | sed -n 's/^\([A-Za-z]*\): *\(.*\)/\2/p')

      case "$key" in
        Download)
          url="$value"
          ;;
        Clone)
          clone_url="$value"
          ;;
        Submodule)
          # "Submodule: <url> <path>" — handled via git submodule, skip here
          submodule_url=$(echo "$value" | awk '{print $1}')
          submodule_path=$(echo "$value" | awk '{print $2}')
          ;;
        Target)
          target="$value"
          ;;
        Install)
          install_cmd="$value"
          ;;
        URL)
          # URL-only resource, nothing to download
          ;;
      esac
    fi
  done < "$md_file"

  if [ "$in_recover" -eq 0 ]; then
    warn "No ## Recover section found in $filename"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Execute recovery based on what we found
  if [ -n "${submodule_url:-}" ] && [ -n "${submodule_path:-}" ]; then
    if [ -d "$submodule_path" ] && [ -n "$(ls -A "$submodule_path" 2>/dev/null)" ]; then
      warn "Submodule already exists: $submodule_path (skipping)"
      SKIPPED=$((SKIPPED + 1))
    else
      echo "  Submodule: handled via git submodule update --init --recursive"
      SKIPPED=$((SKIPPED + 1))
    fi
  elif [ -n "${clone_url:-}" ] && [ -n "${target:-}" ]; then
    if [ -d "$target" ]; then
      warn "Already exists: $target (skipping clone)"
      SKIPPED=$((SKIPPED + 1))
    else
      echo "  Cloning $clone_url → $target"
      if git clone "$clone_url" "$target" 2>/dev/null; then
        ok "Cloned: $target"
        CLONED=$((CLONED + 1))
      else
        fail "Clone failed: $clone_url"
        FAILED=$((FAILED + 1))
      fi
    fi
  elif [ -n "${url:-}" ] && [ -n "${target:-}" ]; then
    if [ -f "$target" ]; then
      warn "Already exists: $target (skipping download)"
      SKIPPED=$((SKIPPED + 1))
    else
      mkdir -p "$(dirname "$target")"
      echo "  Downloading $url → $target"
      if curl -sL -o "$target" "$url" 2>/dev/null; then
        if [ -s "$target" ]; then
          ok "Downloaded: $target"
          DOWNLOADED=$((DOWNLOADED + 1))
        else
          rm -f "$target"
          fail "Download empty: $url"
          FAILED=$((FAILED + 1))
        fi
      else
        fail "Download failed: $url"
        FAILED=$((FAILED + 1))
      fi
    fi
  elif [ -n "${install_cmd:-}" ]; then
    echo "  Install command: $install_cmd"
    warn "Run manually: $install_cmd"
    SKIPPED=$((SKIPPED + 1))
  else
    warn "No actionable recovery info in $filename"
    SKIPPED=$((SKIPPED + 1))
  fi

  # Reset variables for next file
  url="" clone_url="" target="" install_cmd="" submodule_url="" submodule_path=""
  in_recover=0

done

echo ""
echo "=== Summary ==="
echo "  Total articles: $TOTAL"
[ "$DOWNLOADED" -gt 0 ] && ok "Downloaded: $DOWNLOADED"
[ "$CLONED" -gt 0 ] && ok "Cloned: $CLONED"
[ "$SKIPPED" -gt 0 ] && warn "Skipped: $SKIPPED"
[ "$FAILED" -gt 0 ] && fail "Failed: $FAILED"

# Handle git submodules if present
if [ -f .gitmodules ]; then
  echo ""
  echo "Recovering git submodules..."
  git submodule update --init --recursive
  ok "Submodules recovered"
fi

echo ""
echo "Done."
