# first we create vpc from scratch and then provision kubernetes.check "name" {
provider "aws" {
  region = local.region
}

locals {
  name = "terraform-cluster"
  region = "ap-south-1"


  vpc_cidr = "10.12.0.0/16"
  azs = ["ap-south-1a","ap-south-1b","ap-south-1c"]

   public_subnet = ["10.12.1.0/24", "10.12.2.0/24"]
   private_subnet = ["10.12.3.0/24", "10.12.4.0/24"]
   intra_subnet = ["10.12.5.0/24", "10.12.6.0/24"]
    
    tags = {
        Example = local.name
    }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"
  name = local.name
  cidr = local.vpc_cidr

  azs = local.azs
  private_subnets = local.private_subnet
  public_subnets = local.public_subnet
  intra_subnets = local.intra_subnet

  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami = "0440d3b780d96b29d"
    
    instance_types = ["t2.micro"]
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "helloworld"
      }
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
 

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}