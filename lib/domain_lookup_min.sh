#!/usr/bin/env bash
set -euo pipefail

# Minimal domain lookup implementation
# Generate Markdown output if --output-md is specified
if [[ "${1:-}" == "--host" ]]; then
  domain="$2"
  if [[ "${3:-}" == "--output-md" ]]; then
    echo "# Domain Lookup Report\n\n- Host: $domain" > "$4"
    echo "Markdown output created at $4"
  else
    echo "Domain lookup for: $domain"
    echo "RDAP lookup (use in browser):"
    echo "  https://rdap.org/domain/$domain"
    echo "ICANN RDAP search: https://rdap.icann.org/lookup?domain=$domain"
  fi
else
  echo "Usage: $0 --host <domain> [--output-md <file>]"
  exit 1
fi
exit 0