#!/bin/bash

set -e

CERT_DIR="./certs"
mkdir -p "$CERT_DIR"

MINIKUBE_CA="$HOME/.minikube/ca.crt"
MINIKUBE_CA_KEY="$HOME/.minikube/ca.key"

create_user() {
    local USERNAME=$1
    local GROUP=$2

    echo "Creating user: $USERNAME (group: $GROUP)"

    openssl genrsa -out "${CERT_DIR}/${USERNAME}.key" 2048

    cat > "${CERT_DIR}/${USERNAME}.conf" <<EOF
[req]
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
CN = ${USERNAME}
O = ${GROUP}
EOF

    openssl req -new -key "${CERT_DIR}/${USERNAME}.key" \
        -out "${CERT_DIR}/${USERNAME}.csr" \
        -config "${CERT_DIR}/${USERNAME}.conf"

    openssl x509 -req -in "${CERT_DIR}/${USERNAME}.csr" \
        -CA "$MINIKUBE_CA" \
        -CAkey "$MINIKUBE_CA_KEY" \
        -CAcreateserial \
        -out "${CERT_DIR}/${USERNAME}.crt" \
        -days 365

    kubectl config set-credentials "${USERNAME}" \
        --client-certificate="${CERT_DIR}/${USERNAME}.crt" \
        --client-key="${CERT_DIR}/${USERNAME}.key" \
        --embed-certs=true

    kubectl config set-context "${USERNAME}-context" \
        --cluster=minikube \
        --namespace=default \
        --user="${USERNAME}"

    rm -f "${CERT_DIR}/${USERNAME}.conf"

    echo "User $USERNAME created successfully"
    echo "---"
}

create_user "alice-dev" "developers"
create_user "bob-view" "analysts"
create_user "charlie-sec" "security"
create_user "dave-devops" "devops"

echo ""
echo "All users created. Use 'kubectl config use-context <user>-context' to switch."