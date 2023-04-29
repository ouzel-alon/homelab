# Homelab

This monorepo runs my homelab.

This is currently a mix of static VMs (provisioned with Vagrant) and a Kubernetes cluster.

## Kubernetes

State: Prototype

### Getting started

Prerequisites:

* `kubectl` 1.26+
* A tool that sets up a local Kubernetes 1.26 cluster. This can be:
  * `kind`
  * `microk8s`
  * `minikube`

This guide uses `minikube` 1.30+.

1. Start a multinode cluster. Enable a more capable CNI plugin like `calico` or `flannel` so we can apply network policies in the future (and easily tunnel the ingress controller to localhost if using WSL2)

```bash
minikube start -n 4 --cni calico
```

2. Enable an ingress controller. Minikube can enable `ingress-nginx` as a convenient addon:

```bash
minikube addons enable ingress
```

3. For Minikube, change the default storage provisioner with Rancher's [Local Path Provisioner](https://github.com/rancher/local-path-provisioner). This makes the cluster behave closer to real-world clusters or you'll run into pod crashes when deploying PVs across a multi-node cluster.

## Vagrant

### Getting started

This was originally created on a Fedora 34 host before being ported into a standard Virtualbox setup, so some kvm/libvirt references may remain.

1. Setup system for virtualisation:
- [Fedora Docs](https://docs.fedoraproject.org/en-US/quick-docs/getting-started-with-virtualization/)
- [Vagrant](https://www.vagrantup.com/) and [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt)
```
$ sudo dnf install vagrant vagrant-libvirt
```

2. Open TCP port 2049 in your firewall for NFSv4. A default setup will have a libvirt zone.

* Fedora 34:
```
$ sudo firewall-cmd --permanent --zone=libvirt --add-port=2049/tcp
$ sudo firewall-cmd --reload

$ firewall-cmd --list-ports --zone=libvirt
2049/tcp
```

3. (Optional) Install some quality of life plugins. `vagrant-cachier` sets up up a local package cache on your host to prevent constant yum/pip downloads when spinning up VMs, and `vagrant-hostmanager` will manage your hosts file so you don't have to worry about their IP addresses.

```
vagrant plugin install vagrant-cachier
vagrant plugin install vagrant-hostmanager
```

4. (Optional) Setup `sudoers` on your workstation to not require password prompts for NFS and automated hosts file updates done by the `vagrant-hostsmanager` plugin. Replace `YOUR_USERNAME` and `YOUR_GROUP` with your respective credentials.

```
# cat /etc/sudoers.d/vagrant
Cmnd_Alias VAGRANT_EXPORTS_CHOWN = /bin/chown 0\:0 /tmp/*
Cmnd_Alias VAGRANT_EXPORTS_MV = /bin/mv -f /tmp/* /etc/exports
Cmnd_Alias VAGRANT_NFSD_CHECK = /usr/bin/systemctl status --no-pager nfs-server.service
Cmnd_Alias VAGRANT_NFSD_START = /usr/bin/systemctl start nfs-server.service
Cmnd_Alias VAGRANT_NFSD_APPLY = /usr/sbin/exportfs -ar
Cmnd_Alias VAGRANT_HOSTMANAGER_UPDATE = /bin/cp /home/<YOUR_USERNAME>/.vagrant.d/tmp/hosts.local /etc/hosts

%<YOUR_GROUP> ALL=(root) NOPASSWD: VAGRANT_EXPORTS_CHOWN, VAGRANT_EXPORTS_MV, VAGRANT_NFSD_CHECK, VAGRANT_NFSD_START, VAGRANT_NFSD_APPLY, VAGRANT_HOSTMANAGER_UPDATE
```

5. Explore the various `Vagrantfiles` and update network data as necessary (like IP addresses) in the `config.vm.define` section.

```ruby
  config.vm.define "sandbox" do |app|
    app.vm.network :public_network, ip: "192.168.1.10"
  end
```

Make it so:

```bash
  cd vagrant/sandbox
  vagrant up
```

### Troubleshooting

Getting a root password prompt when mounting with NFS:

https://www.vagrantup.com/docs/synced-folders/nfs#root-privilege-requirement
