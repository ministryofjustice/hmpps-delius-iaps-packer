#!/bin/bash

echo "BRANCH_NAME: ${BRANCH_NAME}"
echo "TARGET_ENV: ${TARGET_ENV}"
echo "ARTIFACT_BUCKET: ${ARTIFACT_BUCKET}"
echo "ZAIZI_BUCKET: ${ZAIZI_BUCKET}"
echo "GITHUB_ACCESS_TOKEN: ${GITHUB_ACCESS_TOKEN}"
echo "FILENAME: ${FILENAME}"

echo '----------------------------------'
echo 'Verifying Packer Windows AMI'
echo '----------------------------------'

USER=`whoami` packer validate -var github_access_token=${GITHUB_ACCESS_TOKEN} ${FILENAME}
