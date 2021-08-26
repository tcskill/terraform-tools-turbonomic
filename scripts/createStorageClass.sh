#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

kubectl create -f "${SCRIPT_DIR}/storageclass-ibmc-vpc-block-10iops-mzr.yaml"