terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "null" {}

resource "aws_iam_role" "ec2_access_to_efs" {
  name = "ec2_access_to_efs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "efs_access_policy" {
  name = "efs_access_policy_attachment"

  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadOnlyAccess"
  ])

  # the roles to attacch policy to
  roles      = [aws_iam_role.ec2_access_to_efs.name]
  policy_arn = each.value
}

# Create rofile for EC2 instances that will assume the role
resource "aws_iam_instance_profile" "EFS_access_profile" {
  name = "EFS_access_profile"
  role = aws_iam_role.ec2_access_to_efs.name
}

# Creating security group for EC2 instances
resource "aws_security_group" "Instances_SG" {
  name   = "instances_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.cidr_block
    description = "EFS port"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }
}

# Creating EFS file system
resource "aws_efs_file_system" "efs_for_instances" {
  performance_mode = "generalPurpose"
  encrypted        = false
  throughput_mode  = "bursting"

  tags = {
    Name = "efs for instances"
  }
}

# EFS mount target in us-east-1a
resource "aws_efs_mount_target" "us-east-1a-mount-target" {
  file_system_id  = aws_efs_file_system.efs_for_instances.id
  subnet_id       = var.ec2_subnet_id_1a
  security_groups = [aws_security_group.Instances_SG.id]
}

# EFS mount target in us-east-1f
resource "aws_efs_mount_target" "us-east-1f-mount-target" {
  file_system_id  = aws_efs_file_system.efs_for_instances.id
  subnet_id       = var.ec2_subnet_id_1f
  security_groups = [aws_security_group.Instances_SG.id]
}

# Creating EC2 instance in us-east-1a
resource "aws_instance" "First_instance" {
  ami                  = "ami-08b5b3a93ed654d19"
  instance_type        = "t2.micro"
  key_name             = var.Ec2_secrete_key
  security_groups      = [aws_security_group.Instances_SG.id]
  subnet_id            = var.ec2_subnet_id_1a
  iam_instance_profile = aws_iam_instance_profile.EFS_access_profile.name

  tags = {
    Name = "instance in us-east-1a"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y amazon-efs-utils
    mkdir -p /mnt/efs
    mount -t efs ${aws_efs_file_system.efs_for_instances.id}:/ /mnt/efs
    echo "${aws_efs_file_system.efs_for_instances.id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab
    EOF
}

# Creating EC2 instance in us-east-1f
resource "aws_instance" "Second_instance" {
  ami                  = "ami-08b5b3a93ed654d19"
  instance_type        = "t2.micro"
  key_name             = var.Ec2_secrete_key
  security_groups      = [aws_security_group.Instances_SG.id]
  subnet_id            = var.ec2_subnet_id_1f
  iam_instance_profile = aws_iam_instance_profile.EFS_access_profile.name

  tags = {
    Name = "instance in us-east-1f"
  }
}

# Mounting EFS to the second instance using null_resource
resource "null_resource" "mount_efs_second_instance" {
  depends_on = [aws_instance.Second_instance]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/${var.Ec2_secrete_key}.pem")
    host        = aws_instance.Second_instance.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y amazon-efs-utils",
      "sudo mkdir -p /mnt/efs",
      "sudo mount -t efs ${aws_efs_file_system.efs_for_instances.id}:/ /mnt/efs",
      "echo '${aws_efs_file_system.efs_for_instances.id}:/ /mnt/efs efs defaults,_netdev 0 0' | sudo tee -a /etc/fstab"
    ]
  }
}
