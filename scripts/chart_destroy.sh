#!/usr/bin/env bash

echo "${kubeconfig}" > ./"${name}.kubeconfig"
export KUBECONFIG="./${name}.kubeconfig"

${pre-destroy-cmds}

helm delete --purge "${name}"

${post-destroy-cmds}

unset KUBECONFIG

rm -f "./${name}.kubeconfig"
