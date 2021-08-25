#!/usr/bin/env bash
SCRIPT_DIR = "$1"

kubectl create -f "${SCRIPT_DIR}/storageclass-ibmc-vpc-block-10iops-mzr.yaml"