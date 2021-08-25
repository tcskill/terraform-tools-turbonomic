#!/usr/bin/env bash
MODULE_DIR=$(cd ".."; pwd -P)

kubectl create -f "${MODULE_DIR}/scripts/storageclass-ibmc-vpc-block-10iops-mzr.yaml"