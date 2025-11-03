#!/usr/bin/env bash
set -euo pipefail

# Shim: delegate to bin/domain_lookup_interactive.sh for layout tidiness
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")/bin" && pwd)/domain_lookup_interactive.sh" "$@"
