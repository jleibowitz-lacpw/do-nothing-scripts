#!/usr/bin/env bash
# Small, well-documented helper to compare apex vs www for typical domains.
# - If the provided host looks like an apex (heuristic: single dot), test both apex and www.
# - If it's a multi-label host (e.g. sub.example.com), only test the given host.
# - For each host we print A/AAAA and a short HTTP status (if curl available).

set -euo pipefail
IFS=$'\n\t'

progname=$(basename "$0")

usage() {
  cat <<EOF
Usage: $progname <domain>

Examples:
  $progname example.com    # tests example.com and www.example.com (apex heuristic)
  $progname sub.example.com # tests only sub.example.com

Heuristic: domains with exactly one dot (e.g. example.com) are considered apex.
EOF
}

if [ "$#" -ne 1 ]; then
  usage
  exit 2
fi

domain=$1

# Count dots in the domain (simple heuristic)
dot_count=$(awk -F"." '{print NF-1}' <<<"$domain")

is_apex=false
if [ "$dot_count" -eq 1 ]; then
  is_apex=true
fi

hosts_to_test=()
if [ "$is_apex" = true ]; then
  hosts_to_test+=("$domain" "www.$domain")
else
  hosts_to_test+=("$domain")
fi

# Helper: print A/AAAA using dig if available, fallback to nslookup
print_a_records() {
  host=$1
  if command -v dig >/dev/null 2>&1; then
    a=$(dig +short A "$host" | paste -s -d',' -)
    aaaa=$(dig +short AAAA "$host" | paste -s -d',' -)
  else
    a=$(nslookup -type=A "$host" 2>/dev/null | awk '/^Name:|^Address:|^Addresses:/{print $0}' | paste -s -d',' -)
    aaaa=$(nslookup -type=AAAA "$host" 2>/dev/null | awk '/^Address:/{print $2}' | paste -s -d',' -)
  fi
  printf "  A: %s\n" "${a:--}"
  printf "  AAAA: %s\n" "${aaaa:--}"
}

# Helper: print short HTTP status using curl if available
print_http_status() {
  host=$1
  if command -v curl >/dev/null 2>&1; then
    # Try https then http
    status_https=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 5 "https://$host" || echo "000")
    status_http=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 5 "http://$host" || echo "000")
    printf "  HTTPS: %s\n" "$status_https"
    printf "  HTTP:  %s\n" "$status_http"
  else
    printf "  HTTPS: (curl missing)\n"
    printf "  HTTP:  (curl missing)\n"
  fi
}

printf "Apex/www smart test for input: %s\n\n" "$domain"
for h in "${hosts_to_test[@]}"; do
  printf "%s\n" "Host: $h"
  print_a_records "$h"
  print_http_status "$h"
  printf "\n"
done

exit 0
