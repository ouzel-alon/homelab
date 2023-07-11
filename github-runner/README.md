# GitHub Runner

A basic self-hosted, self-configuring GitHub runner that should run some popular Actions out of the box.

## Setup

Create a fine-grained PAT with read/write access to `Administration` on the repository, as the script needs to be able to register runner tokens using the PAT: https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository

## Build

```bash
cd github-runner
docker build . --tag github-runner
```

## Run

Set the following environment variables:

```bash
GH_TOKEN
GH_OWNER
GH_REPOSITORY
```

Pass them to the container:

```bash
docker run --name github-runner -e GH_TOKEN="${GH_TOKEN}" -e GH_OWNER="${GH_OWNER}" -e GH_REPOSITORY="${GH_REPOSITORY}" -d --rm github-runner
```

Once the runner is registered to GitHub, point CI to use `runs-on: self-hosted`
