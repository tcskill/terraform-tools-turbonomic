#!/usr/bin/env bash

SANAME="$1"
NAMESPACE="$2"

CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$3" == "destroy" ]]; then
    echo "removing cluster role and binding..."
    kubectl delete ClusterRoleBinding ${SANAME}
    kubectl delete ClusterRole ${SANAME}
    ##kubectl delete -f "${CHARTS_DIR}/cluster_role.yaml"
else 
##kubectl create -f "${CHARTS_DIR}/cluster_role.yaml"
#build cluster role
cat > "${CHARTS_DIR}/cluster_role.yaml" << EOL
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: null
  name: ${SANAME}
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - endpoints
  - events
  - persistentvolumeclaims
  - pods
  - secrets
  - serviceaccounts
  - services
  verbs:
  - '*'
- apiGroups:
  - apps
  resources:
  - daemonsets
  - deployments
  - statefulsets
  - replicasets
  verbs:
  - '*'
- apiGroups:
  - apps
  resources:
  - deployments/finalizers
  verbs:
  - update
- apiGroups:
  - extensions
  resources:
  - deployments
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
- apiGroups:
  - policy
  resources:
  - podsecuritypolicies
  - poddisruptionbudgets
  verbs:
  - '*'
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - clusterrolebindings
  - clusterroles
  - rolebindings
  - roles
  verbs:
  - '*'
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - '*'
- apiGroups:
  - monitoring.coreos.com
  resources:
  - servicemonitors
  verbs:
  - get
  - create
- apiGroups:
  - charts.helm.k8s.io
  resources:
  - '*'
  verbs:
  - '*'
- apiGroups:
  - networking.istio.io
  resources:
  - gateways
  - virtualservices
  verbs:
  - '*'
- apiGroups:
  - cert-manager.io
  resources:
  - certificates
  verbs:
  - '*'
- apiGroups:
    - route.openshift.io
  resources:
    - routes
    - routes/custom-host
  verbs:
    - '*'
- apiGroups:
    - security.openshift.io
  resourceNames:
    - restricted
  resources:
    - securitycontextconstraints
  verbs:
    - use
EOL
#build cluster role binding
cat > "${CHARTS_DIR}/cluster_role_binding.yaml" << EOL
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ${SANAME}
subjects:
- kind: ServiceAccount
  name: ${SANAME}
  namespace: ${NAMESPACE}
roleRef:
  kind: ClusterRole
  name: ${SANAME}
  apiGroup: rbac.authorization.k8s.io
EOL
    kubectl create -f "${CHARTS_DIR}/cluster_role.yaml"
    kubectl create -f "${CHARTS_DIR}/cluster_role_binding.yaml"
fi
