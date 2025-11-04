#!/usr/bin/env bash
set -euo pipefail

# Canonical shared helpers (mirrors bin/domain_lookup_lib.sh)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../bin/domain_lookup_lib.sh"

return 0

# Placeholder for domain_lookup_lib.sh
# Add shared helper functions here

echo "domain_lookup_lib.sh loaded"
