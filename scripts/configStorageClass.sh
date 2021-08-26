#!/usr/bin/env bash

CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$1" == "destroy" ]]; then
    echo "removing storage class..."
    kubectl delete -f "${CHARTS_DIR}/storageclass-ibmc-vpc-block-10iops-mzr.yaml"
else 
    kubectl create -f "${CHARTS_DIR}/storageclass-ibmc-vpc-block-10iops-mzr.yaml"
fi