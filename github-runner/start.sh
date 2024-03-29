#!/usr/bin/env bash

RUNNER_SUFFIX=$(openssl rand -hex 3)
# RUNNER_SUFFIX=$(tr -dc 'a-z0-9' < /dev/urandom | head -c6)

RUNNER_NAME="runner-${RUNNER_SUFFIX}"

REG_TOKEN=$(curl -sL \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GH_TOKEN}"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
"https://api.github.com/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token" | jq .token --raw-output)

./config.sh --unattended --url "https://github.com/${GH_OWNER}/${GH_REPOSITORY}" --token "${REG_TOKEN}" --name "${RUNNER_NAME}"

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token "${REG_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
