#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT_DIR/bin/domain_lookup_min.sh"
OUT="$ROOT_DIR/test/out_example_md.md"

echo "Running markdown smoke test..."
rm -f "$OUT"
bash "$SCRIPT" --host example.com --output-md "$OUT"

if [[ ! -f "$OUT" ]]; then
  echo "Markdown output not created" >&2
  exit 2
fi

echo "Markdown smoke test: PASS"
