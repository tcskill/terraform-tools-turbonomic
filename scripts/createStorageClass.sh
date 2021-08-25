#!/usr/bin/env bash
SCRIPT_DIR = "${path.module}/scripts"

kubectl create -f "${SCRIPT_DIR}/storageclass-ibmc-vpc-block-10iops-mzr.yaml"