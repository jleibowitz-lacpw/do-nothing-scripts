#!/usr/bin/env bash
# example.sh - A very simple "do-nothing" script demonstrating
# an echo/read loop for a 5-step manual process. No Gum dependency.
# The idea: wrap an existing manual workflow with a lightweight script
# so it can later evolve toward real automation.

set -euo pipefail

# Data collected during the run
PROJECT_NAME=""
ENVIRONMENT=""
DEPENDENCIES_OK=""
CONFIG_READY=""
NOTES=""

pause() {
  echo
  read -r -p "Press Enter to continue..." _
  echo
}

header() {
  echo "============================================================"
  echo "Step $1 of 5: $2"
  echo "============================================================"
}

clear
echo "Simple Do-Nothing Script Demo (example.sh)"
echo "This will walk through 5 illustrative steps of a pretend onboarding process."
pause

# Step 1: Capture a project name
header 1 "Capture Project Name"
read -r -p "Enter the project name (e.g. inventory-service): " PROJECT_NAME
if [ -z "${PROJECT_NAME// }" ]; then
  PROJECT_NAME="(none entered)"
fi
echo "Recorded project name: $PROJECT_NAME"
pause

# Step 2: Select environment (very simple prompt)
header 2 "Select Environment"
echo "Choose an environment:"
echo "  1) Development"
echo "  2) Staging"
echo "  3) Production"
read -r -p "Enter number (1-3): " choice
case "$choice" in
  1) ENVIRONMENT="development" ;;
  2) ENVIRONMENT="staging" ;;
  3) ENVIRONMENT="production" ;;
  *) ENVIRONMENT="unknown" ;;
 esac
echo "Recorded environment: $ENVIRONMENT"
pause

# Step 3: Confirm dependencies (simulated checklist)
header 3 "Confirm Dependencies"
echo "Have you installed required tools (git, curl, jq)?"
read -r -p "Type 'yes' or 'no': " reply
if [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]; then
  DEPENDENCIES_OK="yes"
else
  DEPENDENCIES_OK="no"
fi
echo "Dependencies confirmed: $DEPENDENCIES_OK"
pause

# Step 4: Mark configuration readiness
header 4 "Configuration File Prepared"
echo "Pretend there's a config file to prepare (e.g., config/app.conf)."
read -r -p "Is the config file ready? (yes/no): " cfg
if [[ "$cfg" =~ ^[Yy]([Ee][Ss])?$ ]]; then
  CONFIG_READY="yes"
else
  CONFIG_READY="no"
fi
echo "Config ready: $CONFIG_READY"
pause

# Step 5: Capture optional notes
header 5 "Optional Notes"
read -r -p "Any notes or blockers to record? (leave blank if none): " NOTES
if [ -z "${NOTES// }" ]; then
  NOTES="(none)"
fi

# Summary
clear
echo "=================== SUMMARY ==================="
echo "Project Name : $PROJECT_NAME"
echo "Environment   : $ENVIRONMENT"
echo "Dependencies  : $DEPENDENCIES_OK"
echo "Config Ready  : $CONFIG_READY"
echo "Notes         : $NOTES"
echo "================================================"

echo "This script didn't automate anything; it just captured and structured the manual steps."
echo "Next iteration ideas: validate inputs, write results to a file, invoke APIs, etc."
