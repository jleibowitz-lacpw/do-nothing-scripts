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
Usage: $0 --host <domain> [--whois] [--output-md <file>] [--output-json <file>]

Simple non-interactive domain diagnostics (minimal for smoke tests).
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
		--help)
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

dns_raw=$(get_dns_records "$host" "$apex")
IFS='|' read -r soa ns a aaaa cname <<<"$dns_raw"

whois_summary=$(get_whois_info "$apex" || true)
ping_res=$(ping_check "$host" || true)
http_res=$(http_check "$host" || true)

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
echo "NS: $ns"
echo "SOA: $soa"
echo "WHOIS: $whois_summary"
echo "Ping: $ping_res"
echo "HTTP/HTTPS: $http_res"

# Exports
if [ -n "$out_md" ]; then
	# Use quoted heredoc to avoid accidental expansion
		cat >"$out_md" <<'MD'
# Domain diagnostics checklist

Generated: $(date --iso-8601=seconds 2>/dev/null || date)

## $host

 - [x] A record: \\`$a\\`
 - [x] AAAA record: \\`$aaaa\\`
 - [ ] CNAME: \\`$cname\\`
 - [x] NS: \\`$ns\\`
 - [x] SOA: \\`$soa\\`
 - [ ] WHOIS (registrar/org): \\`$whois_summary\\`
 - [x] Ping: \\`$ping_res\\`
 - [x] HTTP: \\`$(echo "$http_res" | cut -d'|' -f1)\\` HTTPS: [x] \\`$(echo "$http_res" | cut -d'|' -f2)\\`

MD
	echo "Wrote markdown checklist to $out_md"
fi

if [ -n "$out_json" ]; then
	printf '[\n  {"domain":"%s","soa":"%s","ns":"%s","a":"%s","aaaa":"%s","cname":"%s","whois":"%s","ping":"%s","http":"%s","https":"%s"}\n]\n' \
		"$host" "$soa" "$ns" "$a" "$aaaa" "$cname" "$whois_summary" "$ping_res" "$(echo "$http_res" | cut -d'|' -f1)" "$(echo "$http_res" | cut -d'|' -f2)" >"$out_json"
	echo "Wrote JSON to $out_json"
fi

exit 0
