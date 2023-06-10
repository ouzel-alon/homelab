#!/usr/bin/env bash
set -o errexit

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

kind create cluster --config="$SCRIPT_DIR/kind.yaml"

$SCRIPT_DIR/preload.sh install

kubectl apply -k "SCRIPT_DIR/../bootstrap/calico/"
