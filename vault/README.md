# Hashicorp Vault

Spins up a 3 node Vault cluster backed by Integrated Storage.

Node affinity is temporarily disabled so it can be run on smaller clusters.

## How to use

Make the `vault` namespace:

```bash
cd vault
kubectl apply -f namespace.yaml
```

Build the helm chart and install:

```bash
helm dependency build
helm install vault . -n vault --dry-run
```

Then [initialize and unseal the vault](https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-raft-deployment-guide#initialize-and-unseal-vault)

Expose the web UI with a port forward:

```bash
kubectl port-forward vault-0 8200:8200
```
