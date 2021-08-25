#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

kubectl create -f "${MODULE_DIR}/storageclass-ibmc-vpc-block-10iops-mzr.yaml"