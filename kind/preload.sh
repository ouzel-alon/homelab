#!/usr/bin/env bash

# preload.sh
# Preloads images by pulling them from remote registries and loading them to the cluster

set -e
set -u
set -o pipefail

CALICO_VER="3.26.0"
METALLB_VER="0.13.9"

IMAGES=(
    "docker.io/calico/apiserver:v$CALICO_VER"
    "docker.io/calico/cni:v$CALICO_VER"
    "docker.io/calico/csi:v$CALICO_VER"
    "docker.io/calico/node-driver-registrar:v$CALICO_VER"
    "docker.io/calico/node:v$CALICO_VER"
    "docker.io/calico/pod2daemon-flexvol:v$CALICO_VER"
    "quay.io/metallb/controller:v$METALLB_VER"
    "quay.io/metallb/speaker:v$METALLB_VER"
)

# KUBE_VER="1.26.3"
# KUBE_IMAGES=(
#     "registry.k8s.io/etcd:3.5.6-0"
#     "registry.k8s.io/kube-apiserver:v$KUBE_VER"
#     "registry.k8s.io/kube-controller-manager:v$KUBE_VER"
#     "registry.k8s.io/kube-proxy:v$KUBE_VER"
#     "registry.k8s.io/kube-scheduler:v$KUBE_VER"
#     "registry.k8s.io/pause:3.7"
# )

CLUSTER_BIN="kind"

echo -e "* Check cluster binary"
if [[ $(command -v $CLUSTER_BIN) ]]; then
    echo -e "* $($CLUSTER_BIN --version)"
else
    echo "! Can't find the cluster binary. Is $CLUSTER_BIN installed?"
    exit 1
fi

echo -e "* Check control node if cluster is running"
if [[ $(docker inspect -f '{{.State.Running}}' kind-control-plane) ]]; then
    echo "* Control plane node found"
else
    echo "! Can't find a control plane node. Is the cluster running?"
    exit 1
fi

case $1 in
    "pull")
        echo -e "* Download images\n"
        for i in "${IMAGES[@]}"; do
            docker image pull "$i";
        done
        ;&
    *)
        echo -e "* Load image to cluster\n"
        for i in "${IMAGES[@]}"; do
            case $CLUSTER_BIN in
                "kind")
                    kind load docker-image "$i" --name kind;
                    ;;
                "minikube")
                    minikube image load "$i" --daemon;
                    ;;
                *)
                    echo "! Unsupported cluster";
                    ;;
            esac
        done
    ;;
esac

echo -e "* Current images in cluster\n"
docker exec kind-control-plane crictl images
