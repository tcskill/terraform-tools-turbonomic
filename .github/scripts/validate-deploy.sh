#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)

if [[ -f .kubeconfig ]]; then
  KUBECONFIG=$(cat .kubeconfig)
else
  KUBECONFIG="${PWD}/.kube/config"
fi
export KUBECONFIG

#wait for pods to start
wait 5m

NAMESPACE=$(echo "var.turbo_namespace" | terraform console -var-file variables.tf)


kubectl rollout status deployment/rsyslog -n ${NAMESPACE}
if [[ "$?" -ne 0 ]] then
    echo "turbo deployment failed in namespace: ${NAMESPACE} exit code $?"
    exit 1
fi
