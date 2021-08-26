#!/usr/bin/env bash

CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$1" == "destroy" ]]; then
    echo "removing cluster role and binding..."
    kubectl delete -f "${CHARTS_DIR}/cluster_role_binding.yaml"
    kubectl delete -f "${CHARTS_DIR}/cluster_role.yaml"
else 
    kubectl create -f "${CHARTS_DIR}/cluster_role.yaml"
    kubectl create -f "${CHARTS_DIR}/cluster_role_binding.yaml"
fi