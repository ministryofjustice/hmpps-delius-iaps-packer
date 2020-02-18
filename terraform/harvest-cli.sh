#!/bin/bash

mfa

awsume hmpps_eng

aws codepipeline list-pipelines > codepipeline/pipelines
aws codepipeline get-pipeline --name IAPS-AMI-Builder > codepipeline/pipeline_IAPS-AMI-Builder
aws codepipeline get-pipeline --name IAPS-AMI-Builder-Docker > codepipeline/pipeline_IAPS-AMI-Builder-Docker
aws codebuild list-projects > codebuild/codebuild_projects
aws codebuild list-source-credentials > codepipeline/sourcecredentials