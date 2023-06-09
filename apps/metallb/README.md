# MetalLB

Deploys MetalLB in Layer 2 mode and issues LoadBalancer IPs from the top range of the Docker bridge network.

To test it, the `http-echo` app deploys 2 pods behind a LoadBalancer in the default namespace:

The LoadBalancer should be distributing traffic between the two pods:

```bash
cd http-echo

kubectl apply -k .
service/foobar created
pod/bar-app created
pod/foo-app created

kubectl get service foobar
NAME     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)          AGE
foobar   LoadBalancer   10.96.101.99   172.19.255.241   5678:31176/TCP   8m40s

LB_IP=$(kubectl get svc/foobar -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

for _ in {1..10}; do curl ${LB_IP}:5678; done
bar
bar
foo
bar
bar
bar
foo
bar
foo
foo
```
