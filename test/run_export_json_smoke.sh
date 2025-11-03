#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

outfile="test_export_example.json"
rm -f "$outfile"

bash domain_lookup_min.sh --host example.com --output-json "$outfile"
if [[ -s "$outfile" ]]; then
  echo "export json smoke: PASS"
  exit 0
else
  echo "export json smoke: FAIL"
  exit 1
fi
