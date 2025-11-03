#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT_DIR/domain_lookup_interactive.sh"

if [[ ! -f "$SCRIPT" ]]; then
  echo "ERROR: $SCRIPT not found" >&2
  exit 2
fi

OUT=$(bash "$SCRIPT" --dns-explore example.com || true)

echo "$OUT"

if ! echo "$OUT" | grep -q "A: "; then
  echo "A record not printed" >&2
  exit 3
fi

if ! echo "$OUT" | grep -q "SOA: "; then
  echo "SOA not printed" >&2
  exit 4
fi

if ! echo "$OUT" | grep -q "TXT: "; then
  echo "TXT not printed" >&2
  exit 5
fi

echo "dns explorer smoke test: PASS"
exit 0
