#!/bin/bash

source ../.env
ID="$1"
REPO_NAME=${ID}_${REPO_NAME}
REPO_URL=${ID}_${REPO_URL}
REPO_BRANCH=${ID}_${REPO_BRANCH}
DOMAIN=${ID}_${DOMAIN}
DEPLOY_PATH=${ID}_${DEPLOY_PATH}
DEPLOY_IGNORE_PATHS=${ID}_${DEPLOY_IGNORE_PATHS}

GITHUB_TOKEN="$2"

pullBuild() {
  echo "downloading GitHub release build for deploy ID: ${ID}..."
  downloadGitHubArtifact "$GITHUB_TOKEN"
}

pushBuild() {
  echo "deploy ID: ${ID} pushing to local server..."

  # ignore paths
  IFS=',' read -ra ignore_paths <<< "${DEPLOY_IGNORE_PATHS}"
  for ignore_path in "${ignore_paths[@]}"; do
      rm -rf "/var/www/html/${DOMAIN}/${ignore_path}"
      cp -r "${DEPLOY_PATH}/${ignore_path}" "/var/www/html/${DOMAIN}/"
  done

  echo "deploy ID: ${ID} pushed to local server successfully."
}

downloadGitHubArtifact() {
  local github_token="$1"

  # Store
  tempDir=$(mktemp -d -t artifact-temp-dir.XXXXXX)
  trap 'rm -rf "$tempDir"' EXIT

  # Fetch the latest workflow run associated with the repository and branch
  workflow_run_url=$(curl -sL -H "Authorization: Bearer $github_token" \
    "https://api.github.com/repos/$REPO_NAME/actions/runs?branch=$REPO_BRANCH" \
    | jq -r '.workflow_runs[0].url')

  # Fetch the artifact download URL from the latest workflow run
  artifact_url=$(curl -sL -H "Authorization: Bearer $github_token" \
    "$workflow_run_url/artifacts" \
    | jq -r '.artifacts[0].archive_download_url')

  # Curl
  curl -LJO "$artifact_url"

  # Check for download errors
  if [ $? -ne 0 ]; then
    echo "Error downloading artifact: $artifact_url"
    exit 1
  fi

  echo "Downloaded artifact for ${REPO_NAME} to ${tempDir}"
}

