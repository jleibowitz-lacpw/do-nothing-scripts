#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
min_script="$script_dir/domain_lookup_min.sh"
lib_script="$script_dir/domain_lookup_lib.sh"

# Source library if available
if [[ -f "$lib_script" ]]; then
  # shellcheck source=/dev/null
  source "$lib_script"
fi

interactive_external() {
  local domain="$1"
  local urls=(
    "https://whatsmydns.net/#A/$domain"
    "https://digwebinterface.com/?hostnames=$domain&type=ANY&ns=resolver"
    "https://www.ssllabs.com/ssltest/analyze.html?d=$domain"
    "https://ipinfo.io/$domain"
  )

  for u in "${urls[@]}"; do
    printf '%s\n' "$u"
  done

  if has_cmd gum; then
    if gum confirm "Open these URLs in your browser?" --default=false 2>/dev/null; then
      for u in "${urls[@]}"; do
        open_url "$u"
      done
    fi
  fi
}

# Run SSL/HTTP checks for a domain. Usage: run_ssl_check <domain> <test_both: true|false>
run_ssl_check() {
  local domain="$1"
  local test_both="${2:-true}"
  local apex domain_www
  apex=$(get_apex "$domain")
  domain_www="www.$apex"

  printf 'Testing HTTP/HTTPS for %s (apex: %s)\n' "$domain" "$apex"
  if [[ "$test_both" == true ]]; then
    echo "  http://$domain_www"
    echo "  https://$domain_www"
  fi

  # Helper to test a single URL
  test_url() {
    local url="$1"
    if has_cmd curl; then
  printf '\nTesting: %s\n' "$url"
      if curl -I --connect-timeout 5 --max-time 10 -sS "$url" >/dev/null 2>&1; then
  status=$(curl -I --connect-timeout 5 --max-time 10 -sS "$url" 2>/dev/null | head -n1 || true)
  printf '  Reachable: yes -- %s\n' "$status"
      else
        echo "  Reachable: no"
      fi
    else
      printf '  curl not available to test %s\n' "$url"
    fi
  }

  test_url "http://$apex"
  test_url "https://$apex"
  # If HTTPS reachable, show a minimal cert summary
  if has_cmd curl && curl -I --connect-timeout 5 --max-time 10 -sS "https://$apex" >/dev/null 2>&1; then
    run_ssl_cert_summary "$apex"
  fi
  if [[ "$test_both" == true ]]; then
    test_url "http://$domain_www"
    test_url "https://$domain_www"
    if has_cmd curl && curl -I --connect-timeout 5 --max-time 10 -sS "https://$domain_www" >/dev/null 2>&1; then
      run_ssl_cert_summary "$domain_www"
    fi
  fi

  printf '\nIf HTTPS fails but HTTP works, check certificate configuration and redirection rules.\n'
}

# Minimal ping runner wrapper used by the interactive script's non-interactive flag
run_ping_traceroute() {
  local domain="$1"
  if declare -f ping_check >/dev/null 2>&1; then
    res=$(ping_check "$domain")
    echo "Ping result for $domain: $res"
  else
    echo "Ping tool not available on this system"
  fi
}


# Minimal cert summary using openssl (best-effort). Prints CN, SAN, Not After, Issuer.
run_ssl_cert_summary() {
  local host="$1"
  printf '\nSSL certificate summary for %s (using openssl):\n' "$host"
  if ! has_cmd openssl; then
    echo "  openssl not available; to get certificate details use https://www.ssllabs.com/ssltest/"
    return 0
  fi

  # Use timeout if available to avoid long hangs
  local s_client_cmd="openssl s_client -connect ${host}:443 -servername ${host}"
  if has_cmd timeout; then
    timeout 10 sh -c "${s_client_cmd} </dev/null 2>/dev/null" | openssl x509 -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null || echo "  failed to fetch certificate or parse output"
  else
    sh -c "${s_client_cmd} </dev/null 2>/dev/null" | openssl x509 -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null || echo "  failed to fetch certificate or parse output"
  fi
}

