#!/usr/bin/env bash

if [[ -z "${TMP_DIR}" ]]; then
    TMP_DIR=".tmp"
fi
mkdir -p "${TMP_DIR}"

SANAME="$1"
NAMESPACE="$2"
CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$3" == "destroy" ]]; then
    echo "removing chart extension..."
    # remove the the operator and chart extensions
    #kubectl delete -f "${TMP_DIR}/operator.yaml" -n ${NAMESPACE} --validate=false
    kubectl delete -f "${CHARTS_DIR}/t8c-xl-release-mzr.yaml" 
else 
    # deploy the chart extensions needed
    kubectl create -f "${CHARTS_DIR}/t8c-xl-release-mzr.yaml"

    # create the yaml for operator deployment and deploy it
    #kubectl create -f "${TMP_DIR}/operator.yaml" -n ${NAMESPACE} --validate=false
fi
