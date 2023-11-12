#!/bin/bash

source .env

pullBuild() {
    repo_suffix=$1
    source "repo-name${repo_suffix}.env"

    echo "Pulling repository ${REPO_NAME_${repo_suffix}}..."

    # ssh key validation
    if [ ! -d "${DEPLOY_PATH_${repo_suffix}}/.git" ]; then
        GIT_SSH_COMMAND="ssh -i ${SSH_KEY_PATH_${repo_suffix}}" git clone -b "${REPO_BRANCH_${repo_suffix}}" "${REPO_URL_${repo_suffix}}" "${DEPLOY_PATH_${repo_suffix}}"
    else
        cd "${DEPLOY_PATH_${repo_suffix}}" || exit 1
        GIT_SSH_COMMAND="ssh -i ${SSH_KEY_PATH_${repo_suffix}}" git fetch origin "${REPO_BRANCH_${repo_suffix}}"
        GIT_SSH_COMMAND="ssh -i ${SSH_KEY_PATH_${repo_suffix}}" git reset --hard "origin/${REPO_BRANCH_${repo_suffix}}"
    fi

    echo "Pulling repository ${REPO_NAME_${repo_suffix}} successful!"
}

pushBuild() {
    repo_suffix=$1
    source "repo-name${repo_suffix}.env"

    echo "Deploying repository ${REPO_NAME_${repo_suffix}}..."

    pullRepository ${repo_suffix}

    # ignore list
    IFS=',' read -ra ignore_list <<< "${DEPLOY_PATH_IGNORE_${repo_suffix}}"
    for ignore_item in "${ignore_list[@]}"; do
        rm -rf "/var/www/html/${DOMAIN_${repo_suffix}}/${ignore_item}"
    done

    echo "Deployment for ${REPO_NAME_${repo_suffix}} successful!"
}
