#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_TEMPLATE=${LOCAL_MANIFESTS_DIR}/kube-controller-manager.yaml

CA=$(cat ${LOCAL_ASSETS_DIR}/certs/kubernetes/ca.crt | base64)
SA_KEY=$(cat ${LOCAL_ASSETS_DIR}/certs/kubernetes/sa.key | base64)

cat << EOF > $KUBE_TEMPLATE
---
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: kube-controller-manager
  namespace: kube-system
spec:
  minAvailable: 1
  selector:
    matchLabels:
      tier: control-plane
      k8s-app: kube-controller-manager
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: remora:kube-controller-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-controller-manager
subjects:
- kind: ServiceAccount
  name: kube-controller-manager
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-controller-manager
  namespace: kube-system
---
apiVersion: v1
data:
  ca.crt: ${CA}
  service-account.key: ${SA_KEY}
kind: Secret
metadata:
  name: kube-controller-manager
  namespace: kube-system
type: Opaque
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: kube-controller-manager
  namespace: kube-system
  labels:
    tier: control-plane
    k8s-app: kube-controller-manager
spec:
  replicas: 2
  template:
    metadata:
      labels:
        tier: control-plane
        k8s-app: kube-controller-manager
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: tier
                  operator: In
                  values:
                  - control-plane
                - key: k8s-app
                  operator: In
                  values:
                  - kube-controller-manager
              topologyKey: kubernetes.io/hostname
      containers:
      - name: kube-controller-manager
        image: ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
        command:
        - ./hyperkube
        - controller-manager
        - --allocate-node-cidrs=true
        - --cloud-provider=
        - --cluster-cidr=${KUBE_CLUSTER_CIDR}
        - --node-cidr-mask-size=${KUBE_NODE_CIDR_MASK_SIZE}
        - --configure-cloud-routes=false # FIXME:(yuanying) Change true if kubenet is used.
        - --leader-elect=true
        - --root-ca-file=/etc/kubernetes/secrets/ca.crt
        - --service-account-private-key-file=/etc/kubernetes/secrets/service-account.key
        - --cloud-provider=${KUBE_CLOUD_PROVIDER:-""}
        - --cloud-config=${KUBE_CLOUD_CONFIG:-""}
        - --v=${KUBE_LOG_LEVEL:-"2"}
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10252  # Note: Using default port. Update if --port option is set differently.
          initialDelaySeconds: 15
          timeoutSeconds: 15
        volumeMounts:
        - name: secrets
          mountPath: /etc/kubernetes/secrets
          readOnly: true
        - name: ssl-host
          mountPath: /etc/ssl/certs
          readOnly: true
      nodeSelector:
        node-role.kubernetes.io/master: ""
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
      serviceAccountName: kube-controller-manager
      tolerations:
      - key: CriticalAddonsOnly
        operator: Exists
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      volumes:
      - name: secrets
        secret:
          secretName: kube-controller-manager
      - name: ssl-host
        hostPath:
          path: /usr/share/ca-certificates
      dnsPolicy: Default # Don't use cluster DNS.

EOF
