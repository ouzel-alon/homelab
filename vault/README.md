# Hashicorp Vault

Spins up a high-availability 3 node Vault cluster backed by Integrated Storage.

Node affinity is disabled so it can be run on smaller clusters.

The cluster is initialised with a low key threshold for development convenience. Do not use in production workloads.

## Requirements

* Kubernetes 1.26+
* Helm 3

## How to use

Make the `vault` namespace. Make the ingress rule as well if using the web UI.

The ingress rule in the Helm chart isn't used as it defines a host header.

Vault doesn't officially support being hosted off subpaths (`example.com/vault`) and is expected to be on its own subdomain.

```bash
cd vault
kubectl apply -f namespace.yaml
kubectl apply -f ingress.yaml
```

Add the Helm repo and install Vault:

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault -n vault -f values.yaml
```

Once deployed, pods will be live but not ready (will show as 0/1)

Initialise and unseal Vault on the first pod:

```bash
kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json

VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json)
kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
```

Join the other nodes and form a cluster:

```bash
kubectl exec vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY

kubectl exec vault-2 -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY
```

View the cluster:

```bash
VAULT_ROOT_TOKEN=$(jq -r ".root_token" cluster-keys.json)
kubectl exec vault-0 -- vault login $VAULT_ROOT_TOKEN
kubectl exec vault-0 -- vault operator members

Host Name    API Address                   Cluster Address                        Active Node    Version    Upgrade Version    Redundancy Zone    Last Echo
---------    -----------                   ---------------                        -----------    -------    ---------------    ---------------    ---------
vault-0      http://10.244.151.5:8200      https://vault-0.vault-internal:8201    true           1.13.1     1.13.1             n/a                n/a
vault-1      http://10.244.205.197:8200    https://vault-1.vault-internal:8201    false          1.13.1     1.13.1             n/a                2023-04-29T07:27:04Z
vault-2      http://10.244.59.134:8200     https://vault-2.vault-internal:8201    false          1.13.1     1.13.1             n/a                2023-04-29T07:27:00Z

```

Enable a secrets engine and Kubernetes authentication (optional)

```bash
kubectl exec vault-0 -- vault secrets enable -path=internal kv-v2
kubectl exec vault-0 -- vault auth enable kubernetes
```

To access the web UI without the ingress rule, expose it with a port forward:

```bash
kubectl port-forward vault-0 8200:8200
```

Cleanup:

```bash
helm uninstall vault -n vault
kubectl get pvc -n vault -o name | xargs -I{} kubectl delete {}
```
