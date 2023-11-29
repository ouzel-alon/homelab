# Jenkins

Spins up a deployment of a Jenkins controller backed by a persistent volume.

The ingress host `jenkins.127.0.0.1.nip.io` uses a self-signed TLS cert issued by cert-manager.

## How to use

Grab the initial password:

```bash
kubectl exec -it -n jenkins deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

Then navigate to the ingress URL.

## Notes

If using the `jenkins/inbound-agent` image, ensure that it's the `jdk17` image and the container template name in the plugin is set to `jnlp`
