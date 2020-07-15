#!/bin/bash

echo "BRANCH_NAME: ${BRANCH_NAME}"
echo "IMAGE_TAG_VERSION: ${IMAGE_TAG_VERSION}"
echo "TARGET_ENV: ${TARGET_ENV}"
echo "ARTIFACT_BUCKET: ${ARTIFACT_BUCKET}"
echo "ZAIZI_BUCKET: ${ZAIZI_BUCKET}"
echo "GITHUB_ACCESS_TOKEN: ${GITHUB_ACCESS_TOKEN}"
echo "FILENAME: ${FILENAME}"

echo '-------------------------------------------'
echo 'Verifying Packer AMI inside docker container'
echo '-------------------------------------------'

USER=`whoami` packer validate -var github_access_token=${GITHUB_ACCESS_TOKEN} ${FILENAME}