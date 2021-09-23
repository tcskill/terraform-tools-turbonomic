#!/usr/bin/env bash

STOR_NAME="$1"

kubectl delete StorageClass ${STOR_NAME}
