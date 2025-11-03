#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
min_script="$(cd "$script_dir" && pwd)/domain_lookup_min.sh"

if [ ! -x "$min_script" ]; then
	echo "Missing or non-executable: $min_script" >&2
	exit 2
fi

# Non-interactive helper: support a few flags that the interactive script used to accept
case "${1:-}" in
	--export-md)
		# Usage: --export-md <domain> <outfile>
		shift || true
		domain="${1:-}"
		shift || true
		out="${1:-}"
		exec "$min_script" --host "$domain" --output-md "$out"
		;;
	--export-json)
		shift || true
		domain="${1:-}"
		shift || true
		out="${1:-}"
		exec "$min_script" --host "$domain" --output-json "$out"
		;;
	--export-both)
		shift || true
		domain="${1:-}"
		shift || true
		outmd="${1:-}"
		shift || true
		outjson="${1:-}"
		exec "$min_script" --host "$domain" --output-md "$outmd" --output-json "$outjson"
		;;
	--whois)
		shift || true
		domain="${1:-}"
		exec "$min_script" --host "$domain" --whois
		;;
	*)
		# Fallback: delegate to min script for other non-interactive flags
		exec "$min_script" "$@"
		;;
esac
