#!/bin/bash
set +x

function set_branch_name() {
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
}

function set_git_latest_master_tag() {
    echo '----------------------------------------------'
    echo "Setting IMAGE_TAG_VERSION"
    echo '----------------------------------------------'
    export IMAGE_TAG_VERSION=$(curl -s https://api.github.com/repos/ministryofjustice/hmpps-delius-iaps-packer/tags | jq -r '.[0].name')
    echo "Set IMAGE_TAG_VERSION to '$IMAGE_TAG_VERSION'"
}


function set_tag_version() {
    set_branch_name
    if [ "${BRANCH_NAME}" == "master" ]; then
        echo "Branch name is '${BRANCH_NAME}' so getting latest tag"
        set_git_latest_master_tag
    else
        echo "Branch name is '${BRANCH_NAME}' so setting tag to 0.0.0"
        IMAGE_TAG_VERSION='0.0.0'
    fi
}



function verify_image() {
    # 
    echo '----------------------------------------------'
    echo "Running packer validate ${1}"
    echo '----------------------------------------------'
    USER=`whoami` packer validate -var github_access_token=${GITHUB_ACCESS_TOKEN} $1

    RESULT=$?
    echo '----------------------------------------------'
    echo "Verify return code was: $RESULT"
    echo '----------------------------------------------'
    return $RESULT
}

function build_image() {
    echo '----------------------------------------------'
    echo "Running packer build for Linux Image ${1}"
    echo '----------------------------------------------'
   
    USER=`whoami` packer build -var github_access_token=${GITHUB_ACCESS_TOKEN} ${1}
    RESULT=$?

    echo '----------------------------------------------'
    echo "Build Image return code was: $RESULT"
    echo '----------------------------------------------'
    return $RESULT
}

function build_windows_image() {
    echo '----------------------------------------------'
    echo "Running packer build for Windows Image ${1}"
    echo '----------------------------------------------'
  
    USER=`whoami` packer build $1
    RESULT=$?

    echo '----------------------------------------------'
    echo "Build Image return code was: $RESULT"
    echo '----------------------------------------------'
    return $RESULT
}

function print_env() {
    echo '----------------------------------------------'
    echo "Get Environment Variables"
    echo '----------------------------------------------'
    echo "ARTIFACT_BUCKET    : ${ARTIFACT_BUCKET}"
    echo "AWS_REGION         : ${AWS_REGION}"
    echo "BRANCH_NAME        : ${BRANCH_NAME}"
    echo "GITHUB_ACCESS_TOKEN: ${GITHUB_ACCESS_TOKEN}"
    echo "IMAGE_TAG_VERSION  : ${IMAGE_TAG_VERSION}"
    echo "TARGET_ENV         : ${TARGET_ENV}"
    echo "WIN_ADMIN_PASS     : ${WIN_ADMIN_PASS}"
    echo "WIN_JENKINS_PASS   : ${WIN_JENKINS_PASS}"
    echo "ZAIZI_BUCKET       : ${ZAIZI_BUCKET}"
}


function set_environment_variables() {
    echo '----------------------------------------------'
    echo "Setting Environment Variables"
    echo '----------------------------------------------'
    
    echo 'Setting ARTIFACT_BUCKET'
    ARTIFACT_BUCKET='tf-eu-west-2-hmpps-eng-dev-config-s3bucket'

    echo 'Setting ZAIZI_BUCKET'
    ZAIZI_BUCKET='tf-eu-west-2-hmpps-eng-dev-artefacts-s3bucket'

    echo 'Setting AWS_REGION'
    AWS_REGION="eu-west-2"

    echo 'Setting TARGET_ENV'
    TARGET_ENV='dev'

    echo "Setting GITHUB_ACCESS_TOKEN from SSM ParameterStore key '/jenkins/github/accesstoken'"
    GITHUB_ACCESS_TOKEN=$(aws ssm get-parameter --name /jenkins/github/accesstoken --region ${AWS_REGION} --with-decryption --output text --query Parameter.Value)

    echo "Setting WIN_ADMIN_PASS from SSM ParameterStore key '/${TARGET_ENV}/jenkins/windows/agent/admin/password'"
    WIN_ADMIN_PASS=$(aws ssm get-parameters --names /${TARGET_ENV}/jenkins/windows/agent/admin/password --region ${AWS_REGION} --with-decryption | jq -r '.Parameters[0].Value')

    echo "Setting WIN_JENKINS_PASS from SSM ParameterStore key '/${TARGET_ENV}/jenkins/windows/agent/jenkins/password'"
    WIN_JENKINS_PASS=$(aws ssm get-parameters --names /${TARGET_ENV}/jenkins/windows/agent/jenkins/password --region ${AWS_REGION} --with-decryption | jq -r '.Parameters[0].Value')       

    echo 'Setting IMAGE_TAG_VERSION'
    set_tag_version

    print_env
}


clear

set_environment_variables

verify_image "./iaps.json"

build_windows_image  "./iaps.json"

