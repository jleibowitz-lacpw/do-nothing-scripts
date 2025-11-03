#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
min_script="$script_dir/domain_lookup_min.sh"
lib_script="$script_dir/domain_lookup_lib.sh"

# Source library if available
if [[ -f "$lib_script" ]]; then
  # shellcheck source=/dev/null
  source "$lib_script"
fi

interactive_external() {
  local domain="$1"
  local urls=(
    "https://whatsmydns.net/#A/$domain"
    "https://digwebinterface.com/?hostnames=$domain&type=ANY&ns=resolver"
    "https://www.ssllabs.com/ssltest/analyze.html?d=$domain"
    "https://ipinfo.io/$domain"
  )

    echo "  https://$domain_www"
      run_ping_traceroute "$domain_to_probe"
      ;;
      shift
      # default to testing both variants
  #!/usr/bin/env bash
  set -euo pipefail

  # Shim: delegate to bin/domain_lookup_interactive.sh for layout tidiness
  exec "$(cd "$(dirname "${BASH_SOURCE[0]}")/bin" && pwd)/domain_lookup_interactive.sh" "$@"
  fi