# Minimal HTTP/HTTPS quick-check using curl: status code, final URL, and TLS cipher if present
run_http_check() {
  local domain="$1"
  local test_both="$2"
  local apex domain_www
  apex=$(get_apex "$domain")
  domain_www="www.$apex"

  echo "Note: http vs https and apex vs www can behave differently. We'll summarize each URL."
  test_one() {
    local url="$1"
    if ! has_cmd curl; then
      echo "curl not available; cannot test $url"
      return
    fi
    # Use curl to follow redirects (-L), head request (-I), but capture final URL and SSL cipher
    # We'll run a HEAD-equivalent and also use -w to fetch final url and ssl cipher
    local out
    out=$(curl -sS -o /dev/null -w "%{http_code} %{url_effective} %{ssl_cipher}" --max-time 10 -I -L "$url" 2>/dev/null || true)
    http_code=$(echo "$out" | awk '{print $1}')
    final_url=$(echo "$out" | awk '{print $2}')
    ssl_cipher=$(echo "$out" | awk '{print $3}')
    printf '\nURL: %s\n' "$url"
    printf '  HTTP code: %s\n' "${http_code:--}"
    if [[ -n "$final_url" && "$final_url" != "$url" ]]; then
      printf '  Final (after redirects): %s\n' "$final_url"
    fi
    if [[ -n "$ssl_cipher" && "$ssl_cipher" != "(none)" ]]; then
      printf '  TLS cipher: %s\n' "$ssl_cipher"
    fi
  }

  test_one "http://$apex"
  test_one "https://$apex"
  if [[ "$test_both" == true ]]; then
    test_one "http://$domain_www"
    test_one "https://$domain_www"
  fi
}


# If flags provided, behave like the shim
for arg in "$@"; do
  case "$arg" in
    --whois)
      shift
      domain_to_probe="$1"
      apex=$(get_apex "$domain_to_probe")
      if declare -f get_whois_summary >/dev/null 2>&1; then
        printf "%s\n" "$(get_whois_summary "$apex")"
      elif [[ -x "${script_dir}/whois_rdap.sh" ]]; then
        bash "${script_dir}/whois_rdap.sh" "$apex"
      else
        echo "RDAP/WHOIS: https://rdap.org/domain/$apex"
      fi
      exit 0
      ;;
    --host|-h)
      if [[ -x "$min_script" ]]; then
        exec "$min_script" "$@"
      else
        echo "domain_lookup_min.sh missing or not executable" >&2
        exit 2
      fi
      ;;
    --open-external)
      shift
      domain_to_open="$1"
      printf 'https://whatsmydns.net/#A/%s
' "$domain_to_open"
      printf 'https://digwebinterface.com/?hostnames=%s&type=ANY&ns=resolver
' "$domain_to_open"
      printf 'https://www.ssllabs.com/ssltest/analyze.html?d=%s
' "$domain_to_open"
      printf 'https://ipinfo.io/%s
