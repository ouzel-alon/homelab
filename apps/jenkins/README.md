# Jenkins

Spins up a single-replica pod of a Jenkins controller backed by a persistent volume.

The Jenkins UI is exposed over the `/jenkins` URL path via an ingress rule.

## How to use

Requirements:

* local-path-provisioner

Deploy to your cluster:

```bash
cd jenkins
kubectl apply -k .
```

Then check if it's running and the ingress rule has your cluster IP:

```bash
$ kubectl rollout status deployment/jenkins -n jenkins
deployment "jenkins" successfully rolled out

$ kubectl get ingress -n jenkins
NAME              CLASS   HOSTS   ADDRESS           PORTS   AGE
jenkins-ingress   nginx   *       <your-cluster-ip> 80      x

$ curl -i "http://$(minikube ip)/jenkins"
HTTP/1.1 302 Found
Date: x
Content-Length: 0
Connection: keep-alive
Location: http://<your-cluster-ip>/jenkins/
```

## Initial setup

Grab the initial password from the Jenkins pod:

```bash
kubectl exec -it -n jenkins $(kubectl get pods -l app=jenkins -o jsonpath='{.items[*].metadata.name}' -n jenkins) -- cat /var/jenkins_home/secrets/initialAdminPassword
```

Then navigate with your browser to the `/jenkins` URL on your external cluster IP and provide it the initial password to begin the first time setup process.

## Notes

The manifests use the `jenkins` namespace. Update it if you want Jenkins to run somewhere else.

If using the `jenkins/inbound-agent` image, ensure that it's the `jdk17` image and the container template name in the plugin is set to `jnlp`
