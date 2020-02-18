#!/bin/bash
set +x

echo '----------------------------------------------------'
echo 'Building Packer Windows AMI inside docker container'
echo '----------------------------------------------------'
echo "BRANCH_NAME: ${BRANCH_NAME}"
echo "TARGET_ENV: ${TARGET_ENV}"
echo "ARTIFACT_BUCKET: ${ARTIFACT_BUCKET}"
echo "ZAIZI_BUCKET: ${ZAIZI_BUCKET}"
echo "WIN_ADMIN_PASS: ${WIN_ADMIN_PASS}"
echo "WIN_JENKINS_PASS: ${WIN_JENKINS_PASS}"
echo "AWS_REGION: ${AWS_REGION}"
echo "FILENAME: ${FILENAME}"

USER=`whoami` packer build -debug ${FILENAME}
