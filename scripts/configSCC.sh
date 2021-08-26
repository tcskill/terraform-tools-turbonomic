#!/usr/bin/env bash

if [[ -z "${TMP_DIR}" ]]; then
    TMP_DIR=".tmp"
fi
mkdir -p "${TMP_DIR}"

SANAME="$1"
NAMESPACE="$2"

if [[ "$3" == "destroy" ]]; then
    echo "removing turbo scc..."
    kubectl delete -f "${TMP_DIR}/turboscc.yaml" -n "${NAMESPACE}"
else 
    helm template service-account service-account --repo https://charts.cloudnativetoolkit.dev --set "name=${SANAME}" --set "sccs[0]=anyuid" --set create=true --set "-n=${NAMESPACE}" > "${TMP_DIR}/turboscc.yaml"
    kubectl apply -f "${TMP_DIR}/turboscc.yaml" -n "${NAMESPACE}"
fi
