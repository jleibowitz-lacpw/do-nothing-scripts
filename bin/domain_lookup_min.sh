#!/usr/bin/env bash
set -euo pipefail

# Corrected shim: Point to the actual implementation.
exec "$(dirname "${BASH_SOURCE[0]}")/../lib/domain_lookup_min.sh" "$@"
