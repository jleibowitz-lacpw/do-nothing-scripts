#!/usr/bin/env bash
set -euo pipefail

# gum_demo.sh
# A quick demonstration of the 'gum' utility for creating glamorous shell scripts.
# This script showcases various gum features in the context of "gradual automation".

# --- Helper Functions ---

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed. Please install it from https://github.com/charmbracelet/gum"
    exit 1
fi

# Function to print a styled header for each section
print_header() {
    gum style --border double --margin "1" --padding "1" --border-foreground 212 "$1"
}

# --- Demo Starts Here ---

# 1. `gum style` - For styled text and headers
print_header "Welcome to the Gum Demo Script!"
gum style 'This script will walk you through the features of `gum`.'
echo

# 2. `gum confirm` - For user confirmation
gum style --bold "First, let's use 'gum confirm' to ask for confirmation."
if gum confirm "Are you ready to start the demo?"; then
    gum style --foreground 212 "Great! Let's go."
else
    gum style --foreground 196 "Aborting demo."
    exit 0
fi
echo

# 3. `gum input` - For single-line user input
print_header "Demo: 'gum input' for user input"
gum style "Let's get some input from the user, like a project name."
PROJECT_NAME=$(gum input --placeholder "Enter a project name...")
if [ -n "$PROJECT_NAME" ]; then
    gum style --foreground 212 "Project name set to: $PROJECT_NAME"
else
    gum style --foreground 196 "No project name entered."
fi
echo

# 4. `gum choose` - For selecting from a list of options
print_header "Demo: 'gum choose' for selecting from a list"
gum style "This is great for selecting an environment or a task type."
ENVIRONMENT=$(gum choose "Development" "Staging" "Production")
gum style --foreground 212 "You chose: $ENVIRONMENT"
echo

# 5. `gum write` - For multi-line user input
print_header "Demo: 'gum write' for long-form text"
gum style "Useful for commit messages or descriptions."
COMMIT_MSG=$(gum write --placeholder "Enter a commit message...")
if [ -n "$COMMIT_MSG" ]; then
    gum style --border rounded --padding 1 "Your commit message:" "$COMMIT_MSG"
else
    gum style --foreground 196 "No commit message entered."
fi
echo

# 6. `gum filter` - To filter a list of items
print_header "Demo: 'gum filter' to find something in a list"
gum style "Imagine you need to select a file to process."
FILE_TO_PROCESS=$(find . -maxdepth 2 -type f | gum filter --placeholder "Filter files...")
if [ -n "$FILE_TO_PROCESS" ]; then
    gum style --foreground 212 "You selected: $FILE_TO_PROCESS"
else
    gum style --foreground 196 "No file selected."
fi
echo

# 7. `gum spin` - To show a spinner for long-running tasks
print_header "Demo: 'gum spin' for showing progress"
gum style "Simulating a long-running task, like a deployment."
gum spin --spinner dot --title "Deploying to $ENVIRONMENT..." -- sleep 5
gum style --foreground 212 "Deployment complete!"
echo

# 8. `gum join` - To layout text side-by-side
print_header "Demo: 'gum join' to display text in columns"
gum style "You can join styled text blocks horizontally."
LEFT_COL=$(gum style --border rounded --padding 1 "Checklist:
[x] Step 1
[x] Step 2
[ ] Step 3")
RIGHT_COL=$(gum style --border rounded --padding 1 "Status:
- In Progress
- Blocked")
gum join "$LEFT_COL" "$RIGHT_COL"
echo

# 9. `gum pager` - To view content in a pager
print_header "Demo: 'gum pager' to view large content"
gum style "Let's view the source code of this script inside a pager."
gum confirm "Press enter to view the script's source." && gum pager < "$0"
echo

# 10. `gum table` - To display data in a table
print_header "Demo: 'gum table' to display structured data"
gum style "Perfect for showing status of services or resources."
gum table <<EOF
Service,Status,Port
"Web Server","Running","8080"
"Database","Running","5432"
"API Gateway","Error","9000"
EOF
echo

# --- End of Demo ---
print_header "Demo Complete!"
gum style "You've seen some of the most useful features of 'gum' for creating interactive scripts."
gum style --bold --foreground 212 "Happy scripting!"

# --- How to run this script ---
# chmod +x gum_demo.sh
# ./gum_demo.sh
