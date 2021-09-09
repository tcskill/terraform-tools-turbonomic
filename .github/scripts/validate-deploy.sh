#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

if [[ -f .kubeconfig ]]; then
  KUBECONFIG=$(cat .kubeconfig)
else
  KUBECONFIG="${PWD}/.kube/config"
fi
export KUBECONFIG

#wait for pods to start
sleep 5m

kubectl rollout status deployment/rsyslog
if [[ "$?" -ne 0 ]]; then
    echo "turbo deployment failed with exit code $?"
    exit 1
fi
