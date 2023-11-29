# Homelab

This monorepo runs my homelab.

This is currently a mix of legacy static VMs (provisioned with Vagrant) and a Kubernetes cluster.

## Prerequisites

* `kubectl` 1.27+
* A tool that sets up a local Kubernetes cluster. This sandbox cluster is built with `minikube`.

## Getting started

```bash
cluster/up.sh
```

The script automates configuration of a few things to make minikube behave a bit closer to real-world clusters:

* Starts up at least 3 worker nodes to test HA setups with node affinity (ex: Hashicorp Vault)
* Enables newer versions of calico, metallb and ingress-nginx than the built-in addons
* Switches the default StorageClass to Rancher's Local Path Provisioner (`kind` has this by default)
* Switches the default container runtime to `containerd`, which cloud clusters like AKS and GKE use.

## Things to do

Setup metrics
