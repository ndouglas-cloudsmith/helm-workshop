#!/bin/bash

clear
echo "==============================="
echo "📦 Cloudsmith Repo Scanner"
echo "==============================="
echo "🕹️  Press 'z' at any time during a prompt to restart from the beginning."
echo ""

# Ensure required environment variables are set
if [[ -z "$CLOUDSMITH_API_KEY" || -z "$CLOUDSMITH_ORG" ]]; then
  echo "❌ Please run: source ./set-env.sh"
  exit 1
fi

while true; do
  echo ""
  read -p "🎯 Enter the repository slug to scan (e.g., acme-repo-one): " REPO_SLUG
  [[ "$REPO_SLUG" == "z" ]] && continue

  REPO_PATH="$CLOUDSMITH_ORG/$REPO_SLUG"

  echo ""
  echo "🔍 Scanning for all packages in '$REPO_PATH'..."
  echo ""

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
  echo "   🔁  Press 'z' to go back"
  echo ""

  read -n 1 -p "👉 Press 1, 2, or 3 to choose: " FILTER_CHOICE
  echo ""
  [[ "$FILTER_CHOICE" == "z" ]] && continue

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
      echo "❌ Invalid choice. Please try again."
      continue
      ;;
  esac

  echo ""
  echo "🔎 Filtering '$FILTER_NAME' packages in '$REPO_PATH'..."
  echo ""

  FILTER_CMD="cloudsmith list packages \"$REPO_PATH\" -q \"format:$FILTER_NAME\" -k \"\$CLOUDSMITH_API_KEY\""
  echo -n "+ "
  for ((i=0; i<${#FILTER_CMD}; i++)); do
    echo -n "${FILTER_CMD:$i:1}"
    sleep 0.02
  done
  echo ""

  cloudsmith list packages "$REPO_PATH" -q "format:$FILTER_NAME" -k "$CLOUDSMITH_API_KEY"

  echo ""
  while true; do
    read -p "📦 Enter the exact package name you'd like to inspect further: " PACKAGE_NAME
    [[ "$PACKAGE_NAME" == "z" ]] && continue 2

    TAG_CMD="cloudsmith tags list \"$REPO_PATH/$PACKAGE_NAME\" -k \"\$CLOUDSMITH_API_KEY\""
    echo ""
    echo "🔍 Listing tags for package '$PACKAGE_NAME'..."
    echo -n "+ "
    for ((i=0; i<${#TAG_CMD}; i++)); do
      echo -n "${TAG_CMD:$i:1}"
      sleep 0.02
    done
    echo ""

    cloudsmith tags list "$REPO_PATH/$PACKAGE_NAME" -k "$CLOUDSMITH_API_KEY"
    if [[ $? -eq 0 ]]; then
      break
    else
      echo ""
      echo "❌ Invalid package name: '$PACKAGE_NAME'. Please try again or press 'z' to restart."
      echo ""
    fi
  done

  echo ""
  read -p "🏷️  Would you like to assign a new tag to this package? (y/n): " ADD_TAG_CHOICE
  if [[ "$ADD_TAG_CHOICE" == "y" || "$ADD_TAG_CHOICE" == "Y" ]]; then
    read -p "📝 Enter the tag you'd like to assign: " NEW_TAG
    echo ""

    TAG_ADD_CMD="cloudsmith tags add \"$REPO_PATH/$PACKAGE_NAME\" \"$NEW_TAG\" -k \"\$CLOUDSMITH_API_KEY\""
    echo "🏷️  Assigning tag '$NEW_TAG' to package '$PACKAGE_NAME'..."
    echo -n "+ "
    for ((i=0; i<${#TAG_ADD_CMD}; i++)); do
      echo -n "${TAG_ADD_CMD:$i:1}"
      sleep 0.02
    done
    echo ""

    cloudsmith tags add "$REPO_PATH/$PACKAGE_NAME" "$NEW_TAG" -k "$CLOUDSMITH_API_KEY"
    if [[ $? -eq 0 ]]; then
      echo "✅ Tag '$NEW_TAG' assigned successfully!"
    else
      echo "❌ Failed to assign tag. Please check the tag format or permissions."
    fi
  else
    echo "👍 Skipping tag assignment."
  fi

  echo ""
  read -p "🗑️  Would you like to remove a tag from this package? (y/n): " REMOVE_TAG_CHOICE
  if [[ "$REMOVE_TAG_CHOICE" == "y" || "$REMOVE_TAG_CHOICE" == "Y" ]]; then
    read -p "📝 Enter the tag you'd like to remove: " REMOVE_TAG
    echo ""

    TAG_REMOVE_CMD="cloudsmith tags remove \"$REPO_PATH/$PACKAGE_NAME\" \"$REMOVE_TAG\" -k \"\$CLOUDSMITH_API_KEY\""
    echo "🗑️  Removing tag '$REMOVE_TAG' from package '$PACKAGE_NAME'..."
    echo -n "+ "
    for ((i=0; i<${#TAG_REMOVE_CMD}; i++)); do
      echo -n "${TAG_REMOVE_CMD:$i:1}"
      sleep 0.02
    done
    echo ""

    cloudsmith tags remove "$REPO_PATH/$PACKAGE_NAME" "$REMOVE_TAG" -k "$CLOUDSMITH_API_KEY"
    if [[ $? -eq 0 ]]; then
      echo "✅ Tag '$REMOVE_TAG' removed successfully!"
    else
      echo "❌ Failed to remove tag. Please check the tag name or permissions."
    fi
  else
    echo "👍 Skipping tag removal."
  fi

  echo ""
  read -p "🔄 Press Enter to scan another repository or Ctrl+C to quit..." _
  clear
done
