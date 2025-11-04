#!/usr/bin/env bash

set -euo pipefail

# Sentry Project Setup Script with Gum


# Welcome Message
gum style --foreground 212 --border double --align center 'Sentry Project Setup Wizard'

# Step 1: Open Sentry Portal Instructions
gum style --foreground 212 --border rounded --align left "Step 1: Open the Sentry portal in your browser:"
echo "URL: https://los-angeles-county-public-works.sentry.io/"
echo "If logged out, log in with Active Directory (SSO). It may keep you logged in for some time."

gum confirm "Press Enter once you've completed this step." && {
  echo "Great! Let's move to the next step."
}

# Step 2: Navigate to Projects Page
gum style --foreground 212 --border rounded --align left "Step 2: Navigate to the Projects page:"
echo "URL: https://los-angeles-county-public-works.sentry.io/insights/projects/"
echo "This will take you directly to the Projects section in Sentry."

gum confirm "Press Enter once you've completed this step." && {
  echo "Great! Let's move to the next step."
}

# Step 3: Navigate to Create Project Page
gum style --foreground 212 --border rounded --align left "Step 3: Navigate to the Create Project page:"
echo "URL: https://los-angeles-county-public-works.sentry.io/insights/projects/new/"
echo "This will take you directly to the Create Project section in Sentry."

gum confirm "Press Enter once you've completed this step." && {
  echo "Great! Let's move to the next step."
}

# Step 4: Select Project Type
gum style --foreground 212 --border rounded --align left "Step 4: Select the project type:"
echo "For MVC, React, or Blazor applications, select ASP.NET Core."
echo "For ASP.NET Forms, select .NET."
project_type=$(gum choose "ASP.NET Core (MVC, React, Blazor)" ".NET (ASP.NET Forms)")

echo "You selected: $project_type"

# Step 5: Set Alert Frequency
gum style --foreground 212 --border rounded --align left "Step 5: Set your alert frequency:"
echo "Select 'Alert me on high priority issues' for now."
gum style --foreground 33 "Note: This will be edited later."
alert_frequency=$(gum choose "Alert me on high priority issues" "Alert me on all issues")

echo "You selected: $alert_frequency"

# Step 6: Obtain Application Name from CAL
gum style --foreground 212 --border rounded --align left "Step 6: Obtain the application name from CAL:"
echo "Go to CAL to obtain the name of the application."
echo "Copy and paste it into the Project Name field."
echo "The name should automatically suggest all lowercase with dashes (e.g., example-app-name)."
application_name=$(gum input --placeholder "Enter the application name (e.g., example-app-name)")

echo "Application Name: $application_name"

# Step 7: Select Team
gum style --foreground 212 --border rounded --align left "Step 7: Select the appropriate team:"
echo "Select the team that the application belongs to."
echo "If unsure, ask the developer for clarification."
team=$(gum choose "#data-management" "#infrastructure-systems" "#project-program-management" "#pw-troubleshooting" "#webadmin" "#wshr" "#gis")

echo "You selected: $team"

# Step 8: Create Project and Input Instructions URL
gum style --foreground 212 --border rounded --align left "Step 8: Create the project and input the Instructions URL:"
echo "Click 'Create Project' in the Sentry interface."
echo "If the project is created successfully, you should see the 'Configure ASP.NET Core SDK' page."
echo "This page contains instructions on what to do next and where to place the generated DSN key."
echo "Since we use a custom template, developers will also receive custom instructions."
instructions_url=$(gum input --placeholder "Paste the Instructions URL here")

echo "Instructions URL: $instructions_url"

# Step 9: Navigate Back to Projects Page
gum style --foreground 212 --border rounded --align left "Step 9: Navigate back to the Projects page:"
echo "URL: https://los-angeles-county-public-works.sentry.io/insights/projects/"
echo "This will take you directly to the Projects section in Sentry."

gum confirm "Press Enter once you've completed this step." && {
  echo "Great! Let's move to the next step."
}

# Step 10: Locate the Project and click the Gear icon
project_name=$(gum input --placeholder "Enter the name of the project you just created")
echo "Locate the project named '$project_name' and click on the Gear icon to the right of the project name."

# Step 11: Navigate to Alert Settings
echo "Under General Settings, select 'Alert Settings'."

# Step 12: View Alert Rules
echo "Click 'View Alert Rules'."

# Step 13: Edit the existing rule
echo "Edit the existing rule by selecting the 3 dots and clicking the 'Edit' link."

# Step 14: Modify the WHEN section
echo "Change the 'WHEN' section as follows:"
echo "1. Delete the original 2 conditions."
echo "2. Add the following 2 new conditions:"
echo "   - 'WHEN an event is captured by Sentry and any of the following happens'"
echo "   - 'A new issue is created'"
echo "   - 'Number of events in an issue is more than 0 in 5 minutes'"

# Step 15: Change name and owner section
echo "Change the 'Name' and 'Owner' section to appropriately reflect the Alert name and Team."
echo "For example, set the name to 'Send notification' and the owner to the team you chose previously (e.g., '#gis')."

# Step 16: Save the rule
echo "Click 'Save Rule' to save your changes."

# Step 17: Navigate to Client Keys (DSN)
echo "Click on 'Client Keys (DSN)' under the 'SDK Setup' section."

# Step 18: Configure rate limits
echo "Click 'Configure' in the upper right corner of the 'Client Keys (DSN)' section."

# Step 19: Set rate limits
echo "Under 'Rate Limit', enter/select '1000 events in 1 day'."
echo "Note: This rate can be changed if requested by the developer or if requirements change."

# Step 20: Copy DSN key
dsn_key=$(gum input --placeholder "Paste the DSN key here")
echo "DSN key saved for later use."

# Step 21: Generate email for developer
project_name=$(gum input --placeholder "Enter the project name")
developer_name=$(gum input --placeholder "Enter the developer's name")
instructions_url=$(gum input --placeholder "Enter the Sentry instructions URL")

email_content="""
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

"""

gum style --foreground 212 --border rounded --align left "$email_content"

# Step 22: Final Instructions
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
