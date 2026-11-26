variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Projektname"
  type        = string
  default     = "techstyle-k8s"
}

variable "vpc_cidr" {
  description = "CIDR für das VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR für das Subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type_master" {
  description = "EC2 Instanztyp für Control Plane (Master)"
  type        = string
  default     = "t3.medium"
}

variable "instance_type_worker" {
  description = "EC2 Instanztyp für Worker Nodes"
  type        = string
  default     = "t3.small"
}

variable "ssh_public_key" {
  description = "SSH Public Key"
  type        = string
  default     = ""
}

variable "join_master_count" {
  description = "Anzahl Master Nodes"
  type        = number
  default     = 1
}

variable "join_worker_count" {
  description = "Anzahl Worker Nodes"
  type        = number
  default     = 2
}
