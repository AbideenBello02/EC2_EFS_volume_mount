# Terraform Project: EC2 with EFS Volume Attachment

This Terraform project sets up an AWS environment with the following resources:
- IAM Role and Policy for EC2 instances to access EFS
- Security Group for EC2 instances
- EFS File System and Mount Targets
- EC2 Instances in different subnets
- Null Resource to mount EFS on the second EC2 instance

## Prerequisites

- Terraform installed on my local machine
- AWS CLI configured with appropriate credentials
- An existing VPC and subnets in my aws free-tier environment

## Variables

The following variables are used in the Terraform configuration:

- `vpc_id`: The ID of the VPC where the resources will be created.
- `ec2_subnet_id_1a`: The ID of the subnet for the first EC2 instance.
- `ec2_subnet_id_1f`: The ID of the subnet for the second EC2 instance.
- `port`: The port number for EFS access.
- `cidr_block`: The CIDR block for the security group ingress rule.

# Outputs

The following outputs are provided by this Terraform configuration:

- `first_instance_id`: The ID of the first EC2 instance.
- `first_instance_arn`: The ARN of the first EC2 instance.
- `second_instance_id`: The ID of the second EC2 instance.
- `second_instance_arn`: The ARN of the second EC2 instance.
- `efs_arn`: The ARN of the EFS file system.
- `efs_owner_id`: The owner ID of the EFS file system.
- `efs_name`: The name of the EFS file system.
- `iam_instance_profile_unique_id`: The unique ID of the IAM instance profile.
- `security_group_owner_id`: The owner ID of the security group.
