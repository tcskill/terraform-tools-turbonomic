#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

kubectl delete -f "${SCRIPT_DIR}/storageclass-ibmc-vpc-block-10iops-mzr.yaml"