#!/usr/bin/env bash
# Lightweight shim: delegate non-interactive runs to domain_lookup_min.sh
# For full interactive features, this script used to provide a TUI via gum.
# That implementation is currently being refactored. Use the minimal script for now.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
min_script="$script_dir/domain_lookup_min.sh"
lib_script="$script_dir/domain_lookup_lib.sh"

# Source shared helpers if available (safe, non-fatal)
if [[ -f "$lib_script" ]]; then
	# shellcheck source=/dev/null
	source "$lib_script"
fi

# Interactive helper: confirm via gum (if available) before opening external pages.
interactive_external() {
	local domain="$1"
	local urls=(
		"https://whatsmydns.net/#A/$domain"
		"https://digwebinterface.com/?hostnames=$domain&type=ANY&ns=resolver"
		"https://www.ssllabs.com/ssltest/analyze.html?d=$domain"
		"https://ipinfo.io/$domain"
	)

	if has_cmd gum; then
		# show a simple list and confirm
		printf '%s\n' "External diagnostics for: $domain"
		for u in "${urls[@]}"; do
			printf '  %s\n' "$u"
		done
		if gum confirm --default=false; then
			for u in "${urls[@]}"; do
				open_url "$u"
			done
		else
			echo "Not opening browser. URLs printed above."
		fi
	else
		# fallback: print URLs so user can copy/paste
		for u in "${urls[@]}"; do
			printf '%s\n' "$u"
		done
	fi
}

# If caller supplied --host, delegate to minimal script
while [ "$#" -gt 0 ]; do
	case "$1" in
		--host|-h)
			shift
			domain_to_probe="${1:-}"
			if [[ -x "$min_script" ]]; then
				# Print header expected by legacy shim smoke test (use safe format)
				printf '%s\n' "--- $domain_to_probe ---"
				exec "$min_script" --host "$domain_to_probe"
			else
				echo "domain_lookup_min.sh missing or not executable. See README for usage." >&2
				exit 2
			fi
			;;
		--open-external)
			# Usage: domain_lookup.sh --open-external example.com
			# Demo-friendly: print helpful external diagnostic URLs so user can copy/paste
			shift
			domain_to_open="${1:-}"
			printf 'https://whatsmydns.net/#A/%s\n' "$domain_to_open"
			printf 'https://digwebinterface.com/?hostnames=%s&type=ANY&ns=resolver\n' "$domain_to_open"
			printf 'https://www.ssllabs.com/ssltest/analyze.html?d=%s\n' "$domain_to_open"
			printf 'https://ipinfo.io/%s\n' "$domain_to_open"
			echo "(URLs printed for demo; to open in browser run with --open-external-launch)"
			exit 0
			;;
		--open-external-launch)
			# Usage: domain_lookup.sh --open-external-launch example.com
			# Launch external diagnostics in browser (best-effort)
			shift
			domain_to_open="${1:-}"
			open_url "https://whatsmydns.net/#A/$domain_to_open"
			open_url "https://digwebinterface.com/?hostnames=$domain_to_open&type=ANY&ns=resolver"
			open_url "https://www.ssllabs.com/ssltest/analyze.html?d=$domain_to_open"
			open_url "https://ipinfo.io/$domain_to_open"
			exit 0
			;;
		*)
			shift
			;;
	esac
done

cat <<'EOF'
The interactive `domain_lookup.sh` has been temporarily disabled for stability.
Use `domain_lookup_min.sh --host example.com` for a reliable non-interactive run.
To restore the interactive experience run the refactor task or open an issue.

EOF

exit 0
