locals {
  env         = terraform.workspace
  eks_subnets = [module.vpc.public_subnet[0], module.vpc.public_subnet[1]]
  eks_node_policy_arns = {
    node      = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    cni       = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    container = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
  eks_node_name              = module.eks_cluster_nodes.eks_node_name
  eks_oidc_url               = module.eks_oidc.eks_oidc_url
  eks_oidc_arn               = module.eks_oidc.eks_oidc_arn
  cluster_name               = "${local.env}-cluster"
  cluster_id                 = module.eks_cluster_nodes.eks_cluster_id
  cluster_endpoint           = module.eks_cluster_nodes.eks_cluster_endpoint
  karpenter_instance_profile = module.karpenter.karpenter_instance_profile
  cluster_ca_cert            = module.eks_cluster_nodes.eks_cluster_ca_cert
}

variable "region" {
  default = "us-east-1"
}
variable "subnets" {
  default = {
    public = {
      public-1 = {
        az         = "us-east-1a"
        cidr_block = "10.0.1.0/24"
        map_public = true
      }
      public-2 = {
        az         = "us-east-1b"
        cidr_block = "10.0.2.0/24"
        map_public = true
      }
    },
    private = {
      private-1 = {
        az         = "us-east-1a"
        cidr_block = "10.0.3.0/24"
        map_public = false
      }
      private-2 = {
        az         = "us-east-1b"
        cidr_block = "10.0.4.0/24"
        map_public = false
      }
    }
  }
}
variable "eks_sg_ingress" {
  default = [
    {
      from_port  = 22,
      to_port    = 22,
      protocol   = "tcp",
      cidr_block = "0.0.0.0/0"
    },
    {
      from_port  = 80,
      to_port    = 80,
      protocol   = "tcp",
      cidr_block = "0.0.0.0/0"
    },
    {
      from_port  = 443,
      to_port    = 443,
      protocol   = "tcp",
      cidr_block = "0.0.0.0/0"
    },
  ]
}
variable "eks_cluster_policy_arns" {
  default = {
    cluster        = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    vpc_controller = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }
}

variable "node_groups" {
  default = {
    default_node = {
      node_group_name  = "default-nodegroup"
      instance_types   = ["t2.large"]
      max_scaling_size = 2
      capacity_type    = "ON_DEMAND"
    }
    dev_node = {
      node_group_name  = "dev-nodegroup"
      instance_types   = ["t2.micro"]
      max_scaling_size = 2
      capacity_type    = "SPOT"
    }
  }
}
variable "node_taint" {
  default = {
    key    = "devs"
    value  = "yes"
    effect = "NO_SCHEDULE"
  }

}
