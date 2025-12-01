module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  # Networking
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets # Nodes deployed in private subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Access Configuration
  # This allows you to run kubectl from your laptop
  cluster_endpoint_public_access = true
  
  # Security: Enable OIDC for Service Accounts (Required for LB Controller)
  enable_irsa = true

  # Permissions: Grant the user running Terraform admin rights
  enable_cluster_creator_admin_permissions = true
  
  cluster_addons = {
    vpc-cni    = { most_recent = true }
    kube-proxy = { most_recent = true }
    coredns    = { most_recent = true }
    aws-ebs-csi-driver = { most_recent = true }
  }
  
  # Node Groups (The Servers)
  eks_managed_node_group_defaults = {
    disk_size = 20
  }

  eks_managed_node_groups = {
    general = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["m7i-flex.large"]
      capacity_type  = "ON_DEMAND"
      
      # Ensure nodes have correct IAM permissions if needed later
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }
}
