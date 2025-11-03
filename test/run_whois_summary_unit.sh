#!/usr/bin/env bash
set -euo pipefail

# Unit-ish test for get_whois_summary: assert it prints 4 pipe-separated fields
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

source ./domain_lookup_lib.sh
out=$(get_whois_summary example.com)
fields=$(awk -F"|" '{print NF}' <<<"$out")
if [ "$fields" -eq 4 ]; then
  echo "whois_summary unit: PASS"
  exit 0
else
  echo "whois_summary unit: FAIL - got $out"
  exit 1
fi
