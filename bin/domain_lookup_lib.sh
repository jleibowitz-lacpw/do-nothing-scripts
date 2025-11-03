#!/usr/bin/env bash
set -euo pipefail

# Shared helpers for domain lookup scripts (moved to lib folder)

has_cmd() { command -v "$1" >/dev/null 2>&1; }

get_apex() {
  local d="$1"
  if [[ "$d" == www.* ]]; then
    echo "${d#www.}"
  else
    echo "$d"
  fi
}

get_dns_records() {
  local domain="$1" apex="$2"
  local soa="-" ns="-" a="-" aaaa="-" cname="-"
  if has_cmd dig; then
    soa=$(dig "$apex" SOA +short 2>/dev/null | tr '\n' ',' | sed 's/,$//' || true)
    ns=$(dig "$apex" NS +short 2>/dev/null | tr '\n' ',' | sed 's/,$//' || true)
    a=$(dig "$domain" A +short 2>/dev/null | tr '\n' ',' | sed 's/,$//' || true)
    aaaa=$(dig "$domain" AAAA +short 2>/dev/null | tr '\n' ',' | sed 's/,$//' || true)
    cname=$(dig "$domain" CNAME +short 2>/dev/null | tr '\n' ',' | sed 's/,$//' || true)
  elif has_cmd nslookup; then
    soa=$(nslookup -type=SOA "$apex" 2>/dev/null | awk '/primary name server/ {print $NF}' | tr '\n' ',' | sed 's/,$//' || true)
    ns=$(nslookup -type=NS "$apex" 2>/dev/null | awk '/nameserver/ {print $NF}' | tr '\n' ',' | sed 's/,$//' || true)
    a=$(nslookup "$domain" 2>/dev/null | awk '/Address:/ {print $NF}' | grep -v '#53' | tr '\n' ',' | sed 's/,$//' || true)
    aaaa=$(nslookup -type=AAAA "$domain" 2>/dev/null | awk '/Address:/ {print $NF}' | tr '\n' ',' | sed 's/,$//' || true)
    cname=$(nslookup "$domain" 2>/dev/null | awk '/canonical name/ {print $NF}' | tr '\n' ',' | sed 's/,$//' || true)
  fi
  [[ -z "$soa" ]] && soa="-"
  [[ -z "$ns" ]] && ns="-"
  [[ -z "$a" ]] && a="-"
  [[ -z "$aaaa" ]] && aaaa="-"
  [[ -z "$cname" ]] && cname="-"
  printf "%s|%s|%s|%s|%s" "$soa" "$ns" "$a" "$aaaa" "$cname"
}

get_mx_records() {
  local domain="$1"
  local mx="-"
  if has_cmd dig; then
    mx=$(dig "$domain" MX +short 2>/dev/null | awk '{print $2"("$1")"}' | tr '\n' ',' | sed 's/,$//' || true)
  elif has_cmd nslookup; then
    mx=$(nslookup -type=MX "$domain" 2>/dev/null | awk '/mail exchanger/ {print $NF"("$(NF-1)")"}' | tr '\n' ',' | sed 's/,$//' || true)
  fi
  [[ -z "$mx" ]] && mx="-"
  echo "$mx"
}

get_txt_records() {
  local domain="$1"
  local txt="-"
  if has_cmd dig; then
    txt=$(dig "$domain" TXT +short 2>/dev/null | sed 's/^"//;s/"$//' | tr '\n' ',' | sed 's/,$//' || true)
  elif has_cmd nslookup; then
    txt=$(nslookup -type=TXT "$domain" 2>/dev/null | awk -F'"' '/text =/ {print $2}' | tr '\n' ',' | sed 's/,$//' || true)
  fi
  [[ -z "$txt" ]] && txt="-"
  echo "$txt"
}

get_caa_records() {
  local domain="$1"
  local caa="-"
  if has_cmd dig; then
    caa=$(dig "$domain" CAA +short 2>/dev/null | tr '\n' ',' | sed 's/,$//' || true)
  elif has_cmd nslookup; then
    caa=$(nslookup -type=CAA "$domain" 2>/dev/null | awk '/CAA/ {print $0}' | tr '\n' ',' | sed 's/,$//' || true)
  fi
  [[ -z "$caa" ]] && caa="-"
  echo "$caa"
}

ping_check() {
  local domain="$1"
  local res="-"
  if has_cmd ping; then
    if [[ "${OSTYPE-}" == msys* || "${OSTYPE-}" == cygwin* ]] || has_cmd cmd.exe; then
      if ping -n 1 "$domain" >/dev/null 2>&1; then res="OK"; else res="Fail"; fi
    else
      if ping -c 1 "$domain" >/dev/null 2>&1; then res="OK"; else res="Fail"; fi
    fi
  fi
  echo "$res"
}

http_check() {
  local domain="$1"
  local res_http="-" res_https="-"
  if has_cmd curl; then
    if curl -I --connect-timeout 5 --max-time 10 "http://$domain" 2>/dev/null | grep -qE "HTTP/|200|301|302"; then res_http="OK"; else res_http="Fail"; fi
    if curl -I --connect-timeout 5 --max-time 10 "https://$domain" 2>/dev/null | grep -qE "HTTP/|200|301|302"; then res_https="OK"; else res_https="Fail"; fi
  fi
  printf "%s|%s" "$res_http" "$res_https"
}

get_whois_info() {
  local name="$1"
  if has_cmd whois; then
    whois "$name" 2>/dev/null | awk -F: '/Registrar:|registrar:|OrgName:|org-name:|Org:|organisation:/ {print $2; exit}' | sed 's/^ *//;s/ *$//' || true
  else
    echo "-"
  fi
}

get_whois_summary() {
  local name="$1"
  local registrar="-" expiry="-" ns="-" status="-"
  if has_cmd whois; then
    local out
    out=$(whois "$name" 2>/dev/null || true)
    registrar=$(awk -F":" 'tolower($1) ~ /registrar/ {gsub(/^ +| +$/,"",$2); print $2; exit}' <<<"$out" || true)
    expiry=$(awk -F":" 'tolower($1) ~ /expiry|expir|expiration/ {gsub(/^ +| +$/,"",$2); print $2; exit}' <<<"$out" || true)
    ns=$(awk -F":" 'tolower($1) ~ /name server|nserver|nameserver/ {gsub(/^ +| +$/,"",$2); print $2}' <<<"$out" | tr '\n' ',' | sed 's/,$//' || true)
    status=$(awk -F":" 'tolower($1) ~ /status/ {gsub(/^ +| +$/,"",$2); print $2}' <<<"$out" | tr '\n' ',' | sed 's/,$//' || true)
  fi
  [[ -z "$registrar" ]] && registrar="-"
  [[ -z "$expiry" ]] && expiry="-"
  [[ -z "$ns" ]] && ns="-"
  [[ -z "$status" ]] && status="-"
  printf "%s|%s|%s|%s" "$registrar" "$expiry" "$ns" "$status"
}

open_url() {
  local url="$1"
  if command -v explorer.exe >/dev/null 2>&1; then
    explorer.exe "$url" 2>/dev/null &
  elif command -v pwsh.exe >/dev/null 2>&1; then
    pwsh.exe -NoProfile -Command "Start-Process -FilePath '$url'" >/dev/null 2>&1 &
  elif command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command "Start-Process -FilePath '$url'" >/dev/null 2>&1 &
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url" 2>/dev/null &
  elif command -v open >/dev/null 2>&1; then
    open "$url" 2>/dev/null &
  else
    echo "Open in browser: $url"
  fi
}

return 0
