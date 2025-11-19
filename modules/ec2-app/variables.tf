variable "name" {
  description = "Base name for the instance (used in tags and SG name)"
  type        = string
}

variable "role" {
  description = "Logical role of this instance (backend, frontend, etc.)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the instance and SG will live"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the existing SSH key pair"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH into the instance"
  type        = string
}

variable "app_port" {
  description = "Application port to allow in the security group"
  type        = number
}

variable "user_data" {
  description = "User data script to bootstrap the instance"
  type        = string
}

variable "extra_tags" {
  description = "Additional tags to add to the instance and SG"
  type        = map(string)
  default     = {}
}