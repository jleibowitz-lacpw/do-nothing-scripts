#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT_DIR/domain_lookup_interactive.sh"

if [[ ! -f "$SCRIPT" ]]; then
  echo "ERROR: $SCRIPT not found" >&2
  exit 2
fi

OUT=$(bash "$SCRIPT" --http-check example.com || true)

echo "$OUT"

if ! echo "$OUT" | grep -q "URL: http://example.com"; then
  echo "Expected http test block missing" >&2
  exit 3
fi

echo "http quick-check smoke test: PASS"
exit 0
