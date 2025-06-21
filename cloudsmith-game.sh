#!/bin/bash

clear
echo "==============================="
echo "📦 Cloudsmith Repo Scanner"
echo "==============================="

# Ensure required environment variables are set
if [[ -z "$CLOUDSMITH_API_KEY" || -z "$CLOUDSMITH_ORG" ]]; then
  echo "❌ Please run: source ./set-env.sh"
  exit 1
fi

read -p "🎯 Enter the repository slug to scan (e.g., acme-repo-one): " REPO_SLUG
REPO_PATH="$CLOUDSMITH_ORG/$REPO_SLUG"

echo ""
echo "🔍 Scanning for packages in '$REPO_PATH'..."
echo ""

cloudsmith list packages "$REPO_PATH" -k "$CLOUDSMITH_API_KEY"
