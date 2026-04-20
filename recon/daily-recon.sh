#!/usr/bin/env bash
# Daily recon — diff-aware continuous monitoring for bug bounty programs.
#
# How it works:
#   1. Reads list of authorized targets from programs.txt
#   2. Runs passive subfinder + httpx on each
#   3. Diffs against yesterday's subdomain list
#   4. Runs nuclei ONLY on NEW assets (fresh attack surface)
#   5. Writes a concise daily-summary.md
#   6. Sends a macOS notification if anything interesting
#   7. Optionally commits to a private git repo
#
# This script is meant to run under launchd/cron at ~6am daily.
# It produces a summary you can check over coffee in <30 seconds.
#
# Cost: $0 tokens — pure bash + CLIs. Claude is never involved.
#
# Setup:
#   1. Create programs.txt in the toolkit root listing authorized targets
#   2. Install launchd job: ./scheduling/install-schedule.sh
#   3. Optional: point HUNTS_REPO at a private git repo for historical tracking

set -euo pipefail

# ---- Configuration -------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROGRAMS_FILE="${PROGRAMS_FILE:-$SCRIPT_DIR/programs.txt}"
OUTPUT_ROOT="${OUTPUT_ROOT:-$SCRIPT_DIR/output/daily}"
TODAY=$(date -u +%Y-%m-%d)
YESTERDAY=$(date -u -v-1d +%Y-%m-%d 2>/dev/null || date -u -d "yesterday" +%Y-%m-%d)
TODAY_DIR="$OUTPUT_ROOT/$TODAY"
YESTERDAY_DIR="$OUTPUT_ROOT/$YESTERDAY"
LOG_FILE="$TODAY_DIR/run.log"

# Optional: private repo for historical hunt data (leave empty to skip git)
HUNTS_REPO="${HUNTS_REPO:-}"

# Severity threshold for notifications (info|low|medium|high|critical)
NOTIFY_MIN_SEVERITY="${NOTIFY_MIN_SEVERITY:-medium}"

# Rate limits (keep low to be a polite hunter)
HTTPX_RATE="${HTTPX_RATE:-100}"
NUCLEI_RATE="${NUCLEI_RATE:-100}"
NUCLEI_CONCURRENCY="${NUCLEI_CONCURRENCY:-20}"

# Whether to scan existing assets too (default: only scan new) — set to 1 to re-scan all
FULL_SCAN="${FULL_SCAN:-0}"

# ---- Setup output dir ----------------------------------------------------
mkdir -p "$TODAY_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log()     { echo "[$(date +%H:%M:%S)] [+] $*"; }
success() { echo "[$(date +%H:%M:%S)] [✓] $*"; }
warn()    { echo "[$(date +%H:%M:%S)] [!] $*"; }

log "Daily recon starting — $TODAY"
log "Programs file: $PROGRAMS_FILE"
log "Output:        $TODAY_DIR"

# ---- Validate programs.txt exists ----------------------------------------
if [ ! -f "$PROGRAMS_FILE" ]; then
    warn "No programs.txt found. Create one with one target domain per line."
    warn "Example: echo 'hackerone.com' > $PROGRAMS_FILE"
    exit 0
fi

# Strip comments and blanks — bash 3.2 compatible (no mapfile)
TARGETS=()
while IFS= read -r line; do
    TARGETS+=("$line")
done < <(grep -vE '^(\s*#|\s*$)' "$PROGRAMS_FILE" | tr -d ' \t\r')