' "$domain_to_open"
      echo "(URLs printed for demo; to open in browser run with --open-external-launch)"
      exit 0
      ;;
    --open-external-launch)
      shift
      domain_to_open="$1"
      open_url "https://whatsmydns.net/#A/$domain_to_open"
      open_url "https://digwebinterface.com/?hostnames=$domain_to_open&type=ANY&ns=resolver"
      open_url "https://www.ssllabs.com/ssltest/analyze.html?d=$domain_to_open"
      open_url "https://ipinfo.io/$domain_to_open"
      exit 0
      ;;
    --ping-traceroute)
      # non-interactive mode: domain follows
      shift
      domain_to_probe="$1"
      run_ping_traceroute "$domain_to_probe"
      exit 0
      ;;
    --ssl-check)
      shift
      domain_to_check="$1"
      # default to testing both variants
      run_ssl_check "$domain_to_check" true
      exit 0
      ;;
    --http-check)
      shift
      domain_to_check="$1"
      run_http_check "$domain_to_check" true
      exit 0
      ;;
    --dns-explore)
      shift
      domain_to_probe="$1"
      apex=$(get_apex "$domain_to_probe")
      records=$(get_dns_records "$domain_to_probe" "$apex")
      IFS='|' read -r soa ns a aaaa cname <<<"$records"
      echo "--- DNS Explorer: $domain_to_probe (apex: $apex) ---"
      echo "A: $a"
      echo "AAAA: $aaaa"
      txt=$(get_txt_records "$domain_to_probe")
      mx=$(get_mx_records "$domain_to_probe")
      caa=$(get_caa_records "$domain_to_probe")
      echo "TXT: $txt"
      echo "MX: $mx"
      echo "CAA: $caa"
      echo "CNAME: $cname"
      echo "NS: $ns"
      echo "SOA: $soa"
      whois_info=$(get_whois_info "$apex")
      echo "WHOIS Registrar: $whois_info"
      echo "Note: CNAME records are not valid at a zone apex (apex: $apex)."
      echo "RDAP/WHOIS: https://rdap.org/domain/$apex"
      exit 0
      ;;
    --export-md)
      # non-interactive export: args: --export-md <domain> <outfile>
      shift
      domain_to_export="$1"
      shift
      outpath="$1"
      if [[ ! -x "$min_script" ]]; then
        echo "Missing $min_script" >&2
        exit 2
      fi
      "$min_script" --host "$domain_to_export" --output-md "$outpath"
      echo "Wrote markdown: $outpath"
      exit 0
      ;;
    --export-json)
      # non-interactive export JSON: args: --export-json <domain> <outfile>
      shift
      domain_to_export="$1"
      shift
      outjson="$1"
      if [[ ! -x "$min_script" ]]; then
        echo "Missing $min_script" >&2
        exit 2
      fi
      "$min_script" --host "$domain_to_export" --output-json "$outjson"
      echo "Wrote JSON: $outjson"
      exit 0
      ;;
    --export-both)
      # non-interactive export both: args: --export-both <domain> <md_out> <json_out>
      shift
      domain_to_export="$1"
      shift
      outpath="$1"
      shift
      outjson="$1"
      if [[ ! -x "$min_script" ]]; then
        echo "Missing $min_script" >&2
        exit 2
      fi
      "$min_script" --host "$domain_to_export" --output-md "$outpath" --output-json "$outjson"
      echo "Wrote: $outpath and $outjson"
      exit 0
      ;;
  esac
done

