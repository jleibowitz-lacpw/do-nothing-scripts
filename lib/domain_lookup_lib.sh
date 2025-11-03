#!/usr/bin/env bash
set -euo pipefail

# Canonical shared helpers (mirrors bin/domain_lookup_lib.sh)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../bin/domain_lookup_lib.sh"

return 0
