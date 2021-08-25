#!/usr/bin/env bash
SCRIPT_DIR="./scripts"

kubectl create -f "${SCRIPT_DIR}/storageclass-ibmc-vpc-block-10iops-mzr.yaml"