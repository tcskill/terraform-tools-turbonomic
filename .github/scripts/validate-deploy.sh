#!/usr/bin/env bash

KUBECONFIG=$(cat ./kubeconfig)
NAMESPACE=$(cat ./namespace)

#wait for the deployments to finish
sleep 4m

kubectl rollout status deployment/rsyslog -n ${NAMESPACE}
if [[ $? -ne 0 ]]; then
    echo "turbo deployment failed with exit code $? in namespace ${NAMESPACE}"
    exit 1
fi
