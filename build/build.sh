#!/bin/bash

IMAGE_NAME=${IMAGE_NAME:-test}
SECRET_FILE=${SECRET_FILE:-secrets}
DOCKER_BUILDKIT=${DOCKER_BUILDKIT:-1}
SHELLINABOX_PORT=${SHELLINABOX_PORT:-4200}
SHELLINABOX_USER=${SHELLINABOX_USER:-admin}


if [[ ! -f "${SECRET_FILE}" ]]; then
  echo "Secret file ${SECRET_FILE} not found!"
  exit 1
fi


echo "Building ${IMAGE_NAME}"
DOCKER_BUILDKIT=$DOCKER_BUILDKIT docker build \
  --secret id=shellinabox_password_user,src="${SECRET_FILE}" \
  --build-arg shellinabox_USER="${SHELLINABOX_USER}" \
  --build-arg shellinabox_PORT="${SHELLINABOX_PORT}" \
  -t "${IMAGE_NAME}" \
    .