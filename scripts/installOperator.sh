#!/usr/bin/env bash

SANAME="$1"
NAMESPACE="$2"
CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

if [[ "$3" == "destroy" ]]; then
    echo "removing chart extension..."
    # remove the the operator and chart extensions
    kubectl delete Deployment t8c-operator -n ${NAMESPACE}
    kubectl delete CustomResourceDefinition xls.charts.helm.k8s.io
else 
    # deploy the chart extensions needed
    #kubectl create -f "${CHARTS_DIR}/charts_v1alpha1_xl_crd.yaml"
    kubectl create -f "${CHARTS_DIR}/charts.helm.k8s.io_xls.yaml"

    # create the yaml for operator deployment and deploy it

cat > "${CHARTS_DIR}/operator.yaml" << EOL
apiVersion: apps/v1
kind: Deployment
metadata:
  name: t8c-operator
  labels:
    app.kubernetes.io/name: t8c-operator
    app.kubernetes.io/instance: t8c-operator
    app.kubernetes.io/managed-by: operator-life

spec:
  replicas: 1
  selector:
    matchLabels:
      name: t8c-operator
  template:
    metadata:
      labels:
        name: t8c-operator
    spec:
      serviceAccountName: ${SANAME}
      containers:
      - name: t8c-operator
        image: turbonomic/t8c-operator:42.0
        imagePullPolicy: Always
        env:
        - name: WATCH_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: OPERATOR_NAME
          value: "t8c-operator"
        securityContext:
          readOnlyRootFilesystem: true
          capabilities:
            drop:
              - ALL
        volumeMounts:
        - mountPath: /tmp
          name: operator-tmpfs0
      volumes:
      - name: operator-tmpfs0
        emptyDir: {}
EOL
    kubectl create -f "${CHARTS_DIR}/operator.yaml" -n ${NAMESPACE}
fi





