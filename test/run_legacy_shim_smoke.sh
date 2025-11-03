#!/usr/bin/env bash
set -euo pipefail

# Smoke test for legacy shim `domain_lookup.sh` which should delegate to domain_lookup_min.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

if [[ ! -x ./domain_lookup.sh ]]; then
  echo "domain_lookup.sh missing or not executable; skipping shim smoke" >&2
  exit 2
fi

output=$(bash ./domain_lookup.sh --host example.com)
# The canonical minimal script prints a heading like '--- example.com ---'
if echo "$output" | grep -F -- "--- example.com ---" >/dev/null 2>&1; then
  echo "legacy shim smoke: PASS"
  exit 0
else
  echo "legacy shim smoke: FAIL - output did not contain header" >&2
  echo "--- OUTPUT ---"
  echo "$output"
  exit 1
fi
