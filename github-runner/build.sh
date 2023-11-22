#!/usr/bin/env bash

GH_RUNNER_VERSION="2.311.0"
docker build . --tag "github-runner:${GH_RUNNER_VERSION}" --build-arg="GH_RUNNER_VERSION=${GH_RUNNER_VERSION}"
