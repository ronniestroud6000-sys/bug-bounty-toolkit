#!/usr/bin/env bash
# Full recon pipeline — the flagship workflow.
#
# Usage:  ./recon/full-recon.sh <target-domain> [--quick|--deep]
# Example: ./recon/full-recon.sh example.com
#
# Produces:
#   output/<target>/
#     ├── subdomains.txt         # all discovered subdomains
#     ├── live.txt               # confirmed live hosts
#     ├── live.jsonl             # full httpx JSON output
#     ├── ports.txt              # naabu port scan results
#     ├── crawl.txt              # katana-discovered URLs
#     ├── nuclei.jsonl           # raw nuclei findings
#     └── report.md              # human-readable summary
#
# Authorization reminder: only run this against targets where you have
# explicit authorization (signed SOW, public bug bounty program scope, etc).

set -euo pipefail

BLUE="\033[1;34m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; RED="\033[1;31m"; RESET="\033[0m"
log()     { echo -e "${BLUE}[+]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
fail()    { echo -e "${RED}[✗]${RESET} $*" >&2; exit 1; }

# ---- Arguments ----------------------------------------------------------
TARGET="${1:-}"
MODE="${2:---standard}"

if [ -z "$TARGET" ]; then
    cat <<USAGE
Usage: $0 <target-domain> [--quick|--standard|--deep]

Modes:
  --quick     Subdomain enum + live detection + nuclei high/critical only (~2-5 min)
  --standard  Adds katana crawling + full nuclei scan (default, ~10-20 min)
  --deep      Adds port scanning + exhaustive nuclei templates (~30-60 min)

Example:
  $0 hackerone.com --standard
USAGE
    exit 1
fi

# Strip protocol if pasted
TARGET="${TARGET#https://}"
TARGET="${TARGET#http://}"
TARGET="${TARGET%/}"

# Validate it looks like a domain
if ! [[ "$TARGET" =~ ^[a-zA-Z0-9.-]+$ ]]; then
    fail "Target '$TARGET' doesn't look like a domain"
fi

# ---- Setup output dir ---------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$SCRIPT_DIR/output/$TARGET"
mkdir -p "$OUT"

log "Target: $TARGET"
log "Mode:   $MODE"
log "Output: $OUT"
echo

# ---- Authorization check -------------------------------------------------
if [ ! -f "$SCRIPT_DIR/output/.authorized-targets" ] || ! grep -qx "$TARGET" "$SCRIPT_DIR/output/.authorized-targets" 2>/dev/null; then
    warn "Target not in authorized list. Add to output/.authorized-targets to suppress this warning."
    echo -n "Confirm you have authorization to test '$TARGET' [y/N]: "
    read -r REPLY
    [[ "$REPLY" =~ ^[Yy]$ ]] || fail "Aborted."
    mkdir -p "$SCRIPT_DIR/output"
    echo "$TARGET" >> "$SCRIPT_DIR/output/.authorized-targets"
fi

START_TIME=$(date +%s)

# ---- 1. Subdomain enumeration -------------------------------------------
log "Enumerating subdomains (passive sources)..."
subfinder -d "$TARGET" -silent -all > "$OUT/subdomains.txt" || true
SUB_COUNT=$(wc -l < "$OUT/subdomains.txt" | tr -d ' ')
success "Found $SUB_COUNT subdomains"

# ---- 2. Live host detection + fingerprinting ----------------------------
log "Probing for live hosts..."
cat "$OUT/subdomains.txt" \
    | httpx -silent \
            -status-code -title -tech-detect -ip \
            -o "$OUT/live.txt" \
            -json -output "$OUT/live.jsonl" \
            -rate-limit 150 \
            2>/dev/null || true

LIVE_COUNT=$(wc -l < "$OUT/live.txt" 2>/dev/null | tr -d ' ' || echo 0)
success "$LIVE_COUNT live hosts"

if [ "$LIVE_COUNT" -eq 0 ]; then
    warn "No live hosts found. Exiting."
    exit 0
fi

# ---- 3. Port scanning (deep mode only) ----------------------------------
if [ "$MODE" = "--deep" ]; then
    log "Running port scan (deep mode)..."
    cat "$OUT/live.txt" \
        | sed -E 's#^https?://##; s#/.*##' \
        | sort -u \
        | naabu -silent -top-ports 1000 -rate 1000 > "$OUT/ports.txt" || true
    success "Port scan complete: $(wc -l < "$OUT/ports.txt" | tr -d ' ') open ports"
fi

# ---- 4. Crawling (standard + deep) --------------------------------------
if [ "$MODE" != "--quick" ]; then
    log "Crawling live hosts with katana..."
    katana -silent -list "$OUT/live.txt" \
           -d 2 \
           -jc \
           -rate-limit 100 \
           -o "$OUT/crawl.txt" 2>/dev/null || true
    success "Crawled $(wc -l < "$OUT/crawl.txt" | tr -d ' ') URLs"
fi

# ---- 5. Nuclei scanning -------------------------------------------------
log "Running nuclei vulnerability scan..."

# Severity profile based on mode
case "$MODE" in
    --quick) SEVERITY="high,critical"; TAGS="" ;;
    --deep)  SEVERITY="info,low,medium,high,critical"; TAGS="" ;;
    *)       SEVERITY="medium,high,critical"; TAGS="" ;;
