#!/bin/bash
set +x

echo '----------------------------------'
echo 'Building Packer Windows AMI'
echo '----------------------------------'
echo "BRANCH_NAME: ${BRANCH_NAME}"
echo "TARGET_ENV: ${TARGET_ENV}"
echo "ARTIFACT_BUCKET: ${ARTIFACT_BUCKET}"
echo "ZAIZI_BUCKET: ${ZAIZI_BUCKET}"
echo "WIN_ADMIN_PASS: ${WIN_ADMIN_PASS}"
echo "WIN_JENKINS_PASS: ${WIN_JENKINS_PASS}"
echo "AWS_REGION: ${AWS_REGION}"
echo "FILENAME: ${FILENAME}"

docker run --rm \
    -e BRANCH_NAME=${BRANCH_NAME} \
    -e TARGET_ENV=${TARGET_ENV} \
    -e ARTIFACT_BUCKET=${ARTIFACT_BUCKET} \
    -e ZAIZI_BUCKET=${ZAIZI_BUCKET} \
    -e WIN_ADMIN_PASS=${WIN_ADMIN_PASS} \
    -e WIN_JENKINS_PASS=${WIN_JENKINS_PASS} \
    -e AWS_REGION=${AWS_REGION} \
    -v `pwd`:/home/tools/data \
    mojdigitalstudio/hmpps-packer-builder \
    bash -c "USER=`whoami` packer build -debug ${FILENAME}"
