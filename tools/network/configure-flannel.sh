#!/usr/bin/env bash

set -eu
export LC_ALL=C

# export NODE_IP=$1
KUBE_ADDONS_DIR=/etc/kubernetes/addons

KUBE_FLANNEL_TEMPLATE=${KUBE_ADDONS_DIR}/kube-cni-flannel.yaml
mkdir -p $(dirname $KUBE_FLANNEL_TEMPLATE)
cat << EOF > $KUBE_FLANNEL_TEMPLATE
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: flannel
rules:
  - apiGroups:
      - ""
    resources:
      - pods
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - nodes
    verbs:
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - nodes/status
    verbs:
      - patch
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: flannel
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: flannel
subjects:
- kind: ServiceAccount
  name: flannel
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: flannel
  namespace: kube-system
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: kube-flannel-cfg
  namespace: kube-system
  labels:
    tier: node
    app: flannel
data:
  cni-conf.json: |
    {
      "name": "cbr0",
      "type": "flannel",
      "delegate": {
        "isDefaultGateway": true
      }
    }
  net-conf.json: |
    {
      "Network": "${KUBE_CLUSTER_CIDR}",
      "Backend": {
        "Type": "${FLANNEL_BACKEND_TYPE}"
      }
    }
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: kube-flannel-ds
  namespace: kube-system
  labels:
    tier: node
    app: flannel
spec:
  template:
    metadata:
      labels:
        tier: node
        app: flannel
    spec:
      hostNetwork: true
      nodeSelector:
        beta.kubernetes.io/arch: amd64
      serviceAccountName: flannel
      containers:
      - name: kube-flannel
        image: ${FLANNEL_IMAGE_REPO}:${FLANNEL_VERSION}
        command: [ "/opt/bin/flanneld", "--ip-masq", "--kube-subnet-mgr" ]
        securityContext:
          privileged: true
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        volumeMounts:
        - name: run
          mountPath: /run
        - name: flannel-cfg
          mountPath: /etc/kube-flannel/
      - name: install-cni
        image: ${FLANNEL_IMAGE_REPO}:${FLANNEL_VERSION}
        command: [ "/bin/sh", "-c", "set -e -x; cp -f /etc/kube-flannel/cni-conf.json /etc/cni/net.d/10-flannel.conf; while true; do sleep 3600; done" ]
        volumeMounts:
        - name: cni
          mountPath: /etc/cni/net.d
        - name: flannel-cfg
          mountPath: /etc/kube-flannel/
      volumes:
        - name: run
          hostPath:
            path: /run
        - name: cni
          hostPath:
            path: /etc/cni/net.d
        - name: flannel-cfg
          configMap:
            name: kube-flannel-cfg
EOF

cat ${KUBE_FLANNEL_TEMPLATE} \
    | ${DOCKER_PATH} run \
        --net=host \
        --rm -i \
        --volume=/etc/kubernetes:/etc/kubernetes:ro \
        ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION} \
        /hyperkube kubectl --kubeconfig=/etc/kubernetes/admin.yaml apply -f -
