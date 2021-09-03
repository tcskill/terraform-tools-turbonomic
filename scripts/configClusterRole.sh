#!/usr/bin/env bash

if [[ -z "${TMP_DIR}" ]]; then
    TMP_DIR=".tmp"
fi
mkdir -p "${TMP_DIR}"

SANAME="$1"
NAMESPACE="$2"

CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$3" == "destroy" ]]; then
    echo "removing cluster role and binding..."
    kubectl delete -f "${TMP_DIR}/cluster_role_binding.yaml"
    kubectl delete -f "${CHARTS_DIR}/cluster_role.yaml"
else 
    kubectl create -f "${CHARTS_DIR}/cluster_role.yaml"
#build cluster role binding
cat > "${TMP_DIR}/cluster_role_binding.yaml" << EOL
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: t8c-operator
subjects:
- kind: ServiceAccount
  name: ${SANAME}
  namespace: ${NAMESPACE}
roleRef:
  kind: ClusterRole
  name: t8c-operator
  apiGroup: rbac.authorization.k8s.io
EOL    
    kubectl create -f "${TMP_DIR}/cluster_role_binding.yaml"
fi