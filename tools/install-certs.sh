#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh
source ${ROOT}/utils.sh

KUBE_CERTS_REMOTE_DIR="/etc/kubernetes/ssl"
KUBE_CERTS_TEMP_REMOTE_DIR="${KUBE_TEMP}/certs"

for ADDRESS in ${MACHINES}; do
    if [[ ! ${ADDRESS} =~ ${address_pattern} ]]; then
        continue
    fi
    echo "Install certs to: ${ADDRESS}"
    TARGET="${NODE_USERNAME}@${ADDRESS}"
    kube-ssh "${TARGET}" "mkdir -p ${KUBE_TEMP}/certs"
    kube-ssh "${TARGET}" "sudo mkdir -p ${KUBE_CERTS_REMOTE_DIR}"
    kube-scp "${TARGET}" "${LOCAL_CERTS_DIR}/ca.crt" \
                         "${KUBE_CERTS_TEMP_REMOTE_DIR}/ca.crt"
    kube-ssh "${TARGET}" "sudo cp ${KUBE_CERTS_TEMP_REMOTE_DIR}/ca.crt ${KUBE_CERTS_REMOTE_DIR}/ca.crt"
    kube-scp "${TARGET}" "${LOCAL_CERTS_DIR}/ca.key" \
                         "${KUBE_CERTS_TEMP_REMOTE_DIR}/ca.key"
    kube-ssh "${TARGET}" "sudo cp ${KUBE_CERTS_TEMP_REMOTE_DIR}/ca.key ${KUBE_CERTS_REMOTE_DIR}/ca.key"
    kube-scp "${TARGET}" "${LOCAL_CERTS_DIR}/apiserver-key.pem" \
                         "${KUBE_CERTS_TEMP_REMOTE_DIR}/apiserver-key.pem"
    kube-ssh "${TARGET}" "sudo cp ${KUBE_CERTS_TEMP_REMOTE_DIR}/apiserver-key.pem ${KUBE_CERTS_REMOTE_DIR}/apiserver-key.pem"
    kube-scp "${TARGET}" "${LOCAL_CERTS_DIR}/apiserver.pem" \
                         "${KUBE_CERTS_TEMP_REMOTE_DIR}/apiserver.pem"
    kube-ssh "${TARGET}" "sudo cp ${KUBE_CERTS_TEMP_REMOTE_DIR}/apiserver.pem ${KUBE_CERTS_REMOTE_DIR}/apiserver.pem"
    kube-scp "${TARGET}" "${LOCAL_CERTS_DIR}/worker-key-${ADDRESS}.pem" \
                         "${KUBE_CERTS_TEMP_REMOTE_DIR}/worker-key.pem"
    kube-ssh "${TARGET}" "sudo cp ${KUBE_CERTS_TEMP_REMOTE_DIR}/worker-key.pem ${KUBE_CERTS_REMOTE_DIR}/worker-key.pem"
    kube-scp "${TARGET}" "${LOCAL_CERTS_DIR}/worker-${ADDRESS}.pem" \
                         "${KUBE_CERTS_TEMP_REMOTE_DIR}/worker.pem"
    kube-ssh "${TARGET}" "sudo cp ${KUBE_CERTS_TEMP_REMOTE_DIR}/worker.pem ${KUBE_CERTS_REMOTE_DIR}/worker.pem"
done
