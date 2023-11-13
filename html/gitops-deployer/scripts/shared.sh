#!/bin/bash

source ../.env
ID="$1"
REPO_NAME=${ID}_${REPO_NAME}
REPO_URL=${ID}_${REPO_URL}
REPO_BRANCH=${ID}_${REPO_BRANCH}
DOMAIN=${ID}_${DOMAIN}
DEPLOY_PATH=${ID}_${DEPLOY_PATH}
DEPLOY_IGNORE_PATHS=${ID}_${DEPLOY_IGNORE_PATHS}

pullBuild() {
  echo "Downloading GitHub release build for deploy ID: ${ID}..."
  # todo: downloadGitHubRelease()
}

pushBuild() {
  echo "Deploy ID: ${ID} pushing to local server..."

  # ignore paths
  IFS=',' read -ra ignore_paths <<< "${DEPLOY_IGNORE_PATHS}"
  for ignore_path in "${ignore_paths[@]}"; do
      rm -rf "/var/www/html/${DOMAIN}/${ignore_path}"
      cp -r "${DEPLOY_PATH}/${ignore_path}" "/var/www/html/${DOMAIN}/"
  done

  echo "deploy ID: ${ID} pushed to local server successful!"
}

func downloadGitHubRelease(repoURL, repoBranch, repoName string) error {
  // store
  tempDir, err := ioutil.TempDir("", "release-temp-dir")
  if err != nil {
    return fmt.Errorf("error creating temporary directory: %s", err)
  }
  defer os.RemoveAll(tempDir)

  // curl
  releaseURL := fmt.Sprintf("%s/releases/download/%s/RELEASE_FILE_NAME", repoURL, repoBranch)
  downloadCmd := exec.Command("curl", "-LJO", releaseURL)
  downloadCmd.Dir = tempDir
  downloadOutput, downloadErr := downloadCmd.CombinedOutput()

  if downloadErr != nil {
    return fmt.Errorf("error downloading release file: %s", downloadErr)
  }

  fmt.Printf("Downloaded release file for %s to %s\n", repoName, tempDir)

  return nil
}