if [ ${#TARGETS[@]} -eq 0 ]; then
    warn "programs.txt has no targets. Exiting."
    exit 0
fi

log "Targets: ${#TARGETS[@]} — ${TARGETS[*]}"

# ---- Run per-target scan -------------------------------------------------
TOTAL_NEW_SUBS=0
TOTAL_NEW_FINDINGS=0
TOTAL_HIGH_FINDINGS=0
PER_TARGET_SUMMARY=()

for TARGET in "${TARGETS[@]}"; do
    log "=== $TARGET ==="
    T_DIR="$TODAY_DIR/$TARGET"
    Y_DIR="$YESTERDAY_DIR/$TARGET"
    mkdir -p "$T_DIR"

    # 1. Subdomain enum
    subfinder -d "$TARGET" -silent -all > "$T_DIR/subdomains.txt" 2>/dev/null || true
    SUB_COUNT=$(wc -l < "$T_DIR/subdomains.txt" | tr -d ' ')

    # 2. Diff vs yesterday to find NEW assets
    if [ -f "$Y_DIR/subdomains.txt" ]; then
        comm -23 <(sort "$T_DIR/subdomains.txt") <(sort "$Y_DIR/subdomains.txt") > "$T_DIR/new-subdomains.txt"
    else
        # First run — everything is "new"
        cp "$T_DIR/subdomains.txt" "$T_DIR/new-subdomains.txt"
        warn "First run for $TARGET — all $SUB_COUNT subdomains treated as new"
    fi
    NEW_SUBS=$(wc -l < "$T_DIR/new-subdomains.txt" | tr -d ' ')
    TOTAL_NEW_SUBS=$((TOTAL_NEW_SUBS + NEW_SUBS))
    log "$TARGET: $SUB_COUNT total subdomains ($NEW_SUBS new)"

    # 3. Probe new assets with httpx (or all if FULL_SCAN=1)
    SCAN_INPUT="$T_DIR/new-subdomains.txt"
    [ "$FULL_SCAN" = "1" ] && SCAN_INPUT="$T_DIR/subdomains.txt"

    if [ ! -s "$SCAN_INPUT" ]; then
        log "$TARGET: no new assets to probe, skipping httpx+nuclei"
        PER_TARGET_SUMMARY+=("$TARGET|$SUB_COUNT|$NEW_SUBS|0|0")
        continue
    fi

    httpx -silent \
        -list "$SCAN_INPUT" \
        -status-code -title -tech-detect -ip \
        -json \
        -rate-limit "$HTTPX_RATE" \
        > "$T_DIR/live.jsonl" 2>/dev/null || true
    jq -r '.url' "$T_DIR/live.jsonl" 2>/dev/null | sort -u > "$T_DIR/live.txt" || true
    LIVE_COUNT=$(wc -l < "$T_DIR/live.txt" | tr -d ' ')
    log "$TARGET: $LIVE_COUNT live hosts to scan"

    # 4. Nuclei on live new assets — medium+ only for signal
    if [ "$LIVE_COUNT" -gt 0 ]; then
        nuclei -silent \
            -list "$T_DIR/live.txt" \
            -severity "medium,high,critical" \
            -jsonl -output "$T_DIR/nuclei.jsonl" \
            -rate-limit "$NUCLEI_RATE" \
            -c "$NUCLEI_CONCURRENCY" \
            2>/dev/null || true
        NEW_FINDINGS=$(wc -l < "$T_DIR/nuclei.jsonl" 2>/dev/null | tr -d ' ' || echo 0)
        HIGH_FINDINGS=$(grep -Ec '"severity":"(high|critical)"' "$T_DIR/nuclei.jsonl" 2>/dev/null) || HIGH_FINDINGS=0
    else
        NEW_FINDINGS=0
        HIGH_FINDINGS=0
    fi

    TOTAL_NEW_FINDINGS=$((TOTAL_NEW_FINDINGS + NEW_FINDINGS))
    TOTAL_HIGH_FINDINGS=$((TOTAL_HIGH_FINDINGS + HIGH_FINDINGS))
    log "$TARGET: $NEW_FINDINGS total findings ($HIGH_FINDINGS high/critical)"

    PER_TARGET_SUMMARY+=("$TARGET|$SUB_COUNT|$NEW_SUBS|$NEW_FINDINGS|$HIGH_FINDINGS")
done

# ---- Generate daily summary ----------------------------------------------
SUMMARY="$TODAY_DIR/daily-summary.md"

{
    echo "# Daily Recon Summary — $TODAY"
    echo
    echo "- **Targets scanned:** ${#TARGETS[@]}"
    echo "- **New subdomains (24h):** $TOTAL_NEW_SUBS"
    echo "- **New findings (medium+):** $TOTAL_NEW_FINDINGS"
    echo "- **High/Critical findings:** $TOTAL_HIGH_FINDINGS"
    echo "- **Mode:** $([ "$FULL_SCAN" = "1" ] && echo 'full rescan' || echo 'new-assets-only')"
    echo
    echo "## Per-target breakdown"
    echo
    echo "| Target | Total subs | New subs | New findings | High/Crit |"
    echo "|--------|-----------:|---------:|-------------:|----------:|"
    for row in "${PER_TARGET_SUMMARY[@]}"; do
        IFS='|' read -r target subs new_subs findings high <<< "$row"
        echo "| $target | $subs | $new_subs | $findings | $high |"
    done
    echo

    # New subdomains section
    if [ "$TOTAL_NEW_SUBS" -gt 0 ]; then
        echo "## 🆕 New subdomains discovered"
        echo
        for TARGET in "${TARGETS[@]}"; do
            NS="$TODAY_DIR/$TARGET/new-subdomains.txt"
            if [ -s "$NS" ]; then
                echo "### $TARGET"
                echo
                echo "\`\`\`"
                head -20 "$NS"
                TOTAL=$(wc -l < "$NS" | tr -d ' ')
                [ "$TOTAL" -gt 20 ] && echo "... and $((TOTAL - 20)) more"
                echo "\`\`\`"
                echo
            fi
        done
    fi

    # Findings section
    if [ "$TOTAL_NEW_FINDINGS" -gt 0 ]; then
        echo "## 🚨 New findings"
        echo
        for TARGET in "${TARGETS[@]}"; do
            NF="$TODAY_DIR/$TARGET/nuclei.jsonl"
            if [ -s "$NF" ]; then
                echo "### $TARGET"
                echo
                jq -r '"- **\(.info.severity | ascii_upcase)** — [\(.info.name)](\(."matched-at" // .url)) · template: `\(."template-id")`"' "$NF" 2>/dev/null
                echo
            fi
        done
    fi

    echo
    echo "## Files (raw data)"
    echo
    find "$TODAY_DIR" -maxdepth 2 -type f 2>/dev/null \
        | sed "s|$TODAY_DIR/||" \
        | sort \
        | awk '{ print "- `" $0 "`" }'

    echo
    echo "## Next steps"
    echo
    if [ "$TOTAL_HIGH_FINDINGS" -gt 0 ]; then
        echo "1. ⚠️ **$TOTAL_HIGH_FINDINGS HIGH/CRITICAL finding(s) need review.** Open the finding URLs above."
        echo "2. Triage for false positives (nuclei often cries wolf — see learning/05-writing-reports.md)."
        echo "3. If real: reproduce manually, draft PoC, write report using templates/vulnerability-report.md."
    elif [ "$TOTAL_NEW_SUBS" -gt 0 ]; then
        echo "1. Review new subdomains above for interesting tech (admin panels, staging, APIs)."
        echo "2. Manually probe promising hosts with content-discovery.sh or Caido."
        echo "3. No nuclei findings ≠ no bugs — nuclei misses business logic, auth, IDOR."
    else
        echo "Nothing new today. Consider: (a) adding more programs to programs.txt, (b) FULL_SCAN=1 ./recon/daily-recon.sh to re-scan existing assets, (c) manual hunting on known endpoints."
    fi
} > "$SUMMARY"

success "Summary written: $SUMMARY"

# ---- macOS notification --------------------------------------------------
if command -v osascript >/dev/null 2>&1; then
    MSG="New subs: $TOTAL_NEW_SUBS · Findings: $TOTAL_NEW_FINDINGS · High/Crit: $TOTAL_HIGH_FINDINGS"

    # Only notify if anything interesting happened
    if [ "$TOTAL_NEW_SUBS" -gt 0 ] || [ "$TOTAL_NEW_FINDINGS" -gt 0 ]; then
        osascript -e "display notification \"$MSG\" with title \"Bug Bounty — Daily Recon\" sound name \"Glass\"" 2>/dev/null || true
        log "Notification sent: $MSG"
    fi
fi

# ---- Optional: push to private hunts repo --------------------------------
if [ -n "$HUNTS_REPO" ] && [ -d "$HUNTS_REPO/.git" ]; then
    log "Syncing to hunts repo: $HUNTS_REPO"
    TARGET_DIR="$HUNTS_REPO/daily/$TODAY"
    mkdir -p "$TARGET_DIR"
    cp -R "$TODAY_DIR/"* "$TARGET_DIR/" 2>/dev/null || true

    (
        cd "$HUNTS_REPO"
        git add "daily/$TODAY" 2>/dev/null
        if ! git diff --cached --quiet 2>/dev/null; then
            git commit -m "daily recon: $TODAY — $TOTAL_NEW_SUBS new subs, $TOTAL_NEW_FINDINGS findings" 2>/dev/null || true
            git push origin main 2>/dev/null && success "Pushed to hunts repo" || warn "git push failed (check auth)"
        else
            log "No changes to commit"
        fi
    )
fi

success "Daily recon complete — $TODAY"
echo
echo "Open summary:  open \"$SUMMARY\""
echo "Raw data:      ls \"$TODAY_DIR\""
