#!/usr/bin/env bash
# Bug Bounty Toolkit — bootstrap installer
# Installs all required CLI tools and optional resources.
# Idempotent — safe to re-run.

set -euo pipefail

BLUE="\033[1;34m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; RED="\033[1;31m"; RESET="\033[0m"
log()     { echo -e "${BLUE}[+]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
fail()    { echo -e "${RED}[✗]${RESET} $*" >&2; exit 1; }

OS="$(uname -s)"
WORDLIST_DIR="${WORDLIST_DIR:-$HOME/Desktop/bug-bounty}"

# ---- 1. Homebrew ---------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    success "Homebrew already installed"
fi

# ---- 2. ProjectDiscovery recon CLIs -------------------------------------
log "Installing ProjectDiscovery tools (nuclei, subfinder, httpx, katana, naabu)..."
for t in nuclei subfinder httpx katana naabu; do
    if command -v "$t" >/dev/null 2>&1; then
        success "$t already installed"
    else
        brew install "$t" && success "$t installed"
    fi
done

# ---- 3. Additional high-value tools -------------------------------------
log "Installing supporting tools (jq, gron, dnsx, ffuf)..."
for t in jq gron dnsx ffuf; do
    if command -v "$t" >/dev/null 2>&1; then
        success "$t already installed"
    else
        brew install "$t" && success "$t installed"
    fi
done

# ---- 4. pipx + semgrep (SAST) -------------------------------------------
if ! command -v pipx >/dev/null 2>&1; then
    log "Installing pipx..."
    brew install pipx
    pipx ensurepath
fi

if ! command -v semgrep >/dev/null 2>&1; then
    log "Installing semgrep (SAST)..."
    pipx install semgrep
else
    success "semgrep already installed"
fi

# ---- 5. Wordlists & reference repos -------------------------------------
mkdir -p "$WORDLIST_DIR"

clone_or_update() {
    local url="$1"
    local dir="$2"
    if [ -d "$WORDLIST_DIR/$dir/.git" ]; then
        success "$dir already present (run 'git -C $WORDLIST_DIR/$dir pull' to update)"
    else
        log "Cloning $dir..."
        git clone --depth 1 "$url" "$WORDLIST_DIR/$dir"
    fi
}

clone_or_update https://github.com/danielmiessler/SecLists.git SecLists
clone_or_update https://github.com/swisskyrepo/PayloadsAllTheThings.git PayloadsAllTheThings
clone_or_update https://github.com/projectdiscovery/nuclei-templates.git nuclei-templates
clone_or_update https://github.com/HackTricks-wiki/hacktricks.git hacktricks

# ---- 6. Update nuclei templates -----------------------------------------
log "Updating nuclei template database..."
nuclei -update-templates -silent 2>/dev/null || warn "nuclei template update skipped (will auto-update on first run)"

# ---- 7. Output directory ------------------------------------------------
mkdir -p "$(dirname "$0")/output"

# ---- 8. Final report ----------------------------------------------------
echo
success "Bug Bounty Toolkit installation complete!"
echo
echo "Installed CLIs:"
for t in nuclei subfinder httpx katana naabu ffuf semgrep jq; do
    if command -v "$t" >/dev/null 2>&1; then
        printf "  %-12s %s\n" "$t" "$(command -v $t)"
    fi
done
echo
echo "Wordlists at: $WORDLIST_DIR"
echo
echo "Next steps:"
echo "  1. Read learning/01-START-HERE.md"
echo "  2. Try a scan: ./recon/full-recon.sh hackerone.com"
echo "  3. Install the Claude Code agent: cp agents/bug-bounty-hunter.md ~/.claude/agents/"
echo
