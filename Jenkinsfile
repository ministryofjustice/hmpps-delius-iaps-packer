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

def get_git_latest_master_tag() {
    git_branch = sh (
                    script: """docker run --rm \
                                    -v `pwd`:/home/tools/data \
                                    mojdigitalstudio/hmpps-packer-builder \
                                    bash -c 'git fetch --prune && git describe --tags --exact-match'""",
                    returnStdout: true
                 ).trim()    
    return git_branch
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

def set_tag_version() {
    branchName = set_branch_name()
    if (branchName == "master") {
        git_tag = get_git_latest_master_tag()
    }
    else {
        git_tag = '0.0.0'
    }
    return git_tag
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
        IMAGE_TAG_VERSION = set_tag_version()
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
