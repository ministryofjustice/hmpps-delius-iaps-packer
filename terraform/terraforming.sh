#!/bin/bash

# See https://github.com/dtan4/terraforming

#gem install terraforming

#terraforming alb             # ALB
#terraforming cwa             # CloudWatch Alarm
#terraforming asg             # AutoScaling Group
#terraforming dbpg            # Database Parameter Group
#terraforming dbsg            # Database Security Group
#terraforming dbsn            # Database Subnet Group
#terraforming ddb             # DynamoDB
#terraforming ec2             # EC2
#terraforming ecc             # ElastiCache Cluster
#terraforming ecsn            # ElastiCache Subnet Group
#terraforming efs             # EFS File System
#terraforming eip             # EIP
#terraforming elb             # ELB

terraforming iamg  > iam/aws_iam_group.tf          # IAM Group
terraforming iamgm > iam/aws_iam_group_membership.tf          # IAM Group Membership
terraforming iamgp > iam/aws_iam_group_policy.tf          # IAM Group Policy
terraforming iamip > iam/aws_iam_instance_profile.tf          # IAM Instance Profile
terraforming iamp  > iam/aws_iam_policy.tf          # IAM Policy
terraforming iampa > iam/aws_iam_policy_attachment.tf          # IAM Policy Attachment
terraforming iamr  > iam/aws_iam_role.tf          # IAM Role
terraforming iamrp > iam/aws_iam_role_policy.tf          # IAM Role Policy
terraforming iamu  > iam/aws_iam_user.tf          # IAM User
terraforming iamup > iam/aws_iam_user_policy.tf          # IAM User Policy

# terraforming igw             # Internet Gateway
# terraforming kmsa            # KMS Key Alias
# terraforming kmsk            # KMS Key
# terraforming lc              # Launch Configuration
# terraforming nacl            # Network ACL
# terraforming nat             # NAT Gateway
# terraforming nif             # Network Interface
# terraforming r53z            # Route53 Hosted Zone
# terraforming r53r            # Route53 Record
# terraforming rds             # RDS
# terraforming rs              # Redshift
# terraforming rt              # Route Table
# terraforming rta             # Route Table Association
# terraforming s3              # S3
# terraforming sg              # Security Group
# terraforming sn              # Subnet
# terraforming snst            # SNS Topic
# terraforming snss            # SNS Subscription
# terraforming sqs             # SQS
# terraforming vgw             # VPN Gateway
# terraforming vpc             # VPC