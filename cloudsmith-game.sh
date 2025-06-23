#!/bin/bash

# ───────────────────────────────
# 🛫 Pre-flight Checks
# ───────────────────────────────

echo ""
echo "🧪 Running pre-flight checks..."

# Ensure pip is available
if ! command -v pip &> /dev/null; then
  echo "❌ 'pip' is not installed or not in PATH. Please install Python and pip."
  exit 1
fi

# Install/upgrade Cloudsmith CLI
echo "📦 Installing/Updating Cloudsmith CLI..."
pip install --upgrade cloudsmith-cli

# Remove existing Langflow wheel file
if ls langflow-1.2.0-*.whl &>/dev/null; then
  echo "🧹 Removing existing langflow wheel file..."
  rm -f langflow-1.2.0-*.whl
fi

# Download and run cleanup script
echo "🧼 Downloading and running cleanup script..."
wget -q https://raw.githubusercontent.com/ndouglas-cloudsmith/cloudsmith-cli/refs/heads/main/cleanup.sh -O cleanup.sh
chmod +x cleanup.sh
./cleanup.sh

# ───────────────────────────────
# 🚀 Main Application Starts Here
# ───────────────────────────────

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
    1) FILTER_NAME="python" ;;
    2) FILTER_NAME="helm" ;;
    3) FILTER_NAME="docker" ;;
    *) echo "❌ Invalid choice. Please try again." && continue ;;
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
  echo "🧪 Initiating suspicious activity simulation..."
  echo "🚨 WARNING: You are about to download a potentially malicious package!"
  echo ""
  read -p "😈 Proceed with insecure download of 'langflow==1.2.0'? (y/n): " CONFIRM_DOWNLOAD

  if [[ "$CONFIRM_DOWNLOAD" == "y" || "$CONFIRM_DOWNLOAD" == "Y" ]]; then
    echo ""
    DOWNLOAD_CMD="pip download langflow==1.2.0 --no-deps"
    echo "📥 Running: $DOWNLOAD_CMD"
    echo -n "+ "
    for ((i=0; i<${#DOWNLOAD_CMD}; i++)); do
      echo -n "${DOWNLOAD_CMD:$i:1}"
      sleep 0.02
    done
    echo ""
    pip download langflow==1.2.0 --no-deps

    echo ""
    echo "📤 Preparing to push the downloaded wheel to Cloudsmith..."
    WHEEL_FILE=$(ls langflow-1.2.0-*.whl 2>/dev/null | head -n 1)

    if [[ -f "$WHEEL_FILE" ]]; then
      echo "📦 Found file: $WHEEL_FILE"

      echo ""
      echo "🔐 Setting up policy enforcement before pushing..."

      wget -q https://raw.githubusercontent.com/ndouglas-cloudsmith/epm-demo/refs/heads/main/workflow1.rego -O workflow1.rego
      ESCAPED_POLICY=$(jq -Rs . < workflow1.rego)

      cat <<EOF > payload.json
{
  "name": "ea-workflow1",
  "description": "Quarantine and tag packages with critical CVEs",
  "rego": $ESCAPED_POLICY,
  "enabled": true,
  "is_terminal": false,
  "precedence": 1
}
EOF

      curl -s -X POST "https://api.cloudsmith.io/v2/workspaces/$CLOUDSMITH_ORG/policies/" \
        -H "Content-Type: application/json" \
        -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
        -d @payload.json | jq .

      SLUG_PERM=$(curl -s -X GET "https://api.cloudsmith.io/v2/workspaces/$CLOUDSMITH_ORG/policies/" \
        -H "X-Api-Key: $CLOUDSMITH_API_KEY" | jq -r '.results[] | select(.name=="ea-workflow1") | .slug_perm')

      curl -s -X POST "https://api.cloudsmith.io/v2/workspaces/$CLOUDSMITH_ORG/policies/$SLUG_PERM/repositories/" \
        -H "Content-Type: application/json" \
        -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
        -d "{\"repository\": \"$REPO_SLUG\"}" | jq .

      curl -s -X POST "https://api.cloudsmith.io/v2/workspaces/$CLOUDSMITH_ORG/policies/$SLUG_PERM/actions/" \
        -H "Content-Type: application/json" \
        -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
        -d '{"action_type": "SetPackageState", "precedence": 1, "package_state": "QUARANTINED"}' | jq .

      curl -s -X POST "https://api.cloudsmith.io/v2/workspaces/$CLOUDSMITH_ORG/policies/$SLUG_PERM/actions/" \
        -H "Content-Type: application/json" \
        -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
        -d '{"action_type": "AddPackageTags", "precedence": 32767, "tags": ["policy-violated"]}' | jq .

      curl -s -X POST "https://api.cloudsmith.io/v2/workspaces/$CLOUDSMITH_ORG/policies/$SLUG_PERM/actions/" \
        -H "Content-Type: application/json" \
        -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
        -d '{"action_type": "RejectPackageUpload", "precedence": 0, "message": "Upload blocked by security policy."}' | jq .

      echo ""
      echo "🚀 Pushing package with CVE tag and policy enforcement..."
      PUSH_CMD="cloudsmith push python $REPO_PATH \"$WHEEL_FILE\" -k \"\$CLOUDSMITH_API_KEY\" --tags workflow1"
      echo -n "+ "
      for ((i=0; i<${#PUSH_CMD}; i++)); do
        echo -n "${PUSH_CMD:$i:1}"
        sleep 0.02
      done
      echo ""
      cloudsmith push python "$REPO_PATH" "$WHEEL_FILE" -k "$CLOUDSMITH_API_KEY" --tags workflow1

      if [[ $? -eq 0 ]]; then
        echo "✅ Package pushed with simulated CVE tag!"

        echo ""
        read -p "📋 Would you like to view the decision log for this policy? (y/n): " VIEW_LOG_CHOICE
        if [[ "$VIEW_LOG_CHOICE" == "y" || "$VIEW_LOG_CHOICE" == "Y" ]]; then
          echo ""
          DECISION_LOG_CMD="curl -X GET \"https://api.cloudsmith.io/v2/workspaces/$CLOUDSMITH_ORG/policies/decision_logs/?policy=$SLUG_PERM\" -H \"Accept: application/json\" -H \"X-Api-Key: \$CLOUDSMITH_API_KEY\" | jq ."
          echo "📜 Fetching decision log..."
          echo -n "+ "
          for ((i=0; i<${#DECISION_LOG_CMD}; i++)); do
            echo -n "${DECISION_LOG_CMD:$i:1}"
            sleep 0.02
          done
          echo ""
          curl -s -X GET "https://api.cloudsmith.io/v2/workspaces/$CLOUDSMITH_ORG/policies/decision_logs/?policy=$SLUG_PERM" \
            -H "Accept: application/json" \
            -H "X-Api-Key: $CLOUDSMITH_API_KEY" | jq .
        else
          echo "👍 Skipping decision log view."
        fi
      else
        echo "❌ Failed to push package. You might want to double-check the file or credentials."
      fi
    else
      echo "❌ Could not find the downloaded wheel file. Check if the package was downloaded correctly."
    fi
  else
    echo "🚫 Skipping insecure download simulation."
  fi

  echo ""
read -p "🤔 Based on the decision log, do you trust the quarantined package? (yes/no): " TRUST_CHOICE

if [[ "$TRUST_CHOICE" == "yes" ]]; then
  echo ""
  echo "📦 Listing quarantined packages in $REPO_PATH..."
  cloudsmith list packages "$REPO_PATH" -q "status:quarantined" -k "$CLOUDSMITH_API_KEY"

  echo ""
  read -p "🔓 Enter the identifier of the package you'd like to remove from quarantine: " PACKAGE_ID

  if [[ -n "$PACKAGE_ID" ]]; then
    echo "🧹 Removing quarantine from package: $PACKAGE_ID"
    cloudsmith quarantine remove "$REPO_PATH/$PACKAGE_ID" -k "$CLOUDSMITH_API_KEY"
    echo "✅ Package restored from quarantine."
    echo "🧼 Deleting OPA Policies..."
    curl -X DELETE "https://api.cloudsmith.io/v2/workspaces/acme-corporation/policies/$SLUG_PERM/" \
    -H "X-Api-Key: $CLOUDSMITH_API_KEY"
    echo "🎉 Congratulations! You have completed the lab exercise."
    exit 0
  else
    echo "⚠️ No identifier entered. Skipping quarantine removal."
  fi

elif [[ "$TRUST_CHOICE" == "no" ]]; then
  echo ""
  echo "🧼 Running cleanup scripts..."
  ./cleanup.sh
  echo "🧼 Deleting OPA Policies..."
  curl -X DELETE "https://api.cloudsmith.io/v2/workspaces/acme-corporation/policies/$SLUG_PERM/" \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY"
  echo "🎉 Congratulations! You have completed the lab exercise."
  exit 0
else
  echo "❌ Invalid input. Please respond with 'yes' or 'no'."
fi

  echo ""
  read -p "🔄 Press Enter to scan another repository or Ctrl+C to quit..." _
  clear
done
