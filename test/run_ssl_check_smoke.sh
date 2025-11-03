#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT_DIR/domain_lookup_interactive.sh"

if [[ ! -f "$SCRIPT" ]]; then
  echo "ERROR: $SCRIPT not found" >&2
  exit 2
fi

echo "Running SSL quick-check smoke test..."

bash "$SCRIPT" --ssl-check example.com > /tmp/ssl_out.txt || true

cat /tmp/ssl_out.txt

if ! grep -q "Testing: http://example.com" /tmp/ssl_out.txt; then
  echo "Expected http test line missing" >&2
  exit 3
fi

echo "ssl quick-check smoke test: PASS"
exit 0
