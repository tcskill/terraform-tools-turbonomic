#!/usr/bin/env bash

CHARTS_DIR=$(cd $(dirname $0)/../charts; pwd -P)

STOR_NAME="$1"
ISVPC="$2"

if [[ "${ISVPC}" = 1 ]]; then
echo "creating storage class for VPC"
cat > "${CHARTS_DIR}/customStorageClass.yaml" << EOL
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${STOR_NAME}
  selfLink: /apis/storage.k8s.io/v1/storageclasses/${STOR_NAME}
  uid: 2b83a568-5455-47fa-b24a-7aac6831c1bb
  resourceVersion: '132899'
  creationTimestamp: '2021-08-19T18:53:11Z'
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
    app: ibm-vpc-block-csi-driver
    razee/force-apply: 'true'
  annotations:
    armada-service: addon-vpc-block-csi-driver
    kubectl.kubernetes.io/last-applied-configuration: >
      {"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{"armada-service":"addon-vpc-block-csi-driver","razee.io/build-url":"https://travis.ibm.com/alchemy-containers/addon-vpc-block-csi-driver/builds/53951456","razee.io/source-url":"https://github.ibm.com/alchemy-containers/addon-vpc-block-csi-driver/commit/8f3f02558d7b09651e20b77799371a9a8f356645","storageclass.beta.kubernetes.io/is-default-class":"false","version":"3.0.1_738"},"labels":{"addonmanager.kubernetes.io/mode":"Reconcile","app":"ibm-vpc-block-csi-driver","razee/force-apply":"true"},"name":"ibmc-vpc-block-10iops-tier"},"parameters":{"billingType":"hourly","classVersion":"1","csi.storage.k8s.io/fstype":"ext4","encrypted":"false","encryptionKey":"","profile":"10iops-tier","region":"","resourceGroup":"","sizeRange":"[10-2000]GiB","tags":"","zone":""},"provisioner":"vpc.block.csi.ibm.io","reclaimPolicy":"Delete"}
    razee.io/build-url: >-
      https://travis.ibm.com/alchemy-containers/addon-vpc-block-csi-driver/builds/53951456
    razee.io/source-url: >-
      https://github.ibm.com/alchemy-containers/addon-vpc-block-csi-driver/commit/8f3f02558d7b09651e20b77799371a9a8f356645
    storageclass.beta.kubernetes.io/is-default-class: 'false'
    version: 3.0.1_738
  managedFields:
    - manager: Mozilla
      operation: Update
      apiVersion: storage.k8s.io/v1
      time: '2021-08-19T18:53:11Z'
      fieldsType: FieldsV1
      fieldsV1:
        'f:metadata':
          'f:annotations':
            .: {}
            'f:armada-service': {}
            'f:kubectl.kubernetes.io/last-applied-configuration': {}
            'f:razee.io/build-url': {}
            'f:razee.io/source-url': {}
            'f:storageclass.beta.kubernetes.io/is-default-class': {}
            'f:version': {}
          'f:labels':
            .: {}
            'f:addonmanager.kubernetes.io/mode': {}
            'f:app': {}
            'f:razee/force-apply': {}
        'f:parameters':
          'f:zone': {}
          'f:billingType': {}
          'f:region': {}
          'f:sizeRange': {}
          'f:encryptionKey': {}
          'f:csi.storage.k8s.io/fstype': {}
          'f:tags': {}
          .: {}
          'f:encrypted': {}
          'f:classVersion': {}
          'f:profile': {}
          'f:resourceGroup': {}
        'f:provisioner': {}
        'f:reclaimPolicy': {}
        'f:volumeBindingMode': {}
provisioner: vpc.block.csi.ibm.io
parameters:
  classVersion: '1'
  csi.storage.k8s.io/fstype: ext4
  encrypted: 'false'
  profile: 10iops-tier
  zone: ''
  resourceGroup: ''
  region: ''
  billingType: hourly
  tags: ''
  sizeRange: '[10-2000]GiB'
  encryptionKey: ''
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOL
else
echo "creating storage class for Classic Cluster"
cat > "${CHARTS_DIR}/customStorageClass.yaml" << EOL
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${STOR_NAME}
  selfLink: /apis/storage.k8s.io/v1/storageclasses/${STOR_NAME}
  uid: 95f79f63-65a2-4529-a597-9a113c833436
  resourceVersion: '15951408'
  labels:
    app: ibmcloud-block-storage-plugin
    chart: ibmcloud-block-storage-plugin-1.7.1
    heritage: Helm
    release: release-name
  annotations:
    storageclass.kubernetes.io/is-default-class: 'false'
  managedFields:
    - manager: Mozilla
      operation: Update
      apiVersion: storage.k8s.io/v1
      fieldsType: FieldsV1
      fieldsV1:
        'f:allowVolumeExpansion': {}
        'f:metadata':
          'f:annotations':
            .: {}
            'f:storageclass.kubernetes.io/is-default-class': {}
          'f:labels':
            .: {}
            'f:app': {}
            'f:chart': {}
            'f:heritage': {}
            'f:release': {}
        'f:parameters':
          .: {}
          'f:billingType': {}
          'f:classVersion': {}
          'f:fsType': {}
          'f:iopsPerGB': {}
          'f:sizeRange': {}
          'f:type': {}
        'f:provisioner': {}
        'f:reclaimPolicy': {}
        'f:volumeBindingMode': {}
provisioner: ibm.io/ibmc-block
parameters:
  billingType: hourly
  classVersion: '2'
  fsType: ext4
  iopsPerGB: '10'
  sizeRange: '[20-4000]Gi'
  type: Endurance
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
EOL
fi

kubectl create -f "${CHARTS_DIR}/customStorageClass.yaml"
