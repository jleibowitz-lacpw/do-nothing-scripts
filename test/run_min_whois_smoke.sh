#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

output=$(bash "$SCRIPT_DIR/lib/domain_lookup_min.sh" --host example.com --whois)
if echo "$output" | grep -q "rdap.org\|RDAP lookup"; then
  echo "domain_min whois smoke: PASS"
  exit 0
else
  echo "domain_min whois smoke: FAIL"
  echo "$output"
  exit 1
fi
