#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

if [$1 == -d]; then
    echo "removing storage class..."
    kubectl delete -f "${SCRIPT_DIR}/storageclass-ibmc-vpc-block-10iops-mzr.yaml"
fi else kubectl create -f "${SCRIPT_DIR}/storageclass-ibmc-vpc-block-10iops-mzr.yaml"