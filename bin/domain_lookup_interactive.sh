#!/usr/bin/env bash
set -euo pipefail

exec "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/domain_lookup_interactive.sh" "$@"
