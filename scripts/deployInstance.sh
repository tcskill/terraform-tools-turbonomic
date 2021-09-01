#!/usr/bin/env bash

if [[ -z "${TMP_DIR}" ]]; then
    TMP_DIR=".tmp"
fi
mkdir -p "${TMP_DIR}"

NAMESPACE="$1"
PROBES="$2"
CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$3" == "destroy" ]]; then
    echo "removing xl-release..."
    # remove the the release
    kubectl delete -f "${TMP_DIR}/xl-release.yaml" -n ${NAMESPACE}
else 

    cp "${CHARTS_DIR}/t8c-xl-release-mzr.yaml" "${TMP_DIR}/xl-release.yaml"
    if [[ "${PROBES}" =~ kubeturbo ]]; then
      echo "adding kubeturbo probe..."
      cat >> ${TMP_DIR}/xl-release.yaml << EOL
  kubeturbo:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ openshiftingress ]]; then
      echo "adding openshiftingress probe..."
      cat >> ${TMP_DIR}/xl-release.yaml << EOL
  openshiftingress:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ instana ]]; then
      echo "adding instana probe..."
      cat >> ${TMP_DIR}/xl-release.yaml << EOL
  instana:
    enabled: true
EOL
    fi
    # deploy the release
    kubectl apply -f "${TMP_DIR}/xl-release.yaml" -n ${NAMESPACE}


fi
