#!/usr/bin/env bash
# Minimal WHOIS/RDAP helper: prefer local whois output when available, otherwise print RDAP/ICANN links.
# Usage: whois_rdap.sh <domain> [--open]

set -euo pipefail
IFS=$'\n\t'

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <domain> [--open]"
  exit 2
fi

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
    # Try to extract Registrar and Registry Expiry Date lines if present
    whois "$domain" 2>/dev/null | awk -F":" '/Registrar:|registrar:|Registry Expiry Date|Expiry Date|Expiration Date/{print $1":"$2; exit}' || true
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
  if command -v open_url >/dev/null 2>&1; then
    open_url "https://rdap.org/domain/$domain"
  elif command -v explorer.exe >/dev/null 2>&1; then
    explorer.exe "https://rdap.org/domain/$domain" 2>/dev/null &
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "https://rdap.org/domain/$domain" 2>/dev/null &
  else
    echo "Cannot open browser automatically; URL: https://rdap.org/domain/$domain"
  fi
fi

exit 0
