#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC2317

# Minimal non-interactive domain diagnostic helper
# Usage: ./domain_lookup_min.sh --host example.com [--both]

print_usage() {
  cat <<EOF
Usage: $0 --host <domain> [--both]

Options:
  --host, -h   Hostname to test (required)
  --output-md  Write a markdown checklist summary to the given file
  --output-json Write a JSON array summary to the given file
  --both       Test both apex and www variants (if applicable)
    --whois      Print a short WHOIS/RDAP summary and exit
  --help       Show this help

This is a lightweight, non-interactive alternative to the main script.
EOF
}

HOST=""
TEST_BOTH=false
OUTPUT_MD=""
OUTPUT_JSON=""
WHOIS_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host|-h)
      shift
      HOST="$1"
      shift
      ;;
    --both)
      TEST_BOTH=true
      shift
      ;;
    --output-md)
      shift
      OUTPUT_MD="$1"
      shift
      ;;
    --output-json)
      shift
      OUTPUT_JSON="$1"
      shift
      ;;
    --help|-H)
      print_usage
      exit 0
      ;;
    --whois)
      shift
      WHOIS_ONLY=true
      ;;
    *)
      echo "Unknown arg: $1" >&2
      print_usage
      exit 2
      ;;
  esac
done

if [[ -z "$HOST" ]]; then
  echo "Error: --host is required" >&2
  print_usage
  exit 2
fi

source "$(dirname "${BASH_SOURCE[0]}")/domain_lookup_lib.sh"
if [[ "$WHOIS_ONLY" == true ]]; then
  # If a local whois binary exists, prefer structured summary; otherwise print RDAP links
  if has_cmd whois; then
    if declare -f get_whois_summary >/dev/null 2>&1; then
      printf "%s\n" "$(get_whois_summary "$HOST")"
      exit 0
    fi
    # If get_whois_summary isn't present, fall back to simple whois output
    whois "$HOST" 2>/dev/null || true
    exit 0
  else
    if [[ -x "$(dirname "${BASH_SOURCE[0]}")/whois_rdap.sh" ]]; then
      bash "$(dirname "${BASH_SOURCE[0]}")/whois_rdap.sh" "$HOST"
      exit 0
    else
      echo "RDAP: https://rdap.org/domain/$HOST"
      exit 0
    fi
  fi
fi
# Build domain list
domains=()
if [[ "$TEST_BOTH" == true ]]; then
  apex=$(get_apex "$HOST")
  domains+=("$apex" "www.$apex")
else
  domains+=("$HOST")
fi

summary=()
for d in "${domains[@]}"; do
  apex=$(get_apex "$d")
  IFS='|' read -r soa ns a aaaa cname <<< "$(get_dns_records "$d" "$apex")"
  pingres=$(ping_check "$d")
  IFS='|' read -r httpres httpsres <<< "$(http_check "$d")"
  # WHOIS registrar/org (best-effort)
  whois_info='-'
  if has_cmd whois; then
    whois_info=$(whois "$apex" 2>/dev/null | awk -F: '/Registrar:|registrar:|OrgName:|org-name:|Org:|organisation:/ {print $2; exit}' | sed 's/^ *//;s/ *$//' || true)
    [[ -z "$whois_info" ]] && whois_info='-'
  fi

  # Print human-readable section
  echo "--- $d ---"
  echo "A: $a"
  echo "CNAME: $cname"
  echo "NS: $ns"
  echo "SOA: $soa"
  echo "Ping: $pingres"
  echo "HTTP: $httpres  HTTPS: $httpsres"
  echo ""

  # Build a single tab-separated summary row for downstream parsing
  summary+=("$d"$'\t'"$soa"$'\t'"$ns"$'\t'"$a"$'\t'"$aaaa"$'\t'"$cname"$'\t'"$whois_info"$'\t'"$pingres"$'\t'"$httpres"$'\t'"$httpsres")
done

