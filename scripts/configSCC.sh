#!/usr/bin/env bash

BIN_DIR="$1"

if [[ -z "${TMP_DIR}" ]]; then
    TMP_DIR=".tmp"
fi
mkdir -p "${TMP_DIR}"


SANAME="$2"
NAMESPACE="$3"

if [[ "$4" == "destroy" ]]; then
    echo "removing turbo scc..."
    ${BIN_DIR}/helm template t8scc_chart service-account --repo https://charts.cloudnativetoolkit.dev --set "name=${SANAME}" --set sccs[0]=anyuid --set create=true --set "-n=${NAMESPACE}" | kubectl delete -n "${NAMESPACE}" -f -
else 
    ${BIN_DIR}/helm template t8scc_chart service-account --repo https://charts.cloudnativetoolkit.dev --set "name=${SANAME}" --set sccs[0]=anyuid --set create=true --set "-n=${NAMESPACE}" | kubectl apply -n "${NAMESPACE}" -f -
fi
