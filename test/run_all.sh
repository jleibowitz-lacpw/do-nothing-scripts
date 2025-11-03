#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPTS=("$ROOT_DIR/test/run_smoke.sh" "$ROOT_DIR/test/run_smoke_md.sh" "$ROOT_DIR/test/run_sentry_smoke.sh")
SCRIPTS+=("$ROOT_DIR/test/run_whois_smoke.sh" "$ROOT_DIR/test/run_apex_www_smoke.sh" "$ROOT_DIR/test/run_whois_summary_unit.sh")
SCRIPTS+=("$ROOT_DIR/test/run_min_whois_smoke.sh")
SCRIPTS+=("$ROOT_DIR/test/run_export_smoke.sh")
SCRIPTS+=("$ROOT_DIR/test/run_mx_unit.sh")
SCRIPTS+=("$ROOT_DIR/test/run_txt_unit.sh")
SCRIPTS+=("$ROOT_DIR/test/run_legacy_shim_smoke.sh")
failures=0

for s in "${SCRIPTS[@]}"; do
  echo "--------------------------------------------------"
  echo "Running: $s"
  if bash -x "$s"; then
    echo "OK: $s"
  else
    echo "FAIL: $s"
    failures=$((failures+1))
  fi
done

echo "--------------------------------------------------"
if [[ $failures -eq 0 ]]; then
  echo "ALL SMOKE TESTS: PASS"
  exit 0
else
  echo "SMOKE TESTS FAILED: $failures"
  exit 2
fi
