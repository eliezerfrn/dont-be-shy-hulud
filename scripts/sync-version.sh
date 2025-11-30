#!/bin/bash
#
# sync-version.sh - Synchronize script versions with CHANGELOG.md
# Usage: ./scripts/sync-version.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. Extract latest version from CHANGELOG.md
# Looks for the first occurrence of "## [X.Y.Z] - YYYY-MM-DD"
LATEST_VERSION=$(grep -m 1 "^## \[[0-9]\+\.[0-9]\+\.[0-9]\+\]" CHANGELOG.md | sed -E 's/## \[([0-9]+\.[0-9]+\.[0-9]+)\].*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    echo "Error: Could not extract version from CHANGELOG.md"
    exit 1
fi

echo -e "${BLUE}Latest version from CHANGELOG.md: ${GREEN}$LATEST_VERSION${NC}"

# 2. Update scripts
SCRIPTS=(
    "scripts/detect.sh"
    "scripts/full-audit.sh"
    "scripts/quick-audit.sh"
    "scripts/harden-npm.sh"
    "scripts/check-github-repos.sh"
    "scripts/set-language.sh"
)

echo "Updating scripts..."

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        # Check if VERSION var exists
        if grep -q "VERSION=" "$script"; then
            # Update existing VERSION
            sed -i '' "s/VERSION=\".*\"/VERSION=\"$LATEST_VERSION\"/" "$script"
            echo -e "  ✓ Updated $script"
        else
            # Insert VERSION after the header/shebang/config
            # Trying to find a good insertion point.
            # If "Config" section exists, put it there.
            if grep -q "# Config" "$script"; then
                sed -i '' "/# Config/a\\
VERSION=\"$LATEST_VERSION\"" "$script"
            else
                # Fallback: Insert after shebang
                sed -i '' "2i\\
VERSION=\"$LATEST_VERSION\"" "$script"
            fi
            echo -e "  + Added version to $script"
        fi
    else
        echo "  ! Script not found: $script"
    fi
done

echo -e "${GREEN}All scripts synchronized to version $LATEST_VERSION${NC}"
