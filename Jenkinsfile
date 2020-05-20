def set_branch_name() {
    return env.GIT_BRANCH.replace("/", "_")
}

def verify_image(filename) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh '''
        #!/usr/env/bin bash
        docker run --rm \
        -e BRANCH_NAME \
        -e TARGET_ENV \
        -e ARTIFACT_BUCKET \
        -e ZAIZI_BUCKET \
        -v `pwd`:/home/tools/data \
        mojdigitalstudio/hmpps-packer-builder \
        bash -c 'USER=`whoami` packer validate \
        -var \'github_access_token=`aws ssm get-parameter --name /jenkins/github/accesstoken --with-decryption --output text --query Parameter.Value --region eu-west-2`\' \
        ''' + filename + "'"
    }
}

def build_image(filename) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh '''
        #!/usr/env/bin bash       
        docker run --rm \
        -e BRANCH_NAME \
        -e TARGET_ENV \
        -e ARTIFACT_BUCKET \
        -e ZAIZI_BUCKET \
        -v `pwd`:/home/tools/data \
        mojdigitalstudio/hmpps-packer-builder \
        bash -c 'USER=`whoami` packer build \
        -var \'github_access_token=`aws ssm get-parameter --name /jenkins/github/accesstoken --with-decryption --output text --query Parameter.Value --region eu-west-2`\' \
        ''' + filename + "'"
    }
}

def build_win_image(filename) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        set +x
        docker run --rm \
        -e BRANCH_NAME \
        -e TARGET_ENV \
        -e ARTIFACT_BUCKET \
        -e ZAIZI_BUCKET \
        -e WIN_ADMIN_PASS="${env.WIN_ADMIN_PASS}" \
        -e WIN_JENKINS_PASS="${env.WIN_JENKINS_PASS}" \
        -e AWS_REGION \
        -v `pwd`:/home/tools/data \
        mojdigitalstudio/hmpps-packer-builder \
        bash -c 'USER=`whoami` packer build """ + filename + "'"
    }
}

def set_tag_version(branchname) {
    
    IMAGE_TAG_VERSION='0.0.0'
    echo "Setting IMAGE_TAG_VERSION to default value '${IMAGE_TAG_VERSION}'"
    if [[ branchname == 'master' ]]
    then
        GIT_TAG=$(git describe --tags --exact-match)
        echo "Using git tag '${GIT_TAG}' on master"
        IMAGE_TAG_VERSION=$GIT_TAG
    fi
    echo "IMAGE_TAG_VERSION = ${env.IMAGE_TAG_VERSION}'"
    return $IMAGE_TAG_VERSION
    
}


pipeline {
    agent { label "jenkins_slave"}

    options {
        ansiColor('xterm')
    }

    environment {
        // TARGET_ENV is set on the jenkins slave and defaults to dev
        AWS_REGION        = "eu-west-2"
        WIN_ADMIN_PASS    = '$(aws ssm get-parameters --names /${TARGET_ENV}/jenkins/windows/slave/admin/password --region ${AWS_REGION} --with-decryption | jq -r \'.Parameters[0].Value\')'
        BRANCH_NAME       = set_branch_name()
        IMAGE_TAG_VERSION = set_tag_version(BRANCH_NAME)
    }

    stages {
        stage('IAPS - Packer Verify') { 
            steps { 
                sh('echo $BRANCH_NAME')
                script {
                    verify_image('iaps.json')
                }
            }
        }

        stage('IAPS - Packer Build') { 
            steps { 
                sh('echo $BRANCH_NAME')
                sh('echo $IMAGE_TAG_VERSION')
                script {
                    build_win_image('iaps.json')
                }
            }
        }
    }
    post {
        always {
            deleteDir() /* clean up our workspace */
        }
    }
}
