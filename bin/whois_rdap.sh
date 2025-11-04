#!/usr/bin/env bash

# Minimal WHOIS/RDAP helper: prefer local whois output when available,
# otherwise print RDAP/ICANN links. Small help and Windows-friendly open.
# Usage: whois_rdap.sh <domain> [--open]

set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<USAGE
Usage: $0 <domain> [--open] [-h|--help]

Examples:
  $0 example.com
  $0 example.com --open   # open RDAP in default browser (if available)
USAGE
}

if [ "$#" -lt 1 ]; then
  usage
  exit 2
fi

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

domain=$1
open_flag=false
if [ "${2:-}" = "--open" ]; then
  open_flag=true
fi

# Load library if present (for open_url helper)
lib="$(dirname "$0")/domain_lookup_lib.sh"
if [ -r "$lib" ]; then
  # shellcheck disable=SC1090
  source "$lib"
fi

print_whois() {
  if command -v whois >/dev/null 2>&1; then
    echo "Local whois summary:"
    # Best-effort extraction: print the first Registrar-like and Expiry-like lines
    whois "$domain" 2>/dev/null | awk 'BEGIN{IGNORECASE=1} /Registrar:/ {print; found_reg=1} /Registry Expiry Date|Expiry Date|Expiration Date/ {print; found_exp=1} (found_reg && found_exp){exit}' || true
  else
    echo "Local whois: (whois command not installed)"
  fi
}

print_rdap_links() {
  echo "RDAP lookup (use in browser):"
  echo "  https://rdap.org/domain/$domain"
  echo "ICANN RDAP search: https://rdap.icann.org/lookup?domain=$domain"
}

if command -v whois >/dev/null 2>&1; then
  print_whois
else
  print_rdap_links
fi

if [ "$open_flag" = true ]; then
  url="https://rdap.org/domain/$domain"
  if command -v open_url >/dev/null 2>&1; then
    open_url "$url"
  elif command -v explorer.exe >/dev/null 2>&1; then
    explorer.exe "$url" 2>/dev/null &
  elif command -v pwsh.exe >/dev/null 2>&1; then
    # PowerShell Core on Windows
    pwsh.exe -NoProfile -Command "Start-Process '$url'" 2>/dev/null &
  elif command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command "Start-Process '$url'" 2>/dev/null &
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url" 2>/dev/null &
  else
    echo "Cannot open browser automatically; URL: $url"
  fi
fi

exit 0
