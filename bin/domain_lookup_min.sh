#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lib_dir="$(cd "$script_dir/.." && pwd)/bin"
# Source the library from bin/ for the copied layout
source "$lib_dir/domain_lookup_lib.sh"

# The rest of the script behavior is identical to the original domain_lookup_min.sh
# For brevity, delegate back to the top-level domain_lookup_min.sh if present
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/domain_lookup_min.sh" "$@"
