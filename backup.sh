#!/bin/bash

# Automatic backup script with internal scheduling

# Set variables
REPO_DIR=${1:-"$HOME/main/server"} # Accept repository path as an argument or use default
COMMIT_MESSAGE="Automated backup" # Default commit message
BRANCH="backup" # Use a dedicated backup branch
SCHEDULE_INTERVAL=86400 # Interval in seconds (default: 1 day)

# Check if GITHUB_TOKEN exists in the environment
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN is not set in the environment."
  exit 1
fi

# Change to the repository directory
cd "$REPO_DIR" || { echo "Repository directory not found!"; exit 1; }

# Automaically backup the repository
while true; do
  # Check for changes
  git add .
  if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
  else
    # Commit changes
    git commit -m "$COMMIT_MESSAGE"

    # Push changes
    GIT_HTTPS_URL=$(git config --get remote.origin.url)
    AUTH_URL="https://${GITHUB_TOKEN}@${GIT_HTTPS_URL#https://}"
    git push "$AUTH_URL" "$BRANCH"

    # Log success
    echo "Backup pushed to GitHub successfully."
  fi

  # Wait for the next scheduled interval
  echo "Waiting $SCHEDULE_INTERVAL seconds for the next backup..."
  sleep "$SCHEDULE_INTERVAL"
done