#!/usr/bin/env bash

NAME="${name}"
CHART_NAME="${chart_name}"
CHART_VERSION="${chart_version}"
NAMESPACE="${namespace}"

HELM_EXTRA_ARGS="${helm-extra-args}"

echo "${values}" > "./${name}.values"

echo "${kubeconfig}" > "./${name}.kubeconfig"
export KUBECONFIG="./${name}.kubeconfig"

${pre-install-cmds}

${logic}

${post-install-cmds}

unset KUBECONFIG

rm -f "./${name}.values"
rm -f "./${name}.kubeconfig"
