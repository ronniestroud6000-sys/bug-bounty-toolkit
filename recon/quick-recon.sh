#!/usr/bin/env bash
# Quick recon — the "new program just dropped, scan it while I read the scope page" script.
#
# Usage: ./recon/quick-recon.sh <target-domain>
# Time:  2-5 minutes
#
# Does: subdomain enum → live probe → nuclei critical/high only

exec "$(dirname "$0")/full-recon.sh" "$@" --quick
