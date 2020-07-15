#!/bin/bash
set +x

function set_branch_name() {
    if [ "$CODEBUILD" == "true" ]; then
        BRANCH_NAME=$CODEBUILD_GIT_BRANCH
    else 
        BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    fi
    echo "BRANCH_NAME set to '$BRANCH_NAME'"
}

function set_git_latest_master_tag() {
    echo '----------------------------------------------'
    echo "Setting IMAGE_TAG_VERSION"
    echo '----------------------------------------------'
    IMAGE_TAG_VERSION=$(git describe --tags --exact-match)
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
    echo '----------------------------------------------'
    echo "Running packer validate ${1}"
    echo '----------------------------------------------'
    USER=`whoami` packer validate $1

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
   
    USER=`whoami` packer build ${1}
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
    env | sort
}


function set_environment_variables() {
    echo '----------------------------------------------'
    echo "Setting Environment Variables"
    echo '----------------------------------------------'
    
    echo 'Setting IMAGE_TAG_VERSION'
    set_tag_version

    print_env
}

# set environment
set_environment_variables

echo '-------------------------------------------'
echo 'Verifying Packer AMI'
echo '-------------------------------------------'
verify_image ${PACKER_FILENAME}

echo '----------------------------------------------------'
echo 'Building Packer AMI'
echo '----------------------------------------------------'
build_windows_image  ${PACKER_FILENAME}

