#!/usr/bin/env bash
# Install the daily-recon launchd job.
#
# This substitutes the real toolkit path into the plist template,
# copies it to ~/Library/LaunchAgents/, and loads it.
#
# Idempotent — safe to re-run.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LABEL="com.bugbountytoolkit.daily-recon"
TEMPLATE="$SCRIPT_DIR/$LABEL.plist.template"
TARGET="$HOME/Library/LaunchAgents/$LABEL.plist"

BLUE="\033[1;34m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; RED="\033[1;31m"; RESET="\033[0m"

if [ ! -f "$TEMPLATE" ]; then
    echo -e "${RED}[✗]${RESET} Template not found: $TEMPLATE"
    exit 1
fi

if [ ! -x "$TOOLKIT_DIR/recon/daily-recon.sh" ]; then
    echo -e "${RED}[✗]${RESET} daily-recon.sh not found or not executable at $TOOLKIT_DIR/recon/daily-recon.sh"
    exit 1
fi

# Warn if programs.txt is missing — script won't do anything useful without it
if [ ! -f "$TOOLKIT_DIR/programs.txt" ]; then
    echo -e "${YELLOW}[!]${RESET} programs.txt not found at $TOOLKIT_DIR/programs.txt"
    echo -e "${YELLOW}[!]${RESET} Create it before relying on the scheduled run:"
    echo -e "${YELLOW}[!]${RESET}   cp $TOOLKIT_DIR/programs.example.txt $TOOLKIT_DIR/programs.txt"
    echo -e "${YELLOW}[!]${RESET}   # then edit to add YOUR authorized targets"
    echo
fi

echo -e "${BLUE}[+]${RESET} Toolkit dir: $TOOLKIT_DIR"
echo -e "${BLUE}[+]${RESET} Rendering plist..."

# If already loaded, unload first (idempotent re-install)
if launchctl list 2>/dev/null | grep -q "$LABEL"; then
    echo -e "${BLUE}[+]${RESET} Unloading existing job..."
    launchctl unload "$TARGET" 2>/dev/null || true
fi

# Substitute the toolkit path
sed "s|__TOOLKIT_DIR__|$TOOLKIT_DIR|g" "$TEMPLATE" > "$TARGET"

# Load
launchctl load "$TARGET"
echo -e "${GREEN}[✓]${RESET} Installed and loaded: $LABEL"
echo

# Verify
if launchctl list 2>/dev/null | grep -q "$LABEL"; then
    echo -e "${GREEN}[✓]${RESET} Job is active. Will run daily at 06:00 local time."
else
    echo -e "${RED}[✗]${RESET} Job didn't load. Check ~/Library/LaunchAgents/$LABEL.plist"
    exit 1
fi

echo
echo "Next steps:"
echo "  1. Make sure programs.txt lists your authorized targets"
echo "  2. Do a test run:   $TOOLKIT_DIR/recon/daily-recon.sh"
echo "  3. Check tomorrow's summary: $TOOLKIT_DIR/recon/triage.sh today"
echo
echo "To uninstall:   $SCRIPT_DIR/uninstall-schedule.sh"
echo "To re-run NOW:  launchctl start $LABEL"
echo "To check logs:  tail -f $TOOLKIT_DIR/output/daily-recon.launchd.log"