# Interactive menu
if has_cmd gum; then
  choice=$(gum choose "Run minimal diagnostics" "Open external diagnostics" "DNS explorer" "Export & share" "Ping & traceroute" "Exit" 2>/dev/null || true)
  case "$choice" in
    "WHOIS / RDAP")
  domain=$(gum input --placeholder "Domain to inspect (e.g. example.com)" 2>/dev/null || read -r domain; echo "${domain:-example.com}")
      apex=$(get_apex "$domain")
      if declare -f get_whois_summary >/dev/null 2>&1; then
        printf "%s\n" "$(get_whois_summary "$apex")"
      elif [[ -x "${script_dir}/whois_rdap.sh" ]]; then
        bash "${script_dir}/whois_rdap.sh" "$apex"
      else
        echo "RDAP/WHOIS: https://rdap.org/domain/$apex"
      fi
      exit 0
      ;;
    "Run minimal diagnostics")
  domain=$(gum input --placeholder "Domain (e.g. example.com)" 2>/dev/null || read -r domain; echo "${domain:-example.com}")
      exec "$min_script" --host "$domain"
      ;;
    "Open external diagnostics")
  domain=$(gum input --placeholder "Domain to open (e.g. example.com)" 2>/dev/null || read -r domain; echo "${domain:-example.com}")
      interactive_external "$domain"
      exit 0
      ;;
    "Export & share")
  domain=$(gum input --placeholder "Domain to export (e.g. example.com)" 2>/dev/null || read -r domain; echo "${domain:-example.com}")
      out="./${domain//./_}_diagnostics.md"
      if [[ -x "$min_script" ]]; then
        # Ask which formats to export
        export_choice="markdown"
        if has_cmd gum; then
          export_choice=$(gum choose "Markdown" "JSON" "Both" 2>/dev/null || echo "Markdown")
        fi
        if [[ "$export_choice" == "Markdown" || "$export_choice" == "Both" ]]; then
          "$min_script" --host "$domain" --output-md "$out"
          echo "Wrote $out"
        fi
        if [[ "$export_choice" == "JSON" || "$export_choice" == "Both" ]]; then
          json_out="./${domain//./_}_diagnostics.json"
          "$min_script" --host "$domain" --output-json "$json_out"
          echo "Wrote $json_out"
        fi
        # Try to copy to clipboard using common helpers (robust Windows fallback)
        copy_success=false
          if command -v pbcopy >/dev/null 2>&1; then
            cat "$out" | pbcopy && copy_success=true
          elif command -v wl-copy >/dev/null 2>&1; then
            cat "$out" | wl-copy && copy_success=true
          elif command -v xclip >/dev/null 2>&1; then
            cat "$out" | xclip -selection clipboard && copy_success=true
          elif command -v clip.exe >/dev/null 2>&1; then
            # clip.exe is available on Windows (cmd). Use it if present.
            cat "$out" | clip.exe && copy_success=true
          elif command -v pwsh.exe >/dev/null 2>&1; then
            # PowerShell Core: use Set-Clipboard which accepts piped input
            cat "$out" | pwsh.exe -NoProfile -Command 'Set-Clipboard' && copy_success=true
          elif command -v powershell.exe >/dev/null 2>&1; then
            # Windows PowerShell fallback (older): use Get-Clipboard/Set-Clipboard pipeline
            cat "$out" | powershell.exe -NoProfile -Command 'Set-Clipboard' && copy_success=true
          fi
        if [[ "$copy_success" == true ]]; then
          echo "Markdown copied to clipboard."
        else
          echo "Clipboard helper not available; file saved at $out"
        fi
      else
        echo "Missing $min_script; cannot export"
      fi
      exit 0
      ;;
    "DNS explorer")
  domain=$(gum input --placeholder "Domain to inspect (e.g. example.com)" 2>/dev/null || read -r domain; echo "${domain:-example.com}")
      # Use library helper to gather DNS info
      apex=$(get_apex "$domain")
      records=$(get_dns_records "$domain" "$apex")
      IFS='|' read -r soa ns a aaaa cname <<<"$records"
      echo "--- DNS Explorer: $domain (apex: $apex) ---"
      echo "A: $a"
      echo "AAAA: $aaaa"
      txt=$(get_txt_records "$domain")
      mx=$(get_mx_records "$domain")
      caa=$(get_caa_records "$domain")
      echo "TXT: $txt"
      echo "MX: $mx"
      echo "CAA: $caa"
      echo "CNAME: $cname"
      echo "NS: $ns"
      echo "SOA: $soa"
      whois_info=$(get_whois_info "$apex")
      echo "WHOIS Registrar: $whois_info"
      echo "Note: CNAME records are not valid at a zone apex (apex: $apex)."
      echo "RDAP/WHOIS: https://rdap.org/domain/$apex"
      exit 0
      ;;
    "SSL quick-check")
  domain=$(gum input --placeholder "Domain to test (e.g. example.com)" 2>/dev/null || read -r domain; echo "${domain:-example.com}")
      # Ask whether to test both apex and www
      test_both=true
      if has_cmd gum; then
        if gum confirm "Also test the www variant (example: www.$(get_apex "$domain"))?" --default=true 2>/dev/null; then
          test_both=true
        else
          test_both=false
        fi
      fi
      run_ssl_check "$domain" "$test_both"
      exit 0
      ;;
    "HTTP/HTTPS quick-check")
  domain=$(gum input --placeholder "Domain to test (e.g. example.com)" 2>/dev/null || read -r domain; echo "${domain:-example.com}")
      run_http_check "$domain" true
      exit 0
      ;;
    "Ping & traceroute")
  domain=$(gum input --placeholder "Domain to probe (e.g. example.com)" 2>/dev/null || read -r domain; echo "${domain:-example.com}")
      run_ping_traceroute "$domain"
      exit 0
      ;;
    *)
      echo "Exiting interactive helper. Use $min_script for non-interactive runs.";
      exit 0
      ;;
  esac
else
  cat <<'NO_GUM'
Interactive `domain_lookup_interactive.sh` requires `gum` for the TUI.
Use `domain_lookup_min.sh --host example.com` for non-interactive runs.
NO_GUM
  exit 0
fi
