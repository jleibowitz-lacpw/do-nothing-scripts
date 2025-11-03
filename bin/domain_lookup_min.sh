#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source helpers from bin/
if [ -r "$script_dir/domain_lookup_lib.sh" ]; then
	# shellcheck source=/dev/null
	source "$script_dir/domain_lookup_lib.sh"
else
	echo "Missing library: $script_dir/domain_lookup_lib.sh" >&2
	exit 2
fi

usage() {
	cat <<USAGE
Usage: $0 --host <domain> [--whois] [--output-md <file>] [--output-json <file>] [--no-http] [--no-ping]

Small non-interactive domain diagnostics. Produces A/AAAA/CNAME/NS/SOA + MX/TXT/CAA, ping + HTTP(S) reachability, and optional WHOIS summary.
USAGE
}

if [ "$#" -eq 0 ]; then
	usage
	exit 2
fi

host=""
whois_only=false
out_md=""
out_json=""
skip_http=false
skip_ping=false

while [ "$#" -gt 0 ]; do
	case "$1" in
		--host|-h)
			shift; host="${1:-}"; shift || true
			;;
		--whois)
			whois_only=true; shift
			;;
		--output-md|--out-md)
			shift; out_md="${1:-}"; shift || true
			;;
		--output-json|--out-json)
			shift; out_json="${1:-}"; shift || true
			;;
		--no-http)
			skip_http=true; shift
			;;
		--no-ping)
			skip_ping=true; shift
			;;
		--help|-help|-?)
			usage; exit 0
			;;
		*)
			echo "Unknown arg: $1" >&2; usage; exit 2
			;;
	esac
done

if [ -z "$host" ]; then
	echo "Host required" >&2; usage; exit 2
fi

apex=$(get_apex "$host")

# Core DNS (soa|ns|a|aaaa|cname)
dns_raw=$(get_dns_records "$host" "$apex")
IFS='|' read -r soa ns a aaaa cname <<<"$dns_raw"

# Additional DNS types
mx=$(get_mx_records "$host" || true)
txt=$(get_txt_records "$host" || true)
caa=$(get_caa_records "$host" || true)

whois_summary=$(get_whois_info "$apex" || true)
whois_full=$(get_whois_summary "$apex" || true) # registrar|expiry|ns|status
IFS='|' read -r registrar expiry reg_ns reg_status <<<"$whois_full"

if [[ -n "$aaaa" && "$aaaa" == "$a" && "$aaaa" != "-" && "$aaaa" != *:* ]]; then
	# nslookup sometimes echoes IPv4 in AAAA queries on certain stacks; suppress
	aaaa="-"
fi

ping_res="-"
http_res="-|-"
if ! $skip_ping; then
	ping_res=$(ping_check "$host" || true)
fi
if ! $skip_http; then
	http_res=$(http_check "$host" || true)
fi

if [ "$whois_only" = true ]; then
	# Delegate to the small whois helper if present for RDAP links and summary
	if [ -x "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/whois_rdap.sh" ]; then
		bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/whois_rdap.sh" "$host"
		exit 0
	else
		if [ "$whois_summary" = "-" ]; then
			echo "RDAP lookup (use in browser):"
			echo "  https://rdap.org/domain/$host"
			echo "ICANN RDAP search: https://rdap.icann.org/lookup?domain=$host"
		else
			echo "WHOIS: $whois_summary"
		fi
		exit 0
	fi
fi

echo "Domain: $host (apex: $apex)"
echo "A: $a"
echo "AAAA: $aaaa"
echo "CNAME: $cname"
echo "MX: $mx"
echo "TXT: $txt"
echo "CAA: $caa"
echo "NS: $ns"
echo "SOA: $soa"
echo "WHOIS (registrar/org): $whois_summary"
echo "Registrar: $registrar" 
echo "Expiry: $expiry"
echo "WHOIS Status: $reg_status"
echo "Ping: $ping_res"
echo "HTTP/HTTPS: $http_res"

# Exports
if [ -n "$out_md" ]; then
	# Unquoted heredoc for variable expansion; avoid backticks to prevent accidental command substitution in exotic shells
	cat >"$out_md" <<MD
# Domain diagnostics checklist

Generated: $(date --iso-8601=seconds 2>/dev/null || date)

## $host

| Field | Value |
|-------|-------|
| A | $a |
| AAAA | $aaaa |
| CNAME | $cname |
| MX | $mx |
| TXT | $txt |
| CAA | $caa |
| NS | $ns |
| SOA | $soa |
| Registrar | $registrar |
| Expiry | $expiry |
| WHOIS Status | $reg_status |
| Ping | $ping_res |
| HTTP | $(echo "$http_res" | cut -d'|' -f1) |
| HTTPS | $(echo "$http_res" | cut -d'|' -f2) |

### Quick RDAP Links

- https://rdap.org/domain/$apex
- https://rdap.icann.org/lookup?domain=$apex

MD
	echo "Wrote markdown checklist to $out_md"
fi

if [ -n "$out_json" ]; then
	printf '{"version":1,"domain":"%s","apex":"%s","soa":"%s","ns":"%s","a":"%s","aaaa":"%s","cname":"%s","mx":"%s","txt":"%s","caa":"%s","registrar":"%s","expiry":"%s","whois_status":"%s","ping":"%s","http":"%s","https":"%s"}\n' \
		"$host" "$apex" "$soa" "$ns" "$a" "$aaaa" "$cname" "$mx" "$txt" "$caa" "$registrar" "$expiry" "$reg_status" "$ping_res" "$(echo "$http_res" | cut -d'|' -f1)" "$(echo "$http_res" | cut -d'|' -f2)" >"$out_json"
	echo "Wrote JSON to $out_json"
fi

exit 0
