#!/usr/bin/env bash
set -euo pipefail

# Unit test for get_apex: check common inputs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

source ./domain_lookup_lib.sh

declare -A cases=(
  ["example.com"]="example.com"
  ["www.example.com"]="example.com"
  ["sub.www.example.com"]="sub.www.example.com"
)

for inp in "${!cases[@]}"; do
  expect=${cases[$inp]}
  out=$(get_apex "$inp")
  if [[ "$out" != "$expect" ]]; then
    echo "get_apex unit: FAIL - input='$inp' expected='$expect' got='$out'"
    exit 1
  fi
done

echo "get_apex unit: PASS"
exit 0
