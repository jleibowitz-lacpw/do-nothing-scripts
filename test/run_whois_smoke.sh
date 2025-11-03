#!/usr/bin/env bash
set -euo pipefail

# Smoke test: whois_rdap prints RDAP links or whois summary
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

output=$(bash whois_rdap.sh example.com)
if echo "$output" | grep -q "rdap.org"; then
  echo "whois smoke: PASS"
  exit 0
else
  echo "whois smoke: FAIL"
  echo "$output"
  exit 1
fi
