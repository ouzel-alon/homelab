# cert-manager

Spins up cert-manager, bootstaps its own CA, and issues self-signed certs from that CA.

Useful for quick app testing before setting up TLS certs via Let's Encrypt.

## How to use

Once cert-manager pods are up, deploy the CA:

```bash
kubectl apply -f cluster-issuer.yaml
```

Wait for the CA to bootstrap itself:

```bash
kubectl get clusterissuer selfsigned -o wide
NAME         READY   STATUS                AGE
selfsigned   True    Signing CA verified   42m
```

Then you can issue self-signed certificates, ex:
```
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: jenkins
spec:
  secretName: jenkins-tls
  usages:
    - server auth
    - client auth
  dnsNames:
    - "jenkins.127.0.0.1.nip.io"
  issuerRef:
    name: selfsigned
    kind: ClusterIssuer
```
