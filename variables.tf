variable "vpc_id" {
  description = "vpc id"
  type        = string
  default     = "vpc-074b43b6d9bdd916b"
}

variable "ec2_subnet_id_1a" {
  description = "subnet id"
  type        = string
  default     = "subnet-02c3006d033aeaca7" # us-east-1a
}

variable "ec2_subnet_id_1f" {
  description = "ec2_subnet_id"
  type        = string
  default     = "subnet-0b60f7967e4d3fc3a" # us-east-1f
}

variable "port" {
  description = "to and from port"
  type        = number
  default     = 2049
}

variable "cidr_block" {
  description = "cidr_blocks"
  type        = list(string)
  default     = ["172.31.64.0/18"]
}

variable "Ec2_secrete_key" {
  description = "Ec2_secrete_key"
  type        = string
  default     = "EC2-keys"
  
}