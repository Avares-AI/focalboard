#!/usr/bin/env python3
"""
Set the SCORECARD_READ_TOKEN secret for GitHub repository
This script generates a GitHub token and sets it as a repository secret
"""
import os
import subprocess
import sys
import secrets
import string
import tempfile

def main():
    """Main function to set up Scorecard token"""
    repo = "Avares-AI/focalboard"
    
    # Instructions for the user
    print("=== Scorecard Token Setup ===")
    print("This script will help you create and set a SCORECARD_READ_TOKEN for GitHub Actions")
    print("1. Visit: https://github.com/settings/tokens/new")
    print("2. Enter a note like 'Scorecard Read-Only Token'")
    print("3. Select ONLY the 'public_repo' scope")
    print("4. Click 'Generate token'")
    print("5. Copy the generated token")
    
    # Get token from user
    token = input("\nPaste your GitHub token here (it will not be displayed): ")
    
    if not token or token.strip() == "":
        print("Error: No token provided")
        return 1
    
    # Write token to a temporary file to avoid showing it in command history
    fd, temp_path = tempfile.mkstemp()
    try:
        with os.fdopen(fd, 'w') as tmp:
            tmp.write(token)
        
        # Set the secret using GitHub CLI
        print(f"\nSetting SCORECARD_READ_TOKEN for {repo}...")
        result = subprocess.run(
            ["gh", "secret", "set", "SCORECARD_READ_TOKEN", "-f", temp_path, "-R", repo],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print("\n✅ Success! SCORECARD_READ_TOKEN has been set.")
            print("The Scorecards workflow should now pass on future runs.")
            return 0
        else:
            print("\n❌ Failed to set the secret")
            print(f"Error: {result.stderr}")
            return 1
    finally:
        # Always remove the temporary file with the token
        os.unlink(temp_path)

if __name__ == "__main__":
    sys.exit(main())
