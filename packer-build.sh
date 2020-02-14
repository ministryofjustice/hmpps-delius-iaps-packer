#!/bin/bash
docker run --rm \
  -e BRANCH_NAME=${BRANCH_NAME} \
    -e TARGET_ENV=${TARGET_ENV} \
    -e ARTIFACT_BUCKET=${ARTIFACT_BUCKET} \
    -e ZAIZI_BUCKET=${ZAIZI_BUCKET} \
    -v `pwd`:/home/tools/data \
    mojdigitalstudio/hmpps-packer-builder \
    bash -c "USER=`whoami` packer build -var github_access_token=${GITHUB_ACCESS_TOKEN} ${FILENAME}"
