#!/bin/bash

source .env

getConfig() {
    repo_prefix=$1

    repo_name="${repo_prefix}_REPO_NAME"
    repo_branch="${repo_prefix}_REPO_BRANCH"
    domain="${repo_prefix}_DOMAIN"
    deploy_path="${repo_prefix}_DEPLOY_PATH"
}

pullBuild() {
    repo_prefix=$1
    getConfig $repo_prefix

    echo "Downloading GitHub release build for ${!repo_name}..."

    # todo: downloadGitHubRelease()
}

pushBuild() {
    repo_prefix=$1
    getConfig $repo_prefix

    echo "Pushing repository ${!repo_name} to local server..."

    # ignore list
    IFS=',' read -ra ignore_list <<< "${!deploy_path_ignore}"
    for ignore_item in "${ignore_list[@]}"; do
        rm -rf "/var/www/html/${!domain}/${ignore_item}"
        cp -r "${!deploy_path}/${ignore_item}" "/var/www/html/${!domain}/"
    done

    echo "Pushing for ${!repo_name} to local server successful!"
}

func downloadGitHubRelease(repoURL, repoBranch, repoName string) error {
	// store
	tempDir, err := ioutil.TempDir("", "release-temp-dir")
	if err != nil {
		return fmt.Errorf("Error creating temporary directory: %s", err)
	}
	defer os.RemoveAll(tempDir)

  // curl
	releaseURL := fmt.Sprintf("%s/releases/download/%s/RELEASE_FILE_NAME", repoURL, repoBranch)
	downloadCmd := exec.Command("curl", "-LJO", releaseURL)
	downloadCmd.Dir = tempDir
	downloadOutput, downloadErr := downloadCmd.CombinedOutput()

	if downloadErr != nil {
		return fmt.Errorf("Error downloading release file: %s", downloadErr)
	}

	fmt.Printf("Downloaded release file for %s to %s\n", repoName, tempDir)

	return nil
}
