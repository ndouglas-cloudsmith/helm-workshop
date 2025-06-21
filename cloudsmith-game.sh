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
echo "🔍 Scanning for all packages in '$REPO_PATH'..."
echo ""

# Show and run unfiltered command
BASE_CMD="cloudsmith list packages \"$REPO_PATH\" -k \"\$CLOUDSMITH_API_KEY\""
echo -n "+ "
for ((i=0; i<${#BASE_CMD}; i++)); do
  echo -n "${BASE_CMD:$i:1}"
  sleep 0.02
done
echo ""

cloudsmith list packages "$REPO_PATH" -k "$CLOUDSMITH_API_KEY"

echo ""
echo "🎯 Now choose a package type to filter:"
echo "   1️⃣  Python"
echo "   2️⃣  Helm"
echo "   3️⃣  Docker"
echo ""

read -n 1 -p "👉 Press 1, 2, or 3 to choose: " FILTER_CHOICE
echo ""

# Determine filter based on choice
case "$FILTER_CHOICE" in
  1)
    FILTER_NAME="python"
    ;;
  2)
    FILTER_NAME="helm"
    ;;
  3)
    FILTER_NAME="docker"
    ;;
  *)
    echo "❌ Invalid choice. Please run the script again and choose 1, 2, or 3."
    exit 1
    ;;
esac

echo ""
echo "🔎 Filtering '$FILTER_NAME' packages in '$REPO_PATH'..."
echo ""

# Build and show the filter command
FILTER_CMD="cloudsmith list packages \"$REPO_PATH\" -q \"format:$FILTER_NAME\" -k \"\$CLOUDSMITH_API_KEY\""
echo -n "+ "
for ((i=0; i<${#FILTER_CMD}; i++)); do
  echo -n "${FILTER_CMD:$i:1}"
  sleep 0.02
done
echo ""

# Run the filtered command
cloudsmith list packages "$REPO_PATH" -q "format:$FILTER_NAME" -k "$CLOUDSMITH_API_KEY"
