# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ARG GH_RUNNER_VERSION="2.306.0"
ARG USERNAME=runner
ARG USER_UID=10000
ARG USER_GID=$USER_UID

RUN apt-get update && apt-get install -y \
    curl git jq lsb-release sqlite3 wget \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
WORKDIR /home/runner

RUN curl -o actions.tar.gz --location "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz" && \
    tar -zxf actions.tar.gz && \
    rm -f actions.tar.gz

RUN ./bin/installdependencies.sh

USER runner

COPY start.sh .
ENTRYPOINT ["./start.sh"]
