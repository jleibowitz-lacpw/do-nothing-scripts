#!/usr/bin/env bash
# Interactive domain lookup script

set -euo pipefail

# Resolve script directory robustly
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
min_script="$script_dir/lib/domain_lookup_min.sh"
interactive_script="$script_dir/lib/domain_lookup_interactive.sh"
lib_script="$script_dir/lib/domain_lookup_lib.sh"

# Source shared helpers if available
if [[ -f "$lib_script" ]]; then
	# shellcheck source=/dev/null
	source "$lib_script"
fi

# Check if Gum is available for interactive mode
if has_cmd gum && [[ -f "$interactive_script" ]]; then
	bash "$interactive_script" "$@"
	exit 0
fi

# Fallback to minimal script for non-interactive mode
if [[ -f "$min_script" ]]; then
	bash "$min_script" "$@"
	exit 0
else
	echo "Error: Required scripts are missing. Please check the installation." >&2
	exit 1
fi
