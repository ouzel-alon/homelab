# Hashicorp Vault

Spins up a high-availability 3-node Vault cluster backed by Integrated Storage.

The cluster is initialised with a single unseal key for homelab convenience. **Do not use** in real workloads.

## How to use

Render and deploy the manifest from the official chart:

```bash
kubectl kustomize --enable-helm . > install.yaml
kubectl apply -f install.yaml
```

Once deployed, pods will be live but not ready (will show as 0/1)

Initialise and unseal Vault on the first pod:

```bash
kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > vault-keys.json

VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" vault-keys.json)
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
VAULT_ROOT_TOKEN=$(jq -r ".root_token" vault-keys.json)
kubectl exec vault-0 -- vault login $VAULT_ROOT_TOKEN
kubectl exec vault-0 -- vault operator members

Host Name    API Address                   Cluster Address                        Active Node    Version    Upgrade Version    Redundancy Zone    Last Echo
---------    -----------                   ---------------                        -----------    -------    ---------------    ---------------    ---------
vault-0      http://10.244.151.6:8200      https://vault-0.vault-internal:8201    true           1.15.2     1.15.2             n/a                n/a
vault-1      http://10.244.205.199:8200    https://vault-1.vault-internal:8201    false          1.15.2     1.15.2             n/a                2023-11-29T09:19:12Z
vault-2      http://10.244.59.137:8200     https://vault-2.vault-internal:8201    false          1.15.2     1.15.2             n/a                2023-11-29T09:19:15Z
```

Enable the key store and Kubernetes authentication:

```bash
kubectl exec vault-0 -- vault secrets enable -path=internal kv-v2
kubectl exec vault-0 -- vault auth enable kubernetes
```

Once initial setup is done, revoke the root token and clear sensitive keys:

```bash
kubectl exec vault-0 -- vault token revoke $VAULT_ROOT_TOKEN
unset $VAULT_ROOT_TOKEN
unset $VAULT_UNSEAL_KEY
```

Cleaning up the storage claims:

```bash
kubectl get pvc -n vault -o name | xargs -I{} kubectl delete {}
```
