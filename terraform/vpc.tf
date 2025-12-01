data "aws_availability_zones" "available" {}

locals {
  # Generates a name like "maqbool-eks-a1b2c3d4"
  cluster_name = "${var.cluster_name_prefix}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "${local.cluster_name}-vpc"
  cidr = var.vpc_cidr

  # We use the first two AZs available in the region
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  
  # Private Subnets: For your Worker Nodes (Security Best Practice)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  
  # Public Subnets: For the Load Balancer and NAT Gateway
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true # set to false for HA in production (costs more)
  enable_dns_hostnames = true

  # Tags required for EKS
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  # CRITICAL: These tags allow the Load Balancer to find the public subnets
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  # CRITICAL: These tags allow the cluster to find private subnets for internal routing
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
