
resource "aws_iam_policy_attachment" "AWSCodePipelineServiceRole-eu-west-2-IAPS-AMI-Builder-policy-attachment" {
    name       = "AWSCodePipelineServiceRole-eu-west-2-IAPS-AMI-Builder-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/service-role/AWSCodePipelineServiceRole-eu-west-2-IAPS-AMI-Builder"
    groups     = []
    users      = []
    roles      = ["AWSCodePipelineServiceRole-eu-west-2-IAPS-AMI-Builder"]
}

resource "aws_iam_policy_attachment" "Codebuild-AssumeRoleInAccounts-policy-attachment" {
    name       = "Codebuild-AssumeRoleInAccounts-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/Codebuild-AssumeRoleInAccounts"
    groups     = []
    users      = []
    roles      = ["codebuild-IAPS-Packer-service-role"]
}

resource "aws_iam_policy_attachment" "Codebuild-PackerIAMPassRole-policy-attachment" {
    name       = "Codebuild-PackerIAMPassRole-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/Codebuild-PackerIAMPassRole"
    groups     = []
    users      = []
    roles      = ["codebuild-IAPS-Packer-service-role"]
}

resource "aws_iam_policy_attachment" "CodeBuildBasePolicy-IAPS_AMI_BUILDER-eu-west-2-policy-attachment" {
    name       = "CodeBuildBasePolicy-IAPS_AMI_BUILDER-eu-west-2-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/service-role/CodeBuildBasePolicy-IAPS_AMI_BUILDER-eu-west-2"
    groups     = []
    users      = []
    roles      = ["codebuild-IAPS-Packer-service-role"]
}

resource "aws_iam_policy_attachment" "CodeBuildBasePolicy-IAPS_AMI_BUILDER_DOCKER-eu-west-2-policy-attachment" {
    name       = "CodeBuildBasePolicy-IAPS_AMI_BUILDER_DOCKER-eu-west-2-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/service-role/CodeBuildBasePolicy-IAPS_AMI_BUILDER_DOCKER-eu-west-2"
    groups     = []
    users      = []
    roles      = ["codebuild-IAPS-Packer-service-role"]
}

resource "aws_iam_policy_attachment" "CodeBuildBasePolicy-IAPS_AMI_BUILDER_GIT_HOOKS-eu-west-2-policy-attachment" {
    name       = "CodeBuildBasePolicy-IAPS_AMI_BUILDER_GIT_HOOKS-eu-west-2-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/service-role/CodeBuildBasePolicy-IAPS_AMI_BUILDER_GIT_HOOKS-eu-west-2"
    groups     = []
    users      = []
    roles      = ["codebuild-IAPS-Packer-service-role"]
}

resource "aws_iam_policy_attachment" "CodeBuildVpcPolicy-IAPS_AMI_BUILDER-eu-west-2-policy-attachment" {
    name       = "CodeBuildVpcPolicy-IAPS_AMI_BUILDER-eu-west-2-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/service-role/CodeBuildVpcPolicy-IAPS_AMI_BUILDER-eu-west-2"
    groups     = []
    users      = []
    roles      = ["codebuild-IAPS-Packer-service-role"]
}

resource "aws_iam_policy_attachment" "Codebuild_PackerIAMCreateRole-policy-attachment" {
    name       = "Codebuild_PackerIAMCreateRole-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/Codebuild_PackerIAMCreateRole"
    groups     = []
    users      = []
    roles      = ["codebuild-IAPS-Packer-service-role"]
}

resource "aws_iam_policy_attachment" "IAPS-AMI-Builder-S3-policy-attachment" {
    name       = "IAPS-AMI-Builder-S3-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/IAPS-AMI-Builder-S3"
    groups     = []
    users      = []
    roles      = ["AWSCodePipelineServiceRole-eu-west-2-IAPS-AMI-Builder", "codebuild-IAPS-Packer-service-role"]
}

resource "aws_iam_policy_attachment" "IAPS-AMI-Builder-SSM-Parameters-policy-attachment" {
    name       = "IAPS-AMI-Builder-SSM-Parameters-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/IAPS-AMI-Builder-SSM-Parameters"
    groups     = []
    users      = []
    roles      = ["codebuild-IAPS-Packer-service-role"]
}

resource "aws_iam_policy_attachment" "IAPS-Packer-Builder-EC2-policy-attachment" {
    name       = "IAPS-Packer-Builder-EC2-policy-attachment"
    policy_arn = "arn:aws:iam::895523100917:policy/IAPS-Packer-Builder-EC2"
    groups     = []
    users      = []
    roles      = ["codebuild-IAPS-Packer-service-role"]
}
