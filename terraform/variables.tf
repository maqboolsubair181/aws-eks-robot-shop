variable "aws_region" {
  description = "Region for the EKS cluster"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name_prefix" {
  description = "Prefix for the EKS cluster name"
  type        = string
  default     = "maqbool-eks"
}
