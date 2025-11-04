#!/usr/bin/env bash
set -euo pipefail

# Smoke test for sentry_onboard.sh (non-interactive fallback)
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPTS_DIR="$ROOT_DIR/lib"

echo "Running sentry_onboard.sh smoke test (noninteractive)..."
bash "$SCRIPTS_DIR/sentry_onboard.sh" --noninteractive <<'EOF'
demo-org
demo-project
javascript
demo-team
EOF

echo "Smoke test: PASS"
