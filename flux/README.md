# Flux

Deploys [Flux](https://fluxcd.io/) and configures it to watch the `apps` directory.

## Pre-requisites

* A deploy key loaded into the repository
* flux-cli

## How to use

Install and bootstrap Flux on the cluster against the repository with the deploy key:

```bash
flux bootstrap git -s \
  --url=ssh://git@github.com/ouzel-alon/homelab.git \
  --branch=main \
  --path=./flux \
  --private-key-file ~/.ssh/id_ed25519_flux
```

## Upgrades

Install a newer version of the Flux CLI

Generate updated manifests

```bash
flux install --export > flux-system/gotk-components.yaml
```

Commit and push changes, then tell Flux to upgrade itself

```bash
flux reconcile source git flux-system
```

## How it works

Flux is bootstrapped to look for its own manifests under the `flux-system` folder in `/flux`

Inside flux-system, `gotk-sync.yaml` sets up a [source controller](https://fluxcd.io/flux/components/source/) against this repo and watches for manifests under `/flux`, including watching and syncing itself.

Right now there's only `apps-sync.yaml`, but more can be added here for multiple clusters/separating out environments.

`apps-sync.yaml` then finally watches `/apps` and deploys anything put in there.
