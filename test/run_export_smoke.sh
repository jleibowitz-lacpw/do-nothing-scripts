#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

outfile="test_export_example.md"
rm -f "$outfile"

bash domain_lookup_interactive.sh --export-md example.com "$outfile"
if [[ -f "$outfile" ]]; then
  echo "export smoke: PASS"
  exit 0
else
  echo "export smoke: FAIL"
  exit 1
fi
