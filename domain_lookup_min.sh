#!/usr/bin/env bash
#!/usr/bin/env bash
set -euo pipefail

# Shim: delegate to bin/domain_lookup_min.sh to keep repository root tidy.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")/bin" && pwd)/domain_lookup_min.sh" "$@"
