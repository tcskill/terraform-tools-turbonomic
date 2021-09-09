#!/usr/bin/env bash

NAMESPACE="$1"
PROBES="$2"
STOR_NAME="$3"
CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$4" == "destroy" ]]; then
    echo "removing xl-release..."
    # remove the the release
    kubectl delete -f "${CHARTS_DIR}/xl-release.yaml" -n ${NAMESPACE}
else 
    cat > "${CHARTS_DIR}/xl-release.yaml" << EOL
apiVersion: charts.helm.k8s.io/v1
kind: Xl
metadata:
  name: xl-release
spec:
  global:
    repository: turbonomic
    tag: 8.2.3
    externalArangoDBName: arango.turbo.svc.cluster.local
    storageClassName: ${STOR_NAME}

EOL


    if [[ "${PROBES}" =~ kubeturbo ]]; then
      echo "adding kubeturbo probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL

  kubeturbo:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ openshiftingress ]]; then
      echo "adding openshiftingress probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL
  
  openshiftingress:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ instana ]]; then
      echo "adding instana probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL
  
  instana:
    enabled: true
EOL
    fi
    # deploy the release
    kubectl apply -f "${CHARTS_DIR}/xl-release.yaml" -n ${NAMESPACE}

fi
