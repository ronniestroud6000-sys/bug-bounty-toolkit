#!/usr/bin/env bash
# Local triage — zero-token filters over nuclei findings.
#
# Use this BEFORE involving Claude so you only send it interesting data.
# All operations are local jq/grep — $0 in tokens.
#
# Usage:
#   ./recon/triage.sh <command> [args]
#
# Commands:
#   today                    Show today's summary
#   findings <target>        Show nuclei findings for a target (today)
#   high                     Show all HIGH/CRITICAL findings across all targets (today)
#   new-subs <target>        Show new subdomains for a target (today)
#   interesting              Show hosts with "interesting" tech (admin, api, staging, etc)
#   dedupe                   Show findings grouped by template-id (spot patterns)
#   tech <word>              Find all hosts running a specific tech (e.g., wordpress)
#   compare <date1> <date2>  Diff two days of findings
#   clean <days>             Delete scan output older than N days

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAILY="$SCRIPT_DIR/output/daily"
TODAY=$(date -u +%Y-%m-%d)

CMD="${1:-help}"

case "$CMD" in
    today)
        SUMMARY="$DAILY/$TODAY/daily-summary.md"
        if [ -f "$SUMMARY" ]; then
            cat "$SUMMARY"
        else
            echo "No scan for today. Run: ./recon/daily-recon.sh"
        fi
        ;;

    findings)
        TARGET="${2:-}"
        [ -z "$TARGET" ] && { echo "Usage: $0 findings <target>"; exit 1; }
        NF="$DAILY/$TODAY/$TARGET/nuclei.jsonl"
        if [ ! -f "$NF" ] || [ ! -s "$NF" ]; then
            echo "No findings for $TARGET today."
            exit 0
        fi
        jq -r '"\(.info.severity | ascii_upcase) | \(.info.name) | \(."matched-at" // .url) | \(."template-id")"' "$NF"
        ;;

    high)
        echo "# HIGH/CRITICAL findings — $TODAY"
        echo
        FOUND=0
        for target_dir in "$DAILY/$TODAY"/*/; do
            [ -d "$target_dir" ] || continue
            TARGET=$(basename "$target_dir")
            NF="$target_dir/nuclei.jsonl"
            [ -s "$NF" ] || continue
            MATCHES=$(grep -E '"severity":"(high|critical)"' "$NF" 2>/dev/null || true)
            if [ -n "$MATCHES" ]; then
                echo "## $TARGET"
                echo "$MATCHES" | jq -r '"- **\(.info.severity | ascii_upcase)** [\(.info.name)](\(."matched-at" // .url)) · \(."template-id")"'
                echo
                FOUND=$((FOUND + $(echo "$MATCHES" | wc -l | tr -d ' ')))
            fi
        done
        echo "---"
        echo "Total: $FOUND high/critical finding(s)"
        ;;

    new-subs)
        TARGET="${2:-}"
        [ -z "$TARGET" ] && { echo "Usage: $0 new-subs <target>"; exit 1; }
        NS="$DAILY/$TODAY/$TARGET/new-subdomains.txt"
        if [ ! -s "$NS" ]; then
            echo "No new subdomains for $TARGET today."
            exit 0
        fi
        echo "# New subdomains for $TARGET — $TODAY"
        cat "$NS"
        ;;

    interesting)
        echo "# Interesting live hosts — $TODAY"
        echo "(admin, api, staging, dev, test, internal, beta, demo)"
        echo
        for target_dir in "$DAILY/$TODAY"/*/; do
            [ -d "$target_dir" ] || continue
            TARGET=$(basename "$target_dir")
            LJ="$target_dir/live.jsonl"
            [ -s "$LJ" ] || continue
            MATCHES=$(grep -iE '(admin|api|staging|dev|test|internal|beta|demo|jenkins|jira|confluence|gitlab|phpmyadmin|cpanel)' "$LJ" || true)
            if [ -n "$MATCHES" ]; then
                echo "## $TARGET"
                echo "$MATCHES" | jq -r '"- [\(.url)](\(.url)) — \(.title // "(no title)") — \(.tech // [] | join(", "))"' 2>/dev/null | sort -u
                echo
            fi
        done
        ;;

    dedupe)
        echo "# Findings grouped by template — $TODAY"
        echo "(high counts often = false positive pattern)"
        echo
        find "$DAILY/$TODAY" -name "nuclei.jsonl" -exec cat {} \; 2>/dev/null \
            | jq -r '"\(."template-id") | \(.info.severity)"' 2>/dev/null \
            | sort | uniq -c | sort -rn | head -30
        ;;

    tech)
        WORD="${2:-}"
        [ -z "$WORD" ] && { echo "Usage: $0 tech <word>"; exit 1; }
        echo "# Hosts running '$WORD' — $TODAY"
        echo
        for target_dir in "$DAILY/$TODAY"/*/; do
            [ -d "$target_dir" ] || continue
            TARGET=$(basename "$target_dir")
            LJ="$target_dir/live.jsonl"
            [ -s "$LJ" ] || continue
            MATCHES=$(grep -i "$WORD" "$LJ" || true)
            if [ -n "$MATCHES" ]; then
                echo "## $TARGET"
                echo "$MATCHES" | jq -r '"- \(.url) — \(.tech // [] | join(", "))"' 2>/dev/null | sort -u
                echo
            fi
        done
        ;;

    compare)
        D1="${2:-}"
        D2="${3:-}"
        [ -z "$D1" ] || [ -z "$D2" ] && { echo "Usage: $0 compare <date1> <date2> (YYYY-MM-DD)"; exit 1; }
        echo "# Comparing $D1 vs $D2"
        echo
        for target_dir in "$DAILY/$D1"/*/; do
            [ -d "$target_dir" ] || continue
            TARGET=$(basename "$target_dir")
            D1_SUBS="$DAILY/$D1/$TARGET/subdomains.txt"
            D2_SUBS="$DAILY/$D2/$TARGET/subdomains.txt"
            if [ -f "$D1_SUBS" ] && [ -f "$D2_SUBS" ]; then
                echo "## $TARGET"
                NEW=$(comm -23 <(sort "$D2_SUBS") <(sort "$D1_SUBS") | wc -l | tr -d ' ')
                GONE=$(comm -23 <(sort "$D1_SUBS") <(sort "$D2_SUBS") | wc -l | tr -d ' ')
                echo "- Gained: $NEW subdomains"
                echo "- Lost:   $GONE subdomains"
                echo
            fi
        done
        ;;

    clean)
        DAYS="${2:-30}"
        echo "Deleting scan output older than $DAYS days..."
        find "$DAILY" -maxdepth 1 -type d -mtime +"$DAYS" -name '20*-*-*' -print -exec rm -rf {} \; 2>/dev/null || true
        echo "Done."
        ;;

    help|*)
        grep -E '^#|^\s+[a-z]' "$0" | head -30
        ;;
esac
