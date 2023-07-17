# Terraform

Terraform for managing VMs via the `libvirt` provider.

This is intended to run an on-prem Kubernetes cluster with nodes on Flatcar Linux, and support tooling that needs to live outside the cluster.

Butane configs are transpiled into Ignition configs via the `poseidon/ct` provider.

## Requirements

A bare-metal Linux server configured for virtualisation, this setup uses Fedora Server:

* KVM
* QEMU
* libvirt

Flatcar Linux image and a `qcow2` snapshot of it on the VM host: https://www.flatcar.org/docs/latest/installing/vms/libvirt/#download-the-flatcar-container-linux-image

SSH keypair for libvirt, loaded into the agent when Terraform is ran, or else you'll have to specify the private key in the URI, ex:

```
provider "libvirt" {
  uri = "qemu+ssh://host/system?keyfile=/home/..."
}
```

Once the Kubernetes cluster is setup, install the reboot controller: [Flatcar Linux Update Operator](https://github.com/flatcar/flatcar-linux-update-operator)

## Notes

Handy SSH config to tunnel through the host into the `libvirt` network, this uses the default `libvirt` subnet and the default Flatcar/FCOS user `core`:

```
Host 192.168.122.*
  user core
  ProxyJump <host>
  IdentityFile ~/.ssh/id_<your_key>
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  AddKeysToAgent yes
```
