#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT_DIR/domain_lookup_interactive.sh"

if [[ ! -f "$SCRIPT" ]]; then
  echo "ERROR: $SCRIPT not found" >&2
  exit 2
fi

echo "Running interactive open-external smoke test..."

OUT=$(bash "$SCRIPT" --open-external example.com)

echo "$OUT"

if ! echo "$OUT" | grep -q "https://whatsmydns.net/#A/example.com"; then
  echo "Expected whatsmydns URL not printed" >&2
  exit 3
fi

echo "interactive open-external smoke test: PASS"
exit 0
