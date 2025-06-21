#!/bin/bash

# Script to set up SCORECARD_READ_TOKEN for GitHub repository
# This creates a minimal-permission PAT just for Scorecard analysis

echo "This script will help you create a read-only PAT for Scorecards analysis"
echo "You will be redirected to GitHub to create a token with minimal permissions"
echo "Once created, copy the token and paste it back here when prompted"
echo ""

# Open the GitHub token creation page with pre-filled minimal permissions
echo "Opening GitHub token creation page with minimal permissions..."
open "https://github.com/settings/tokens/new?description=Scorecard%20Read-Only%20Token&scopes=public_repo"

echo ""
echo "After creating the token on GitHub, copy it and paste it below:"
read -s TOKEN

if [ -z "$TOKEN" ]; then
  echo "No token provided. Exiting."
  exit 1
fi

# Set the token as a repository secret
echo ""
echo "Setting the SCORECARD_READ_TOKEN secret in repository..."
echo "$TOKEN" | gh secret set SCORECARD_READ_TOKEN -R Avares-AI/focalboard

echo ""
echo "Secret SCORECARD_READ_TOKEN has been set successfully!"
echo "The Scorecards workflow should now pass on future runs."
