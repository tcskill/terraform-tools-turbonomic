#!/usr/bin/env bash

CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

kubectl delete -f "${CHARTS_DIR}/customStorageClass.yaml"
