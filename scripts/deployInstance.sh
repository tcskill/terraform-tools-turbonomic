#!/usr/bin/env bash

if [[ -z "${TMP_DIR}" ]]; then
    TMP_DIR=".tmp"
fi
mkdir -p "${TMP_DIR}"

NAMESPACE="$1"
CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$2" == "destroy" ]]; then
    echo "removing chart extension..."
    # remove the the release
    #kubectl delete -f "${TMP_DIR}/operator.yaml" -n ${NAMESPACE} --validate=false
    kubectl delete -f "${CHARTS_DIR}/t8c-xl-release-mzr.yaml" -n ${NAMESPACE}
else 
    # deploy the release
    kubectl apply -f "${CHARTS_DIR}/t8c-xl-release-mzr.yaml" -n ${NAMESPACE}

    # create the yaml for operator deployment and deploy it
    #kubectl create -f "${TMP_DIR}/operator.yaml" -n ${NAMESPACE} --validate=false
fi
