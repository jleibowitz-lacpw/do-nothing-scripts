#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT_DIR/domain_lookup.sh"

if [[ ! -f "$SCRIPT" ]]; then
  echo "ERROR: $SCRIPT not found" >&2
  exit 2
fi

echo "Running open-external smoke test..."

# Capture output
OUT=$(bash "$SCRIPT" --open-external example.com)

echo "$OUT"

# Basic assertions: ensure at least one known URL is printed
if ! echo "$OUT" | grep -q "https://whatsmydns.net/#A/example.com"; then
  echo "Expected whatsmydns URL not printed" >&2
  exit 3
fi

if ! echo "$OUT" | grep -q "https://www.ssllabs.com/ssltest/analyze.html?d=example.com"; then
  echo "Expected ssllabs URL not printed" >&2
  exit 4
fi

echo "open-external smoke test: PASS"
exit 0
