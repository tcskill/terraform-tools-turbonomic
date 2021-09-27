#!/usr/bin/env bash

NAMESPACE="$1"
PROBES="$2"
STOR_NAME="$3"
SANAME="$4"
CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$5" == "destroy" ]]; then
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
    serviceAccountName:  ${SANAME}

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

    if [[ "${PROBES}" =~ aws ]]; then
      echo "adding aws probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL
  
  aws:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ azure ]]; then
      echo "adding azure probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL
  
  azure:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ prometheus ]]; then
      echo "adding prometheus probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL
  
  prometheus:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ servicenow ]]; then
      echo "adding servicenow probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL
  
  servicenow:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ tomcat ]]; then
      echo "adding tomcat probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL
  
  tomcat:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ jvm ]]; then
      echo "adding jvm probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL
  
  jvm:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ websphere ]]; then
      echo "adding websphere probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL
  
  websphere:
    enabled: true
EOL
    fi

    if [[ "${PROBES}" =~ weblogic ]]; then
      echo "adding weblogic probe..."
      cat >> ${CHARTS_DIR}/xl-release.yaml << EOL
  
  weblogic:
    enabled: true
EOL
    fi
    # deploy the release
    kubectl apply -f "${CHARTS_DIR}/xl-release.yaml" -n ${NAMESPACE}

fi
