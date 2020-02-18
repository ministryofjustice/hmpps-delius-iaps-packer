#!/bin/bash

echo '-------------------------------------------'
echo 'Building Packer AMI inside docker container'
echo '-------------------------------------------'

echo "BRANCH_NAME: ${BRANCH_NAME}"
echo "TARGET_ENV: ${TARGET_ENV}"
echo "ARTIFACT_BUCKET: ${ARTIFACT_BUCKET}"
echo "ZAIZI_BUCKET: ${ZAIZI_BUCKET}"
echo "GITHUB_ACCESS_TOKEN: ${GITHUB_ACCESS_TOKEN}"
echo "FILENAME: ${FILENAME}"

USER=`whoami` packer build -var github_access_token=${GITHUB_ACCESS_TOKEN} ${FILENAME}
