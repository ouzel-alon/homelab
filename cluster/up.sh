#!/usr/bin/env bash
set -o errexit

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CLUSTER="${1:-minikube}"

# Kubernetes
printf '\n%s\n' "* Start up Kubernetes cluster"
minikube start -n 2 \
    --profile "${CLUSTER}" \
    --container-runtime containerd \
    --cni "${SCRIPT_DIR}/calico/calico.yaml" \
    --extra-config=apiserver.enable-admission-plugins=PodSecurity,ValidatingAdmissionWebhook,MutatingAdmissionWebhook,NodeRestriction

# Calico
printf '\n%s\n' "* Wait for calico controller pod"
kubectl wait --for=condition=Ready pod -l k8s-app=calico-kube-controllers -n kube-system
printf '\n%s\n' "* Wait for felix pods"
kubectl rollout status daemonset calico-node -n kube-system
# kubectl wait --for=condition=Ready pod -l k8s-app=calico-node -n kube-system

# Local Path Provisioner
printf '\n%s\n' "* Install local-path-provisioner"
# kubectl apply -k "${SCRIPT_DIR}/local-path-provisioner/."
printf '\n%s\n' "* Wait for local-path-provisioner"
kubectl wait --for=condition=Ready pod -l app=local-path-provisioner -n local-path-storage

printf '\n%s\n' "* Patch default StorageClass"
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# MetalLB
printf '\n%s\n' "* Enable metallb"
minikube -p "${CLUSTER}" addons enable metallb
printf '\n%s\n' "* Wait for metallb controller pod"
kubectl rollout status deployment -l app=metallb,component=controller -n metallb-system
printf '\n%s\n' "* Wait for metallb speaker pods"
kubectl rollout status daemonset -l app=metallb,component=speaker -n metallb-system

# Ingress
printf '\n%s\n' "* Enable ingress"
minikube -p "${CLUSTER}" addons enable ingress
printf '\n%s\n' "* Wait for ingress controller pod"
kubectl rollout status deployment -l app.kubernetes.io/name=ingress-nginx,app.kubernetes.io/component=controller -n ingress-nginx
