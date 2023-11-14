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

  # store
  tempDir=$(mktemp -d -t artifact-temp-dir.XXXXXX)
  trap 'rm -rf "$tempDir"' EXIT

  # curl
  workflow_run_url=$(curl -sL -H "Authorization: Bearer $github_token" \
    "https://api.github.com/repos/$REPO_NAME/actions/runs?branch=$REPO_BRANCH")
  workflow_run_url=$(echo "$workflow_run_url" | grep -o '"url": "[^"]*' | sed 's/"url": "\(.*\)"/\1/')
  artifact_url=$(curl -sL -H "Authorization: Bearer $github_token" \
    "$workflow_run_url/artifacts")
  artifact_url=$(echo "$artifact_url" | grep -o '"archive_download_url": "[^"]*' | sed 's/"archive_download_url": "\(.*\)"/\1/')
  curl -LJO "$artifact_url"

  # result
  if [ $? -ne 0 ]; then
    echo "Error downloading artifact: $artifact_url"
    exit 1
  fi

  echo "Downloaded artifact for ${REPO_NAME} to ${tempDir}"
}

