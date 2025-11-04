#!/usr/bin/env bash
set -euo pipefail

# Minimal Sentry onboarding TUI demo for 'do-nothing-scripts'
# - If `gum` is available it shows a simple TUI. Otherwise falls back to stdin prompts.
# - This is a demo: it doesn't perform API calls, only collects inputs and prints the suggested steps.

has_cmd() { command -v "$1" >/dev/null 2>&1; }

print_header() {
  echo "=== Sentry Onboarding (demo) ==="
}

run_gum_tui() {
  local org project platform team
  org=$(gum input --placeholder "Organization slug (e.g. my-org)")
  project=$(gum input --placeholder "Project slug (e.g. my-project)")
  platform=$(gum choose --no-limit "javascript" "python" "go" "ruby" "other" | sed -n '1p')
  team=$(gum input --placeholder "Team (optional)")

  gum confirm && true

  cat <<EOF
Collected:
  Organization: $org
  Project:      $project
  Platform:     $platform
  Team:         $team

Suggested next steps (manual demo):
  1) Create project "$project" in Sentry under org "$org".
  2) Follow Sentry docs to add the SDK for "$platform".
  3) Install DSN or environment variable in your project.
  4) Optionally add the project to team "$team".
EOF
}

run_fallback() {
  local org project platform team
  read -rp "Organization slug (e.g. my-org): " org
  read -rp "Project slug (e.g. my-project): " project
  read -rp "Platform (javascript/python/go/ruby/other): " platform
  read -rp "Team (optional): " team

  echo
  echo "Collected:"
  echo "  Organization: $org"
  echo "  Project:      $project"
  echo "  Platform:     $platform"
  echo "  Team:         $team"
  echo
  echo "Suggested next steps (manual demo):"
  echo "  1) Create project \"$project\" in Sentry under org \"$org\"."
  echo "  2) Follow Sentry docs to add the SDK for \"$platform\"."
  echo "  3) Install DSN or environment variable in your project."
  echo "  4) Optionally add the project to team \"$team\"."
}

usage() {
  echo "Usage: $0 [--noninteractive]"
  exit 2
}

main() {
  local noninteractive=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --noninteractive) noninteractive=1; shift;;
      -h|--help) usage;;
      *) echo "Unknown arg: $1"; usage;;
    esac
  done

  print_header

  if [[ $noninteractive -eq 0 ]] && has_cmd gum; then
    run_gum_tui
  else
    run_fallback
  fi
}

main "$@"
