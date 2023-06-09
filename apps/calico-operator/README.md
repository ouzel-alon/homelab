# Calico Operator

Installs the Calico Operator, which then manages the installation and configuration of Calico across the cluster.

## kind

It's tricky to bootstrap a CNI on a bare cluster without an existing CNI installed, so kind uses the defaults which contains a barebones CNI (kindnet) on creation.

Once the operator has configured Calico, we don't need kindnet anymore:

```bash
kubectl delete daemonset kindnet -n kube-system
```
