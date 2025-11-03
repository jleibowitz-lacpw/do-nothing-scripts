#!/usr/bin/env bash
set -euo pipefail

# Small demo runner: generate a markdown diagnostics report for a domain
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

domain=${1:-example.com}
out="./demo_${domain//./_}_report.md"

if [[ ! -x "${SCRIPT_DIR}/domain_lookup_min.sh" ]]; then
  echo "domain_lookup_min.sh missing or not executable" >&2
  exit 2
fi

echo "Generating demo report for $domain -> $out"
bash "${SCRIPT_DIR}/domain_lookup_min.sh" --host "$domain" --output-md "$out"
echo "Wrote: $out"
