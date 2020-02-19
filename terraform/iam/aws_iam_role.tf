resource "aws_iam_role" "AWSCodePipelineServiceRole-eu-west-2-IAPS-AMI-Builder" {
    name               = "AWSCodePipelineServiceRole-eu-west-2-IAPS-AMI-Builder"
    path               = "/service-role/"
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "codebuild-IAPS-Packer-service-role" {
    name               = "codebuild-IAPS-Packer-service-role"
    path               = "/service-role/"
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
