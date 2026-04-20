#!/usr/bin/env bash
# Uninstall the daily-recon launchd job.

set -euo pipefail

LABEL="com.bugbountytoolkit.daily-recon"
TARGET="$HOME/Library/LaunchAgents/$LABEL.plist"

BLUE="\033[1;34m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; RESET="\033[0m"

if [ -f "$TARGET" ]; then
    echo -e "${BLUE}[+]${RESET} Unloading $LABEL..."
    launchctl unload "$TARGET" 2>/dev/null || true
    rm -f "$TARGET"
    echo -e "${GREEN}[✓]${RESET} Removed $TARGET"
else
    echo -e "${YELLOW}[!]${RESET} Not installed — nothing to do."
fi