esac

# Input: live hosts + crawled URLs (if present)
NUCLEI_INPUT="$OUT/live.txt"
if [ -f "$OUT/crawl.txt" ] && [ -s "$OUT/crawl.txt" ]; then
    cat "$OUT/live.txt" "$OUT/crawl.txt" | sort -u > "$OUT/nuclei-input.txt"
    NUCLEI_INPUT="$OUT/nuclei-input.txt"
fi

nuclei -silent \
       -list "$NUCLEI_INPUT" \
       -severity "$SEVERITY" \
       -jsonl -output "$OUT/nuclei.jsonl" \
       -rate-limit 150 \
       -c 25 \
       2>/dev/null || true

NUCLEI_COUNT=$(wc -l < "$OUT/nuclei.jsonl" 2>/dev/null | tr -d ' ' || echo 0)
success "nuclei found $NUCLEI_COUNT potential issues"

# ---- 6. Generate report -------------------------------------------------
log "Generating report..."

REPORT="$OUT/report.md"
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

{
    echo "# Recon Report: $TARGET"
    echo
    echo "- **Date:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo "- **Mode:** $MODE"
    echo "- **Duration:** ${ELAPSED}s"
    echo
    echo "## Summary"
    echo
    echo "| Metric | Count |"
    echo "|--------|-------|"
    echo "| Subdomains discovered | $SUB_COUNT |"
    echo "| Live hosts | $LIVE_COUNT |"
    [ "$MODE" = "--deep" ] && echo "| Open ports | $(wc -l < "$OUT/ports.txt" 2>/dev/null | tr -d ' ' || echo 0) |"
    [ -f "$OUT/crawl.txt" ] && echo "| URLs crawled | $(wc -l < "$OUT/crawl.txt" | tr -d ' ') |"
    echo "| Potential issues (nuclei) | $NUCLEI_COUNT |"
    echo

    if [ "$NUCLEI_COUNT" -gt 0 ]; then
        echo "## Findings by severity"
        echo
        for sev in critical high medium low info; do
            count=$(grep -c "\"severity\":\"$sev\"" "$OUT/nuclei.jsonl" 2>/dev/null || echo 0)
            [ "$count" -gt 0 ] && echo "- **${sev^^}:** $count"
        done
        echo
        echo "## Top findings (critical & high)"
        echo
        grep -E '"severity":"(critical|high)"' "$OUT/nuclei.jsonl" 2>/dev/null \
          | jq -r '"- **\(.info.severity | ascii_upcase)** — [\(.info.name)](\(.matched_at)) · template: `\(.template_id)`"' \
          | head -50
        echo
        echo "## Full nuclei output"
        echo
        echo "\`\`\`"
        cat "$OUT/nuclei.jsonl" | jq -r '"\(.info.severity | ascii_upcase) | \(.info.name) | \(.matched_at)"' 2>/dev/null | head -200
        echo "\`\`\`"
    fi

    echo
    echo "## Interesting live hosts (with tech detection)"
    echo
    cat "$OUT/live.jsonl" 2>/dev/null \
      | jq -r '"- \(.url) — \(.title // "(no title)") — \(.tech // [] | join(", "))"' \
      | head -30 || true

    echo
    echo "## Next steps"
    echo
    echo "1. Review findings above against scope — filter out-of-scope hosts"
    echo "2. Manually verify critical/high findings (nuclei can false-positive)"
    echo "3. Deep-dive on interesting tech (admin panels, APIs, auth flows)"
    echo "4. Content discovery: \`ffuf -u https://TARGET/FUZZ -w ~/Desktop/bug-bounty/SecLists/Discovery/Web-Content/common.txt\`"
    echo "5. Draft reports using templates in \`../templates/\`"
    echo
    echo "## Files"
    echo
    ls -la "$OUT" | tail -n +2 | awk '{ print "- `" $NF "`" }'
} > "$REPORT"

success "Report: $REPORT"
echo
log "Open with: open \"$REPORT\""
