#!/usr/bin/env bash
# Content discovery — find hidden paths, files, parameters.
#
# Usage:  ./recon/content-discovery.sh <url> [wordlist]
# Example: ./recon/content-discovery.sh https://example.com/
#          ./recon/content-discovery.sh https://example.com/ api
#
# Wordlist shortcuts: common, big, raft, api, aws (maps to SecLists paths)

set -euo pipefail

URL="${1:-}"
LIST="${2:-common}"

if [ -z "$URL" ]; then
    cat <<USAGE
Usage: $0 <url> [wordlist]

Wordlist shortcuts:
  common   Discovery/Web-Content/common.txt              (default, fast)
  big      Discovery/Web-Content/big.txt                 (larger, slower)
  raft     Discovery/Web-Content/raft-large-directories.txt
  api      Discovery/Web-Content/api/api-endpoints.txt   (for APIs)
  aws      Discovery/Web-Content/aws-s3-bucket-names.txt (S3 hunting)

Example: $0 https://target.com/api/ api
USAGE
    exit 1
fi

WORDLIST_BASE="${WORDLIST_BASE:-$HOME/Desktop/bug-bounty/SecLists/Discovery/Web-Content}"

case "$LIST" in
    common) WL="$WORDLIST_BASE/common.txt" ;;
    big)    WL="$WORDLIST_BASE/big.txt" ;;
    raft)   WL="$WORDLIST_BASE/raft-large-directories.txt" ;;
    api)    WL="$WORDLIST_BASE/api/api-endpoints.txt" ;;
    aws)    WL="$WORDLIST_BASE/aws-s3-bucket-names.txt" ;;
    *)      WL="$LIST" ;;  # treat as a path
esac

[ -f "$WL" ] || { echo "Wordlist not found: $WL"; exit 1; }

# Normalize URL: ensure it ends with /FUZZ
case "$URL" in
    *FUZZ*) ;;
    */)     URL="${URL}FUZZ" ;;
    *)      URL="${URL}/FUZZ" ;;
esac

echo "[+] Target:   $URL"
echo "[+] Wordlist: $WL ($(wc -l < "$WL" | tr -d ' ') entries)"
echo

ffuf -u "$URL" \
     -w "$WL" \
     -mc 200,204,301,302,307,401,403 \
     -fs 0 \
     -rate 100 \
     -of md \
     -o "output/ffuf-$(date +%s).md" \
     "$@"
