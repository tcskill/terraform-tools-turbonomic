#!/usr/bin/env bash

if [[ -z "${TMP_DIR}" ]]; then
    TMP_DIR=".tmp"
fi
mkdir -p "${TMP_DIR}"

NAMESPACE="$1"

if [[ "$2" == "destroy" ]]; then
    echo "removing turbo scc..."
    kubectl delete -f "${TMP_DIR}/turboscc.yaml" -n "${NAMESPACE}"
else 
    kubectl apply -f "${TMP_DIR}/turboscc.yaml" -n "${NAMESPACE}"
fi
