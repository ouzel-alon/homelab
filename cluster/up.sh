#!/usr/bin/env bash
set -o errexit

blue=$(tput setaf 4)
normal=$(tput sgr0)

function info() {
    # printf '\n%s\n' "* $1"
    printf "[%s] * ${blue}%s\n${normal}" "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CLUSTER="${1:-minikube}"

# Kubernetes
info "Start up Kubernetes cluster"
minikube start -n 4 \
    --profile "${CLUSTER}" \
    --cpus 2 \
    --memory 2g \
    --container-runtime containerd \
    --cni "${SCRIPT_DIR}/calico/calico.yaml" \
    --extra-config=apiserver.enable-admission-plugins=NamespaceExists
    # --extra-config=kubelet.seccomp-default=True

info "Wait 10s for cluster to be stable"
sleep 10

# Calico
# Might time out on a single node cluster if the controller doesn't start up on time
info "Wait for calico controller pod"
kubectl wait --for=condition=Ready pod -l k8s-app=calico-kube-controllers --timeout=60s -n kube-system
info "Wait for felix pods"
kubectl rollout status daemonset calico-node -n kube-system

# Local Path Provisioner
info "Install local-path-provisioner"
kubectl apply -k "${SCRIPT_DIR}/local-path-provisioner/"
info "Wait for local-path-provisioner"
kubectl wait --for=condition=Ready pod -l app=local-path-provisioner -n local-path-storage

info "Patch default StorageClass"
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# MetalLB
info "Install metallb"
kubectl apply -k "${SCRIPT_DIR}/metallb/"
info "Wait for metallb custom resources"
kubectl wait --for condition=Established --all CustomResourceDefinition --namespace=metallb-system
info "Wait for metallb controller pod"
kubectl rollout status deployment -l app=metallb,component=controller -n metallb-system
info "Wait for metallb speaker pods"
kubectl rollout status daemonset -l app=metallb,component=speaker -n metallb-system
info "Configure metallb address pool"
kubectl apply -f "${SCRIPT_DIR}/metallb/config.yaml"

# Ingress
info "Install ingress"
kubectl apply -k "${SCRIPT_DIR}/ingress-nginx/"
info "Wait for ingress controller pod"
kubectl rollout status deployment -l app.kubernetes.io/name=ingress-nginx,app.kubernetes.io/component=controller -n ingress-nginx

info "Done!"
