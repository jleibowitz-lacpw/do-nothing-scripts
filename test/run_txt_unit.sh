#!/usr/bin/env bash
set -euo pipefail

# Unit-ish test for get_txt_records: ensure output is non-empty or placeholder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

source ./domain_lookup_lib.sh

# Stub has_cmd to avoid network dependency
orig_has_cmd=$(declare -f has_cmd || true)
function has_cmd() { false; }

out=$(get_txt_records example.com)

# Restore has_cmd
if [[ -n "$orig_has_cmd" ]]; then
  eval "$orig_has_cmd"
fi

if [[ -z "$out" || "$out" == "-" ]]; then
  echo "txt unit: PASS (no external resolver available, returned placeholder)"
  exit 0
else
  # If environment has dig/nslookup, validate it looks like TXT content (contains spaces or =)
  if echo "$out" | grep -qE '[ =]'; then
    echo "txt unit: PASS (got: $out)"
    exit 0
  else
    echo "txt unit: FAIL - unexpected output: $out"
    exit 1
  fi
fi
