# Helm Chart

This Terraform module installs a Helm chart on a K8s cluster. It is useful for overcoming the limitations of the main [Helm release resource](https://www.terraform.io/docs/providers/helm/release.html) when you want to spin up a cluster and use it as a provider for k8s resources within the same Terraform plan.

- [Usage](#usage)
- [Variables](#variables)
- [Links](#links)

## Usage

Here are a few different examples for how to use this module:

### Cert-Manager

```hcl
module "cert-manager" {
  source     = "git@github.com:dansible/terraform-null-helm-chart.git?ref=v0.0.2"

  # This is assumed to be the output of the GKE module but can be any Kubeconfig
  kubeconfig  = "${module.k8s.kubeconfig}"

  # This is used to manage install/uninstall process
  enabled    = true

  # This is assumed to be the output of the Helm install module but can be any TF resource
  depends_on = "${module.helm.dependency}"

  name          = "certmanager"
  chart_name    = "stable/cert-manager"
  chart_version = "0.5.2"
  namespace     = "kube-system"
  values            = "${file("values.yaml")}"

  helm-extra-args   = "--set resources.requests.cpu=10m --set resources.requests.memory=32Mi --set resources.limits.cpu=50m --set resources.limits.memory=128Mi"

  pre-install-cmds  = ""
  post-install-cmds = ""
  pre-destroy-cmds  = ""

  # Delete any remaining CRDs created by the cert-manager chart
  post-destroy-cmds = "kubectl delete customresourcedefinitions.apiextensions.k8s.io certificates.certmanager.k8s.io clusterissuers.certmanager.k8s.io issuers.certmanager.k8s.io"
}
```

### Vault

```hcl
module "vault" {
  source        = "git@github.com:dansible/terraform-null-helm-chart.git?ref=v0.0.2"
  kubeconfig     = "${module.k8s.kubeconfig}"
  enabled       = true
  depends_on    = ["${module.helm.dependency}"]
  name          = "vault"
  chart_name    = "."
  chart_version = "0.0.1"
  namespace     = "default"

  helm-extra-args  = "--set consul.affinity=\"\""
  pre-install-cmds  = <<EOF
if [ ! -d vault-helm ] ; then git clone https://github.com/helm/charts.git ; fi
cd charts/incubator/vault/
EOF
  pre-destroy-cmds  = ""
  post-destroy-cmds = ""
}
```

### Fluent-Bit

```hcl
module "fluentbit" {
  source            = "git@github.com:dansible/terraform-null-helm-chart.git?ref=v0.0.2"
  kubeconfig         = "${module.k8s.kubeconfig}"
  enabled           = true
  depends_on        = ["${module.helm.dependency}"]
  name              = "fluentbit"
  chart_name        = "lms-helm-charts/fluent-bit"
  chart_version     = "0.10.0"
  namespace         = "infra"
  pre-install-cmds  = "${file("${path.module}/fluent-bit.sh")}"
  values            = "${data.vault_generic_secret.fluentbit-values.data_json}"
}
```

Contents of fluent-bit.sh:

```sh
set -o errexit
set -o pipefail
set -o nounset

if ! helm plugin list | grep s3 > /dev/null; then
  helm plugin install https://github.com/hypnoglow/helm-s3.git
fi

if helm repo list | grep private-helm-charts > /dev/null; then
  helm repo update
else
  helm repo add lms-helm-charts s3://private-helm-charts/
fi

set +o errexit
set +o pipefail
set +o nounset
```

## Variables

For more info, please see the [variables file](variables.tf).

| Variable               | Description                         | Default                                               |
| :--------------------- | :---------------------------------- | :---------------------------------------------------- |
| `kubeconfig` | Kubeconfig for cluster in which Helm will be installed. | `(Required)` |
| `enabled` | Whether to enable this module. Set to `false` to properly uninstall the chart. | `true` |
| `name` | The name to assign to the chart & temporary resources. | `certmanager` |
| `chart_name` | The name of the chart to install. | `stable/cert-manager` |
| `chart_version` | Version of Tiller component. Must match the Helm cli on the machine executing Terraform. | `0.5.2` |
| `namespace` | The namespace to install the chart to. | `default` |
| `helm-extra-args` | Extra arguments to pass to helm command. | `""` |
| `values` | Content of Helm values file rendered as a string. | `""` |
| `pre-install-cmds` | Custom commands to run before installing the chart. | `""` |
| `post-install-cmds` | Custom commands to run after installing the chart. | `""` |
| `pre-destroy-cmds` | Custom commands to run before destroying the chart. | `""` |
| `post-destroy-cmds` | Custom commands to run after destroying the chart. | `""` |

### Dependency Variables

This module exposes two variables to work around the limitations of module dependencies in Terraform.

| Name               | Type                         | Description                                     |
| :----------------- | :--------------------------- | :---------------------------------------------- |
| `depends_on` | `list variable` | Dummy variable to enable module dependencies. |
| `dependency` | `list output` | Dummy output to enable module dependencies. |

Using these two, you can emulate the functionality of `depends_on` by chaining one module's `dependency` output to another's `depends_on` input.

## Links

### Cert-Manager

- https://github.com/helm/charts/tree/master/stable/cert-manager
- https://cert-manager.readthedocs.io/en/latest/tutorials/acme/quick-start/index.html
- https://cert-manager.readthedocs.io/en/latest/getting-started/install.html
- https://cert-manager.readthedocs.io/en/latest/tasks/issuers/index.html
- https://cert-manager.readthedocs.io/en/latest/tasks/issuing-certificates/ingress-shim.html

### Terraform

- https://github.com/hashicorp/terraform/issues/15933
- https://www.terraform.io/docs/providers/template/
- https://www.terraform.io/docs/configuration/interpolation.html#templates
