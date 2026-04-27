#!/usr/bin/env bash

echo "Creating secrets as required"
echo

COCO_SECRETS_DIR="${HOME}/.coco-pattern"
KBS_PRIVATE_KEY="${COCO_SECRETS_DIR}/kbsPrivateKey"
KBS_PUBLIC_KEY="${COCO_SECRETS_DIR}/kbsPublicKey"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${HOME}/values-secret-coco-pattern.yaml"

mkdir -p ${COCO_SECRETS_DIR}

SSH_KEY_FILE="${COCO_SECRETS_DIR}/id_rsa"

if [ "${COCO_ENABLE_SSH_DEBUG:-false}" = "true" ]; then
	if [ ! -f "${SSH_KEY_FILE}" ]; then
		echo "Creating ssh keys for podvm debug access"
		rm -f "${SSH_KEY_FILE}.pub"
		ssh-keygen -f "${SSH_KEY_FILE}" -N ""
	fi
fi

if [ ! -f "${KBS_PRIVATE_KEY}" ]; then
	echo "Creating kbs keys"
	rm -f "${KBS_PUBLIC_KEY}"
	openssl genpkey -algorithm ed25519 >${KBS_PRIVATE_KEY}
	openssl pkey -in "${KBS_PRIVATE_KEY}" -pubout -out "${KBS_PUBLIC_KEY}"
fi

## PCCS secrets for bare metal Intel TDX deployments
PCCS_PRIVATE_KEY="${COCO_SECRETS_DIR}/pccs_private.pem"
PCCS_CERTIFICATE="${COCO_SECRETS_DIR}/pccs_certificate.pem"
PCCS_USER_TOKEN_FILE="${COCO_SECRETS_DIR}/pccs_user_token"
PCCS_ADMIN_TOKEN_FILE="${COCO_SECRETS_DIR}/pccs_admin_token"

if [ ! -f "${PCCS_PRIVATE_KEY}" ]; then
	echo "Creating PCCS TLS certificate"
	openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
		-keyout "${PCCS_PRIVATE_KEY}" \
		-out "${PCCS_CERTIFICATE}" \
		-subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=pccs-service.intel-dcap.svc.cluster.local"
fi

if [ ! -f "${PCCS_USER_TOKEN_FILE}" ]; then
	echo "Creating PCCS user token"
	echo "usertoken" > "${PCCS_USER_TOKEN_FILE}"
fi
tr -d '\n' < "${PCCS_USER_TOKEN_FILE}" | sha512sum | tr -d '[:space:]-' > "${COCO_SECRETS_DIR}/pccs_user_token_hash"

if [ ! -f "${PCCS_ADMIN_TOKEN_FILE}" ]; then
	echo "Creating PCCS admin token"
	echo "admintoken" > "${PCCS_ADMIN_TOKEN_FILE}"
fi
tr -d '\n' < "${PCCS_ADMIN_TOKEN_FILE}" | sha512sum | tr -d '[:space:]-' > "${COCO_SECRETS_DIR}/pccs_admin_token_hash"

## Copy a sample values file if this stuff doesn't exist

if [ ! -f "${VALUES_FILE}" ]; then
	echo "No values file was found copying template.. please review before deploying"
	cp "${SCRIPT_DIR}/../values-secret.yaml.template" "${VALUES_FILE}"
fi
