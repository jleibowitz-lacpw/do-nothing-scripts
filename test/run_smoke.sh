#!/usr/bin/env bash
set -eu
# Simple smoke test: run the minimal domain lookup script and ensure it exits 0
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIN_SCRIPT="$ROOT_DIR/bin/domain_lookup_min.sh"

if [[ ! -x "$MIN_SCRIPT" ]]; then
  echo "ERROR: $MIN_SCRIPT not found or not executable" >&2
  exit 2
fi

echo "Running smoke test: $MIN_SCRIPT --host example.com"
if "$MIN_SCRIPT" --host example.com; then
  echo "Smoke test: PASS"
  exit 0
else
  echo "Smoke test: FAIL" >&2
  exit 1
fi
