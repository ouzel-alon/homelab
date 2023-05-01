# kube-prometheus

Deploys the full, highly-available stack of Prometheus, Grafana and Alertmanager using the Prometheus Operator.

The apps are exposed with basic ingress rules.

## Preview

```bash
kubectl get pods -n monitoring

NAME                                   READY   STATUS    RESTARTS   AGE
alertmanager-main-0                    2/2     Running   0          52s
alertmanager-main-1                    2/2     Running   0          52s
alertmanager-main-2                    2/2     Running   0          52s
blackbox-exporter-6b6c8d67b8-rptn5     3/3     Running   0          51s
grafana-575f7f449-2rxrj                1/1     Running   0          50s
kube-state-metrics-f76ffbf8b-zr69b     3/3     Running   0          50s
node-exporter-cx8jq                    2/2     Running   0          49s
node-exporter-h2x4m                    2/2     Running   0          49s
prometheus-adapter-6b88dfd544-9w96k    1/1     Running   0          49s
prometheus-adapter-6b88dfd544-jgdch    1/1     Running   0          49s
prometheus-k8s-0                       2/2     Running   0          48s
prometheus-k8s-1                       2/2     Running   0          47s
prometheus-operator-5c9d7d6df8-dsvtr   2/2     Running   0          62s
```

## Tested on

* Kubernetes 1.26
* Go 1.18
* kube-prometheus 0.12

## How to use

Add `GOENV` to `PATH` if it's not there already:

```bash
export PATH=$PATH:$(go env GOPATH)/bin
```

Install `jsonnet-bundler` and tools to be able to render the templates:

```bash
go install -a github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
go install github.com/brancz/gojsontoyaml@latest
go install github.com/google/go-jsonnet/cmd/jsonnet@latest
```

Grab the `kube-prometheus` library and render the manifests from jsonnet to Kubernetes YAML:

```bash
cd prometheus
jb install
./build.sh homelab.jsonnet
```

Deploy the manifests, starting with the namespace (default `monitoring`) and CRDs:

```bash
kubectl apply --server-side -f manifests/setup

kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring

kubectl apply -f manifests/
```

Cleanup:

```bash
kubectl delete --ignore-not-found=true -f manifests/ -f manifests/setup
```
