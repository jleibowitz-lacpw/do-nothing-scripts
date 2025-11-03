#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
min_script="$script_dir/domain_lookup_min.sh"
lib_script="$script_dir/domain_lookup_lib.sh"

if [ ! -x "$min_script" ]; then
	echo "Missing or non-executable: $min_script" >&2
	exit 2
fi

# Source helpers for open_url + has_cmd
if [ -r "$lib_script" ]; then
	# shellcheck source=/dev/null
	source "$lib_script"
fi

usage() {
	cat <<USAGE
Interactive domain diagnostics (with gum if installed).

Usage:
	$0                 # Launch interactive flow
	$0 --export-md <domain> <file>
	$0 --export-json <domain> <file>
	$0 --export-both <domain> <mdfile> <jsonfile>
	$0 --whois <domain>
USAGE
}

case "${1:-}" in
	--export-md)
		shift || true; domain="${1:-}"; shift || true; out="${1:-}"
		exec "$min_script" --host "$domain" --output-md "$out"
		;;
	--export-json)
		shift || true; domain="${1:-}"; shift || true; out="${1:-}"
		exec "$min_script" --host "$domain" --output-json "$out"
		;;
	--export-both)
		shift || true; domain="${1:-}"; shift || true; outmd="${1:-}"; shift || true; outjson="${1:-}"
		exec "$min_script" --host "$domain" --output-md "$outmd" --output-json "$outjson"
		;;
	--whois)
		shift || true; domain="${1:-}"; exec "$min_script" --host "$domain" --whois
		;;
	--help|-h|-?)
		usage; exit 0
		;;
	"")
		;; # fall through to interactive flow
	*)
		# Delegate unknown flags to minimal script for consistency
		exec "$min_script" "$@"
		;;
esac

# -------- Interactive Flow ---------

prompt_domain() {
	if has_cmd gum; then
		gum input --placeholder "example.com" --prompt "Domain: "
	else
		printf 'Domain (e.g. example.com): '
		read -r d
		echo "$d"
	fi
}

prompt_actions() {
	local opts=("Run full diagnostics" "WHOIS only" "Export markdown" "Export JSON" "Export both" "Open external tools" "Quit")
	if has_cmd gum; then
		gum choose "${opts[@]}"
	else
		printf '\nSelect action:\n'
		local i=1
		for o in "${opts[@]}"; do printf '  %d) %s\n' "$i" "$o"; i=$((i+1)); done
		printf 'Choice: '
		read -r c
		case "$c" in
			1) echo "Run full diagnostics";;
			2) echo "WHOIS only";;
			3) echo "Export markdown";;
			4) echo "Export JSON";;
			5) echo "Export both";;
			6) echo "Open external tools";;
			*) echo "Quit";;
		esac
	fi
}

run_loop() {
	while true; do
		local domain
		domain=$(prompt_domain)
		[ -z "$domain" ] && echo "Empty domain; exiting." && break
		local action
		action=$(prompt_actions)
		case "$action" in
			"Run full diagnostics")
				echo "--- $domain ---"
				"$min_script" --host "$domain"
				;;
			"WHOIS only")
				"$min_script" --host "$domain" --whois
				;;
			"Export markdown")
				local f="diag_${domain//[^a-zA-Z0-9._-]/_}.md"
				"$min_script" --host "$domain" --output-md "$f"
				echo "Markdown written: $f"
				;;
			"Export JSON")
				local f="diag_${domain//[^a-zA-Z0-9._-]/_}.json"
				"$min_script" --host "$domain" --output-json "$f"
				echo "JSON written: $f"
				;;
			"Export both")
				local fm="diag_${domain//[^a-zA-Z0-9._-]/_}.md" fj="diag_${domain//[^a-zA-Z0-9._-]/_}.json"
				"$min_script" --host "$domain" --output-md "$fm" --output-json "$fj"
				echo "Artifacts: $fm $fj"
				;;
			"Open external tools")
				echo "Opening browser tabs (best-effort)..."
				open_url "https://whatsmydns.net/#A/$domain"
				open_url "https://digwebinterface.com/?hostnames=$domain&type=ANY&ns=resolver"
				open_url "https://www.ssllabs.com/ssltest/analyze.html?d=$domain"
				open_url "https://ipinfo.io/$domain"
				;;
			*)
				echo "Goodbye."; break
				;;
		esac
		if has_cmd gum; then gum confirm "Run another?" || break; else printf 'Run another? [y/N]: '; read -r yn; [[ "$yn" =~ ^[Yy]$ ]] || break; fi
	done
}

run_loop

exit 0
