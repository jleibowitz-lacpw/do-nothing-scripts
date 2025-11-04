#!/usr/bin/env bash
set -euo pipefail

## Pre-flight: verify 'gum' is present and plausibly authentic.
## we rely on version pattern + a couple of benign capability probes.
## Set GUM_STRICT=1 to enforce an extra (best-effort) help substring check.
if ! command -v gum >/dev/null 2>&1; then
  echo "Error: 'gum' CLI not found. Install: https://github.com/charmbracelet/gum"
  exit 1
fi

gum_version_output=$(gum --version 2>&1 || true)
if [[ ! $gum_version_output =~ ^gum\ version\ v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
  echo "Error: Unexpected 'gum' version string: '$gum_version_output'"
  echo "Expected format: 'gum version vX.Y.Z'"
  exit 1
fi

# Capability probe: run a trivial style command (should exit 0) and a choose help grep.
if ! gum style "" >/dev/null 2>&1; then
  echo "Error: 'gum style' invocation failed; binary may be incompatible."
  exit 1
fi

choose_help=$(gum choose --help 2>&1 || true)
if ! printf '%s' "$choose_help" | grep -qi 'Choose an option'; then
  echo "Warning: 'gum choose --help' did not contain expected phrase. Continuing, but review binary source if concerned." >&2
fi

if [ "${GUM_STRICT:-0}" = "1" ]; then
  help_full=$(gum --help 2>&1 || true)
  if ! printf '%s' "$help_full" | grep -qi 'A tool for glamorous shell scripts'; then
    echo "Error: Strict mode enabled and help text did not match expected tagline. Aborting."
    exit 1
  fi
fi

# Helper: require non-empty input
prompt_non_empty() {
  local placeholder="$1"
  local value
  while true; do
    value=$(gum input --placeholder "$placeholder")
    if [ -n "${value// }" ]; then
      printf '%s\n' "$value"
      return 0
    fi
    gum style --foreground 196 "Input cannot be empty. Please try again."
  done
}

# Sentry Project Setup Script with Gum

gum style --foreground 212 --border double --align center 'Sentry Project Setup Wizard'

gum style --foreground 212 --border rounded --align left "Step 1: Open the Sentry portal in your browser:"
echo "URL: https://los-angeles-county-public-works.sentry.io/"
echo "If logged out, log in with Active Directory (SSO). It may keep you logged in for some time."
gum confirm "Press Enter once you've completed this step." && { echo "Great! Let's move to the next step."; }

gum style --foreground 212 --border rounded --align left "Step 2: Navigate to the Projects page:"
echo "URL: https://los-angeles-county-public-works.sentry.io/insights/projects/"
echo "This will take you directly to the Projects section in Sentry."
gum confirm "Press Enter once you've completed this step." && { echo "Great! Let's move to the next step."; }

gum style --foreground 212 --border rounded --align left "Step 3: Navigate to the Create Project page:"
echo "URL: https://los-angeles-county-public-works.sentry.io/insights/projects/new/"
echo "This will take you directly to the Create Project section in Sentry."
gum confirm "Press Enter once you've completed this step." && { echo "Great! Let's move to the next step."; }

gum style --foreground 212 --border rounded --align left "Step 4: Select the project type:"
echo "For MVC, React, or Blazor applications, select ASP.NET Core."
echo "For ASP.NET Forms, select .NET."
project_type=$(gum choose "ASP.NET Core (MVC, React, Blazor)" ".NET (ASP.NET Forms)")
echo "You selected: $project_type"

gum style --foreground 212 --border rounded --align left "Step 5: Set your alert frequency:"
echo "Select 'Alert me on high priority issues' for now."
gum style --foreground 33 "Note: This will be edited later."
alert_frequency=$(gum choose "Alert me on high priority issues" "Alert me on all issues")
echo "You selected: $alert_frequency"

gum style --foreground 212 --border rounded --align left "Step 6: Obtain the application name from CAL:"
echo "Go to CAL to obtain the name of the application."
echo "Copy and paste it into the Project Name field (lowercase with dashes)."
application_name=$(prompt_non_empty "Enter the application name (e.g., example-app-name)")
echo "Application Name: $application_name"

gum style --foreground 212 --border rounded --align left "Step 7: Select the appropriate team:"
echo "Select the team that the application belongs to."
echo "If unsure, ask the developer for clarification."
team=$(gum choose "#data-management" "#infrastructure-systems" "#project-program-management" "#pw-troubleshooting" "#webadmin" "#wshr" "#gis")
echo "You selected: $team"

gum style --foreground 212 --border rounded --align left "Step 8: Create the project and input the Instructions URL:"
echo "Click 'Create Project'. You should see the 'Configure ASP.NET Core SDK' page."
echo "Paste the instructions page URL."
instructions_url=$(prompt_non_empty "Paste the Instructions URL here")
echo "Instructions URL: $instructions_url"

gum style --foreground 212 --border rounded --align left "Step 9: Navigate back to the Projects page:"
echo "URL: https://los-angeles-county-public-works.sentry.io/insights/projects/"
gum confirm "Press Enter once you've completed this step." && { echo "Great! Let's move to the next step."; }

gum style --foreground 212 --border rounded --align left "Step 10: Locate the project you just created and click on the Gear icon:"
# Derive the Sentry project name from the application name (normalize: lower, spaces -> dashes,
# remove unsafe chars, collapse multiple dashes, trim dashes). Allow override if desired.
project_name_candidate=$(printf '%s' "$application_name" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9 _-]+//g' \
  | sed -E 's/[ _]+/-/g' \
  | sed -E 's/-+/ -/g' )
project_name_candidate=$(printf '%s' "$project_name_candidate" | sed -E 's/[[:space:]]+/-/g' | sed -E 's/-+/ -/g' )
project_name_candidate=$(printf '%s' "$project_name_candidate" | sed -E 's/ -/-/g' | sed -E 's/^-+//; s/-+$//')

gum style --foreground 212 "Suggested project name: $project_name_candidate"
if gum confirm "Use this project name?"; then
  project_name="$project_name_candidate"
else
  project_name=$(prompt_non_empty "Enter the name of the project you just created")
fi
echo "Locate '$project_name' and click the Gear icon."

gum style --foreground 212 --border rounded --align left "Step 11: Navigate to Alert Settings:"
echo "Under General Settings, select 'Alert Settings'."

gum style --foreground 212 --border rounded --align left "Step 12: View Alert Rules:"
echo "Click 'View Alert Rules'."

gum style --foreground 212 --border rounded --align left "Step 13: Edit the existing rule:"
echo "Use the 3 dots menu, then click 'Edit'."

gum style --foreground 212 --border rounded --align left "Step 14: Modify the 'WHEN' section of the alert rule:"
echo "1. Delete the original 2 conditions."
echo "2. Add:"
echo "   - A new issue is created"
echo "   - Number of events in an issue is more than 0 in 5 minutes"

gum style --foreground 212 --border rounded --align left "Step 15: Change the 'Name' and 'Owner' section:"
echo "Example: Name 'Send notification', Owner $team"

gum style --foreground 212 --border rounded --align left "Step 16: Save the rule:"
echo "Click 'Save Rule'."

gum style --foreground 212 --border rounded --align left "Step 17: Navigate to 'Client Keys (DSN)':"
echo "Under 'SDK Setup', click 'Client Keys (DSN)'."

gum style --foreground 212 --border rounded --align left "Step 18: Configure rate limits:"
echo "Click 'Configure' (upper right)."

gum style --foreground 212 --border rounded --align left "Step 19: Set rate limits:"
echo "Set '1000 events in 1 day'. Adjust later if needed."

gum style --foreground 212 --border rounded --align left "Step 20: Copy the DSN key:"
dsn_key=$(prompt_non_empty "Paste the DSN key here")
echo "DSN key captured."

gum style --foreground 212 --border rounded --align left "Step 21: Generate email content for the developer:"
developer_name=$(prompt_non_empty "Enter the developer's name")

email_content=$(cat <<EOF
Hi $developer_name,

The Project "$project_name" was created and below is the DSN key:

$dsn_key

Sentry instructions page:
$instructions_url

Additional instructions:
https://github.com/la-county-dpw/PW-Library#13-pwsentry
https://docs.sentry.io/platforms
https://docs.sentry.io/platforms/dotnet/guides/aspnet/#install
https://docs.sentry.io/platforms/dotnet/guides/aspnetcore/

Wiki page:
https://lacounty.sharepoint.com/teams/DPW/cio/itdsa/devcorner/Developers%20Guide/Sentry%20Error%20Handler.aspx
EOF
)

gum style --foreground 212 --border rounded --align left "$email_content"

gum style --foreground 212 --border double --align center "Setup Complete! Follow the instructions below:"
echo "Sentry instructions page:"
echo "https://los-angeles-county-public-works.sentry.io/projects/public-works-corrective-action-tracking-system/getting-started/?product=performance-monitoring"
echo "Additional resources:"
echo "- https://github.com/la-county-dpw/PW-Library"
echo "- https://docs.sentry.io/platforms"
echo "- https://docs.sentry.io/platforms/dotnet/guides/aspnet/"
echo "- https://docs.sentry.io/platforms/dotnet/guides/aspnetcore/"
echo "- Wiki Page: https://lacounty.sharepoint.com/teams/DPW/cio/itdsa/devcorner/Developers%20Guide/Sentry%20Error Handler.aspx"

# How to run:
# chmod +x sentry.sh && ./sentry.sh