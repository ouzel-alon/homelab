# Local Path Provisioner

From https://github.com/rancher/local-path-provisioner

## How to use

Deploy to cluster:

```bash
cd local-path-provisioner
kubectl apply -k .
```

Once deployed, set it as the default storage class:

```bash
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```
