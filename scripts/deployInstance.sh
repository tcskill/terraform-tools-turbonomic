#!/usr/bin/env bash

NAMESPACE="$1"
PROBES="$2"
STOR_NAME="$3"
SANAME="$4"
CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$5" == "destroy" ]]; then
    echo "removing xl-release..."
    kubectl delete Xl xl-release -n ${NAMESPACE} >/dev/null 2>&1 &

    # In the case that Kubernetes hangs on deleting the XL instance, set the finalizer to null which will force delete the XL instance this is a known issue with latest release
    resp=$(kubectl get xl/xl-release -n ${NAMESPACE} --no-headers 2>/dev/null | wc -l)

    if [[ "${resp}" != "0" ]]; then
        echo "patching instance..."
        kubectl patch xl/xl-release -p '{"metadata":{"finalizers":[]}}' --type=merge -n ${NAMESPACE} 2>/dev/null
    fi

else 
    cat > "${CHARTS_DIR}/xl-release.yaml" << EOL
apiVersion: charts.helm.k8s.io/v1
kind: Xl
metadata:
  name: xl-release
spec:
  global:
    repository: turbonomic
    tag: 8.3.4
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
