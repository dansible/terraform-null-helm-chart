set -o errexit
set -o pipefail
set -o nounset

until kubectl get po -n kube-system -o json -l app=helm,name=tiller | jq -r '.items[].status.containerStatuses[0].ready' | grep true 2>&1; do
  echo "Waiting for Tiller to become ready..." && sleep 1 ;
done

helm upgrade --install "${NAME}" \
  --values "./${NAME}.values" \
  ${HELM_EXTRA_ARGS} \
  --namespace "${NAMESPACE}" \
  --version "${CHART_VERSION}" \
  --wait \
  "${CHART_NAME}"

set +o errexit
set +o pipefail
set +o nounset
