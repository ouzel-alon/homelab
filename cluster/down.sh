#!/usr/bin/env bash
set -o errexit

CLUSTER="${1:-minikube}"

printf '\n%s\n' "* Check if control node is running"
if [[ $(docker inspect -f '{{.State.Running}}' "${CLUSTER}") ]]; then
    printf '\n%s\n' "* Control plane node found - shutting down"
    minikube stop -p "${CLUSTER}"
else
    printf '\n%s\n' "! Can't find a control plane node. Is the cluster running?"
    exit 1
fi
