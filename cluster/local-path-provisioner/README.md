# Local Path Provisioner

From https://github.com/rancher/local-path-provisioner

Local Path Provisioner provides a way for the Kubernetes users to utilize the local storage in each node. Based on the user configuration, the Local Path Provisioner will create either hostPath or local based persistent volume on the node automatically. It utilizes the features introduced by Kubernetes Local Persistent Volume feature, but makes it a simpler solution than the built-in local volume feature in Kubernetes.

## Requirements

* Kubernetes 1.12+

## How to use

Deploy to your cluster:

```bash
cd local-path-provisioner
kubectl apply -k .
```

Once deployed, set it as the default storage class:

```bash
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```
