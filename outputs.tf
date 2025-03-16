output "first_instance_id" {
  description = "The ID of the first EC2 instance"
  value       = aws_instance.First_instance.id
}

output "first_instance_arn" {
  description = "The ARN of the first EC2 instance"
  value       = aws_instance.First_instance.arn
}

output "second_instance_id" {
  description = "The ID of the second EC2 instance"
  value       = aws_instance.Second_instance.id
}

output "second_instance_arn" {
  description = "The ARN of the second EC2 instance"
  value       = aws_instance.Second_instance.arn
}

output "efs_arn" {
  description = "The ARN of the EFS file system"
  value       = aws_efs_file_system.efs_for_instances.arn
}

output "efs_owner_id" {
  description = "The owner ID of the EFS file system"
  value       = aws_efs_file_system.efs_for_instances.owner_id
}

output "efs_name" {
  description = "The name of the EFS file system"
  value       = aws_efs_file_system.efs_for_instances.tags["Name"]
}

output "iam_instance_profile_unique_id" {
  description = "The unique ID of the IAM instance profile"
  value       = aws_iam_instance_profile.EFS_access_profile.unique_id
}

output "security_group_owner_id" {
  description = "The owner ID of the security group"
  value       = aws_security_group.Instances_SG.owner_id
}