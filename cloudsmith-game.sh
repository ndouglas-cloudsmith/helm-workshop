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

# Build the command string
CMD="cloudsmith list packages \"$REPO_PATH\" -k \"\$CLOUDSMITH_API_KEY\""

# Typewriter effect
echo -n "+ "
for ((i=0; i<${#CMD}; i++)); do
  echo -n "${CMD:$i:1}"
  sleep 0.02
done
echo ""

# Actually run the command
cloudsmith list packages "$REPO_PATH" -k "$CLOUDSMITH_API_KEY"
