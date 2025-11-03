#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT_DIR/domain_lookup_interactive.sh"

if [[ ! -f "$SCRIPT" ]]; then
  echo "ERROR: $SCRIPT not found" >&2
  exit 2
fi

echo "Running ping/traceroute smoke test..."

# Run the non-interactive ping-traceroute action; it's allowed to print warnings if tools missing
bash "$SCRIPT" --ping-traceroute example.com

echo "ping/traceroute smoke test: PASS"
exit 0