# Print table
echo "=== Summary ==="
if has_cmd column; then
  printf "%s\n" "${summary[@]}" | column -t -s $'\t'
else
  printf "%s\n" "${summary[@]}"
fi

if [[ -n "$OUTPUT_MD" ]]; then
  mdfile="$OUTPUT_MD"
  {
    echo "# Domain diagnostics checklist"
    echo
    echo "Generated: $(date --iso-8601=seconds 2>/dev/null || date)"
    echo
    for row in "${summary[@]}"; do
      IFS=$'\t' read -r dom soa ns a aaaa cname whois_info pingres httpres httpsres <<< "$row"
        echo "## $dom"
        echo
        # Decide checked state: mark as checked when evidence exists or status is OK
    if [[ "$a" != "-" ]]; then a_chk='[x]'; else a_chk='[ ]'; fi
    if [[ "$aaaa" != "-" ]]; then aaaa_chk='[x]'; else aaaa_chk='[ ]'; fi
    if [[ "$cname" != "-" ]]; then cname_chk='[x]'; else cname_chk='[ ]'; fi
    if [[ "$ns" != "-" ]]; then ns_chk='[x]'; else ns_chk='[ ]'; fi
    if [[ "$soa" != "-" ]]; then soa_chk='[x]'; else soa_chk='[ ]'; fi
    if [[ "$whois_info" != "-" ]]; then whois_chk='[x]'; else whois_chk='[ ]'; fi
        if [[ "$pingres" == "OK" ]]; then ping_chk='[x]'; else ping_chk='[ ]'; fi
        if [[ "$httpres" == "OK" ]]; then http_chk='[x]'; else http_chk='[ ]'; fi
        if [[ "$httpsres" == "OK" ]]; then https_chk='[x]'; else https_chk='[ ]'; fi

  printf " - %s A record: \`%s\`\n" "$a_chk" "$a"
  printf " - %s AAAA record: \`%s\`\n" "$aaaa_chk" "$aaaa"
  printf " - %s CNAME: \`%s\`\n" "$cname_chk" "$cname"
  printf " - %s NS: \`%s\`\n" "$ns_chk" "$ns"
  printf " - %s SOA: \`%s\`\n" "$soa_chk" "$soa"
  printf " - %s WHOIS (registrar/org): \`%s\`\n" "$whois_chk" "$whois_info"
  printf " - %s Ping: \`%s\`\n" "$ping_chk" "$pingres"
  printf " - %s HTTP: \`%s\` HTTPS: %s \`%s\`\n" "$http_chk" "$httpres" "$https_chk" "$httpsres"
        echo
      done
  } > "$mdfile"
  echo "Wrote markdown checklist to $mdfile"
fi

if [[ -n "$OUTPUT_JSON" ]]; then
  jsonfile="$OUTPUT_JSON"
  # Build a JSON array from the summary rows
  {
    echo '[ '
    first=true
    for row in "${summary[@]}"; do
      IFS=$'\t' read -r dom soa ns a aaaa cname whois_info pingres httpres httpsres <<< "$row"
      # Escape JSON strings (very small safe encoder)
      esc() { printf '%s' "$1" | python -c "import json,sys; print(json.dumps(sys.stdin.read()))" | sed 's/^\"//;s/\"$//' ; }
      if [[ "$first" == true ]]; then
        first=false
      else
        echo ','
      fi
      printf '  {"domain":"%s","soa":"%s","ns":"%s","a":"%s","aaaa":"%s","cname":"%s","whois":"%s","ping":"%s","http":"%s","https":"%s"}' \
        "$(esc "$dom")" "$(esc "$soa")" "$(esc "$ns")" "$(esc "$a")" "$(esc "$aaaa")" "$(esc "$cname")" "$(esc "$whois_info")" "$(esc "$pingres")" "$(esc "$httpres")" "$(esc "$httpsres")"
    done
    echo
    echo ' ]'
  } > "$jsonfile"
  echo "Wrote JSON summary to $jsonfile"
fi

exit 0
