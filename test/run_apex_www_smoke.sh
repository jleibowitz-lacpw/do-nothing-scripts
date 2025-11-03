#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

output=$(bash apex_www_test.sh example.com)
if echo "$output" | grep -q "Host: example.com" && echo "$output" | grep -q "Host: www.example.com"; then
  echo "apex/www smoke: PASS"
  exit 0
else
  echo "apex/www smoke: FAIL"
  echo "$output"
  exit 1
fi
