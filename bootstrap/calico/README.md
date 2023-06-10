# Calico

Deploys a minimal install of Calico and `calicoctl`.

Once installed, check the configured IP pool with:

```bash
kubectl exec -it -n kube-system calicoctl -- /calicoctl get ippool
NAME                  CIDR             SELECTOR
default-ipv4-ippool   192.168.0.0/16   all()
```

## Tigera Operator install with kind

It's tricky (but not impossible) to bootstrap a CNI on a bare cluster without an existing CNI installed, so kind uses the defaults which contains a barebones CNI (kindnet) on creation.

Once the operator has configured Calico, we don't need kindnet anymore:

```bash
kubectl delete daemonset kindnet -n kube-system
```
